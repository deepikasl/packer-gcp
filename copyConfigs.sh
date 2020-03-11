#!/bin/bash -e

echo "Copying 99-pipelines.conf..."
sudo cp /tmp/99-pipelines.conf /etc/sysctl.d/99-pipelines.conf
