#!/bin/bash

TARGET_IP=10.0.0.38
SUDO=$(test ${EUID} -ne 0 && which sudo)
$SUDO systemctl stop video-eo
pistreamer --config_file=/usr/lib/python3.11/dist-packages/pistreamer/477-Pi4.json --radio_type="test" --gcs_ip=${TARGET_IP} --verbose
