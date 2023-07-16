#!/bin/bash
while true; do
  lsof -i -P -n | grep LISTEN &
  sleep 10 # wait 10 seconds before running the command again
done