#!/bin/sh

mpoint='/opt'
mpoint='/data'
tst_folder=$mpoint'/test'
tst_file=$tst_folder'/tfile'
tst_str='123qwer'
semaphore='/var/run/watch_usb'
debug_mode=1

is_mount () {
  tst=`/bin/df | /usr/bin/grep -w "$mpoint" | /usr/bin/awk '{print $1}'`
  if [ 'x'$tst == 'x' ]; then
    return 1
  fi
  return 0
}

is_disk_good () {
  if [ ! -d "$tst_folder" ]; then
    /bin/mkdir -p "$tst_folder"
  fi
  /usr/bin/stdbuf -o0 echo "$tst_str" > "tst_file"
  /bin/sleep 5
  tst_str1=`cat "tst_file"`
  /bin/rm -f "tst_file"
  if [ "$tst_str" != "$tst_str1" ]; then
    return 1
  fi
  return 0
}

is_semaphore () {
  if [ -f "$semaphore" ]; then
    return 1
  fi
  return 0
}

progname=`/usr/bin/basename $0`

is_mount
if [ $? -gt 0 ]; then
  /usr/bin/logger -t $progname  The drive is not mounted
  if [ $debug_mode -gt 0 ]; then
    echo The drive is not mounted
    exit 1
  else
    /sbin/reboot
  fi
fi

is_disk_good
if [ $? -gt 0 ]; then
  /usr/bin/logger -t $progname The drive is not accessible
  if [ $debug_mode -gt 0 ]; then
    echo The drive is not accessible
    exit 1
  else
    is_semaphore && /sbin/reboot || /usr/bin/logger -t $progname The semaphore file found so don\'t reboot
  fi
fi

is_semaphore && /bin/rm -f "$semaphore"

if [ $debug_mode -gt 0 ]; then
    echo All Ok
fi
exit 0
