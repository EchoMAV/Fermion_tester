#!/bin/bash

TARGET_IP=10.0.0.63

pistreamer --config_file=/usr/lib/python3.11/dist-packages/pistreamer/477-Pi4.json --radio_type="test" --gcs_ip=${TARGET_IP}
