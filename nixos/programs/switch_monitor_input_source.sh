#!/run/current-system/sw/bin/bash

if /run/current-system/sw/bin/ddcutil getvcp 60 -n 8NVLK03 | grep -q DisplayPort; then
  /run/current-system/sw/bin/ddcutil setvcp 60 0x1b -n 8NVLK03
else
  /run/current-system/sw/bin/ddcutil setvcp 60 0x0f -n 8NVLK03
fi
