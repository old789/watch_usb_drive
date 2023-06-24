#!/bin/sh

mpoint='/opt'

is_mount () {
  tst = `/bin/df | /usr/bin/grep -w "$mpoint" | /usr/bin/awk '{print $1}'`
  if [ 'x'$tst == 'x' ]; then
    return 1
  fi
  return 0
}

