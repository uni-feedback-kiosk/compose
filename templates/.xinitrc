#!/bin/bash

# Read environment variables
set -a && source ./.env && set -a

# Get screen resolution
IFS='x' read width height <<<  $(xrandr | grep '*' | awk '{ print $1 }')

# Run the app
$APP_PATH --width "$width" --height "$height" | logger -t kiosk-app
