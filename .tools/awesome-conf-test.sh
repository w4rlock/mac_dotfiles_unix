#!/bin/sh

Xephyr -ac -br -noreset -screen 1200x768 :1.0 &
ZEPHYR_PID=$!
sleep 1
DISPLAY=:1.0 awesome -c $HOME/.config/awesome/rc.lua
kill $ZEPHYR_PID