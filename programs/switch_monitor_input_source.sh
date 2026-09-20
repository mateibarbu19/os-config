#!/usr/bin/env bash

if ddcutil getvcp 60 -n 8NVLK03 | grep -q DisplayPort; then
  ddcutil setvcp 60 0x1b -n 8NVLK03
else
  ddcutil setvcp 60 0x0f -n 8NVLK03
fi
