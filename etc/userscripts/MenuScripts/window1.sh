#!/bin/bash

# Get the active window ID
active_id=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')

# Get the active window information
wininfo=$(xwininfo -id "$active_id")

# Extract window position and height
window_x=$(echo "$wininfo" | grep "Absolute upper-left X:" | awk '{print $4}')
window_y=$(echo "$wininfo" | grep "Absolute upper-left Y:" | awk '{print $4}')
window_height=$(echo "$wininfo" | grep "Height:" | awk '{print $2}')

# Debugging output for window position and height
echo "Window X: $window_x"
echo "Window Y: $window_y"
echo "Window Height: $window_height"

# Ensure window position and height are integers
if ! [[ "$window_x" =~ ^[0-9]+$ ]] || ! [[ "$window_y" =~ ^[0-9]+$ ]] || ! [[ "$window_height" =~ ^[0-9]+$ ]]; then
    echo "Error: Window position or height is not a valid integer."
    exit 1
fi

# Get all connected monitors
monitors=$(xrandr | grep ' connected')

# Variables for the active monitor
screen_width=""
screen_height=""
monitor_x=""
monitor_y=""
found=false

# Find the primary monitor first for fallback
primary_line=$(echo "$monitors" | grep ' primary' || echo "$monitors" | head -n1)
primary_geo=$(echo "$primary_line" | grep -oP '\d+x\d+\+\d+\+\d+')
if [ -n "$primary_geo" ]; then
    primary_w=$(echo "$primary_geo" | cut -d 'x' -f1)
    primary_h=$(echo "$primary_geo" | cut -d 'x' -f2 | cut -d '+' -f1)
    primary_x=$(echo "$primary_geo" | cut -d '+' -f2)
    primary_y=$(echo "$primary_geo" | cut -d '+' -f3)
fi

# Loop through each monitor to find the one containing the window's top-left corner
while IFS= read -r line; do
    geo=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+')
    if [ -n "$geo" ]; then
        mon_w=$(echo "$geo" | cut -d 'x' -f1)
        mon_h=$(echo "$geo" | cut -d 'x' -f2 | cut -d '+' -f1)
        mon_x=$(echo "$geo" | cut -d '+' -f2)
        mon_y=$(echo "$geo" | cut -d '+' -f3)

        # Check if window is on this monitor
        if [ "$window_x" -ge "$mon_x" ] && [ "$window_x" -lt "$((mon_x + mon_w))" ] && \
           [ "$window_y" -ge "$mon_y" ] && [ "$window_y" -lt "$((mon_y + mon_h))" ]; then
            screen_width="$mon_w"
            screen_height="$mon_h"
            monitor_x="$mon_x"
            monitor_y="$mon_y"
            found=true
            break
        fi
    fi
done <<< "$monitors"

# If not found, fallback to primary or first monitor
if [ "$found" = false ]; then
    screen_width="$primary_w"
    screen_height="$primary_h"
    monitor_x="$primary_x"
    monitor_y="$primary_y"
fi

# Debugging output for monitor details
echo "Screen width: $screen_width"
echo "Screen height: $screen_height"
echo "Monitor X position: $monitor_x"
echo "Monitor Y position: $monitor_y"

# Ensure width and height are integers
if ! [[ "$screen_width" =~ ^[0-9]+$ ]] || ! [[ "$screen_height" =~ ^[0-9]+$ ]]; then
    echo "Error: Screen width or height is not a valid integer."
    exit 1
fi

# Calculate the Y coordinate for the bottom left position, adjusted up by 25px
y_coordinate=$((monitor_y + screen_height - window_height - 25))

# Ensure the Y coordinate is not negative
if [ "$y_coordinate" -lt 0 ]; then
    y_coordinate=0
fi

# Debugging output for Y coordinate
echo "Calculated Y coordinate: $y_coordinate"

# Move the active window to the bottom left of the active monitor
wmctrl -r :ACTIVE: -e 0,"$monitor_x","$y_coordinate",-1,-1

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to move the active window."
else
    echo "Successfully moved the active window."
fi