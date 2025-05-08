#!/bin/bash
# script to test thermal camera connected to a Fermion Camera
# 
# 
SUDO=$(test ${EUID} -ne 0 && which sudo)
LOCAL=/usr/local
TEST_SCRIPT=./detect_thermal.sh
TARGET_IP=10.0.0.63
TARGET_PORT=5600

echo "Start Fermion Thermal Tester"

SUDO=$(test ${EUID} -ne 0 && which sudo)
$SUDO systemctl stop video-thermal

THERMAL_BITRATE=1000

#Scale the THERMAL_BITRATE from kbps to bps
# different encoders take different scales, rpi v4l2h264enc takes bps
SCALED_THERMAL_BITRATE=$(($THERMAL_BITRATE * 1000)) 

# First detect what camera is attached, need to make sure echothermd is running or the echotherm won't be detected
    # Path to the lock file
echothermd --kill
sleep 1
LOCK_FILE="/tmp/echothermd.lock"
# Check if the lock file exists
if [ -f "$LOCK_FILE" ]; then
   	echo "Removing found lock file"
        #Remove the lock file
	rm "$LOCK_FILE"
fi
      
echothermd --daemon --colorPalette 4 --maxZoom 16
sleep 1

THERMALCAMERA=$(sudo "$TEST_SCRIPT")

echo "Thermal Camera is ${THERMALCAMERA}"

if [ "$THERMALCAMERA" = "boson640" ] || [ "$THERMALCAMERA" = "boson320" ] ; then

    if [ "$THERMALCAMERA" = "boson640" ]; then
        echo "Detected FLIR Boson 640"
        video_devices=$(ls /dev/video*)
        # Loop through each video device and check if it is a FLIR Boson camera
        for device in $video_devices; do
            # Use v4l2-ctl to get the device name
            device_name=$(v4l2-ctl -d $device --info | grep "Model" | awk '{print $3}')        
            # Check if the device name matches FLIR Boson (assuming "boson" is part of the driver name)
            if [[ "$device_name" == *"Boson"* ]]; then
                echo "FLIR Boson camera found at: $device"   
                # create the pipeline thermalsrc
                echo "Creating the thermalSrc pipeline..." 
                # original working pipeline tesed with QGCS     
                gst-launch-1.0 v4l2src device=$device io-mode=mmap ! "video/x-raw,format=(string)I420,width=(int)640,height=(int)512,framerate=(fraction)30/1" ! v4l2h264enc extra-controls="controls,video_bitrate=$SCALED_THERMAL_BITRATE" ! "video/x-h264,level=(string)4.2" ! rtph264pay config-interval=1 pt=96 ! udpsink host=$TARGET_IP port=$TARGET_PORT sync=false
                break
            fi
        done
    elif [ "$THERMALCAMERA" = "boson320" ]; then
        echo "Looking for FLIR Boson 320"
        video_devices=$(ls /dev/video*)
        # Loop through each video device and check if it is a FLIR Boson camera
        for device in $video_devices; do
            # Use v4l2-ctl to get the device name
            device_name=$(v4l2-ctl -d $device --info | grep "Model" | awk '{print $3}')        
            # Check if the device name matches FLIR Boson (assuming "boson" is part of the driver name)
            if [[ "$device_name" == *"Boson"* ]]; then
                echo "FLIR Boson camera found at: $device"       
                # create the pipeline thermalSrc
                #echo "Creating the thermalSrc pipeline..." 
                #gst-client pipeline_create thermalSrc v4l2src device=$device io-mode=mmap ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=ultrafast bitrate=${THERMAL_BITRATE} key-int-max=30 bframes=0 name=thermalEncoder ! queue ! interpipesink name=thermalSrc                           
                # original working pipeline tested with QGCS
                gst-launch-1.0 v4l2src device=$device ! v4l2h264enc extra-controls="controls,video_bitrate=${SCALED_THERMAL_BITRATE}" name=thermalEncoder ! "video/x-h264,level=(string)4.2" ! rtph264pay config-interval=1 pt=96 ! interpipesink name=thermalsrc
                break
            fi
        done
    fi

elif [ "$THERMALCAMERA" = "echotherm320" ]; then
    echo "Starting pipeline for Echotherm 320"
    #run echothermd to be able to control the echothermcam
    video_devices=$(ls /dev/video*)
    for device in $video_devices; do
        # Use v4l2-ctl to get the device name
        device_name=$(v4l2-ctl -d $device --info | awk '/Card type/ { card_type = substr($0, index($0, ":") + 2) } END {print card_type}')        
        # Check if the device name matches EchoTherm
        echo "Inspecting $device and checking $device_name for EchoTherm or Dummy video"
        if [[ "$device_name" == *"EchoTherm"* || "$device_name" == *"Dummy video"* ]]; then        
            echo "EchoMAV EchoTherm camera found at: $device"       
            # create the pipeline thermalSrc
            #echo "Creating the thermalSrc pipeline..."           
            #
            #gst-client pipeline_create thermalSrc v4l2src device=$device ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=ultrafast bitrate=${THERMAL_BITRATE} key-int-max=30 bframes=0 name=thermalEncoder ! queue ! interpipesink name=thermalSrc            
            # original pipeline tested with QGCS
            gst-launch-1.0 v4l2src device=$device ! videoconvert ! video/x-raw,format=I420 ! x264enc bitrate=${THERMAL_BITRATE} speed-preset=superfast tune=zerolatency ! rtph264pay config-interval=1 pt=96 ! udpsink host=${TARGET_IP} port=${TARGET_PORT} sync=false            
            # original pipeline tested with ATAK
            # gst-launch-1.0 -v v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,format=I420 ! x264enc bitrate=700 speed-preset=superfast tune=zerolatency ! mpegtsmux alignment=7 ! udpsink host=172.20.1.1 port=5700 sync=false
            break
         fi
    done   
fi


# This script just sets up the pipelines, but does not actually start them.
# echoliteProxy will start the thermal pipeline with "gst-client pipeline_play (thermalRTP|thermalMPEGTS)"


