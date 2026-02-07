#!/bin/bash

# Check if a command exists
command_to_check="nm-connection-editor"

if command -v $command_to_check &> /dev/null
then
    echo "$command_to_check exists. Exiting."
    exit 1
else
    echo "$command_to_check does not exist. Running the Connman Settings..."
    connman-gtk
fi
