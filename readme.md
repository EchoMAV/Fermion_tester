power on SBX board
connect to the board, from terminal window:
```
ssh echopilot@10.0.0.73
```
password = echopilot

1. Connect the blue microcoax to the Fermion board

2. Start the EO video (if the shape is weird in GCS, kill the command and rerun (right click app on desktop, run as program):
```
./test_eo.sh
```

3. In QGroundControl GCS confirm video. Adjust lens until the tuning image is as sharp as possible. Tighten the lockring and apply a small bit of plastic epoxy.

4. Back on the terminal window, kill the previous command (Ctrl-C). Then verify thermal streaming (no focus needed, only functionality)
```
./test_thermal.sh
```

5. Kill that command then put on QC Pass sticker.
