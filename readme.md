# Connect to an SBX over SSH:
1. Power on SBX board and ensure it has an ethernet cable plugged in.
2. From a terminal window enter the following:
```
ssh echopilot@{THE_IP}
```
`password = echopilot`

# Test Fermion
1. Connect the blue microcoax to the Fermion board.
2. Start the EO video (if the shape is weird in GCS, kill the command and rerun (right click app on desktop, run as program):
```
./test_eo.sh
```
3. In QGroundControl GCS confirm video. Adjust lens until the tuning image is as sharp as possible. Tighten the lockring and apply a small bit of plastic epoxy.
4. Back on the terminal window, kill the previous command (Ctrl-C). Then verify thermal streaming (no focus needed, only functionality).
```
./test_thermal.sh
```
5. Kill that command then put on QC Pass sticker.

# Test Fan
Run `python test_fan.py`.
The code will toggle fan power between 100% and 40%.
For the best test _connect the fan when the output reads 40%_ and ensure the fan spins up and increases power at 100% and the decreases at the next 40%.
Note: A small percent of fans when first powered up at 40% will remain off even when output is increased to 100%. 
