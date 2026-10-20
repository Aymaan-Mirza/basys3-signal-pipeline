# Basys 3 Real-Time Signal Processing Pipeline

A small hardware pipeline in SystemVerilog on a Digilent Basys 3 (AMD Xilinx Artix-7, 100 MHz clock). It reads an 8-bit value from the switches, smooths it with a moving average, and lights an LED when the smoothed value crosses a threshold.

## Why I built it

I built this to learn RTL design from scratch: writing hardware in SystemVerilog, simulating it, closing timing, and running it on a real FPGA board. I wanted a project small enough to finish completely but with real pieces in it: input handling, a datapath, and a decision.

The filter plus threshold pattern is also a tiny version of something real. Sensors give jumpy readings and acting on a single raw reading can cause false triggers. This acts as a way of smoothing out any type of data that may be an obstacle.

Example (threshold = 40):

    Raw readings:      30  30  30  30  60  30  30  30
    Raw >= 40?          0   0   0   0   1   0   0   0   <- one glitch triggers it
    Filtered output:   30  30  30  30  37  37  37  37
    Filtered >= 40?     0   0   0   0   0   0   0   0   <- glitch is smoothed out

A single spike of 60 would trip a raw threshold, but the 4-sample average only reaches 37, so the detector stays off. The tradeoff is latency: a real, sustained change takes a few samples to show up in the output.

## How it works

    sw[7:0] --> [moving average filter] --> [threshold detector] --> led15 (latched)
                        ^                            
    btnC --> [button one-pulse]        btnU = reset

- **button_one_pulse**: turns a long button press into a single one-clock-cycle pulse (rising-edge detect), so one press means one sample.
- **moving_average_filter**: keeps the last 3 samples plus the new one, sums them in 10 bits, and outputs sum[9:2], which is a divide by 4 done as a right shift (just wiring).
- **threshold_detector**: combinational, outputs detected when the filtered value >= 40.
- **top**: connects everything. The 8 LEDs show the filtered value, and LED 15 latches the last detection result. btnU resets.

## Results

- Timing at 100 MHz: setup slack +4.837 ns, hold slack +0.121 ns.
- Example: after reset, a first input of 10 outputs 2 (2.5 truncated), then (10, 20) outputs 7.

## Verification

Three self-checking testbenches in `sim/`:
- Filter: inputs 10 to 80 in steps of 10, expects 2, 7, 15, 25, 35, 45, 55, 65.
- Threshold detector: 25, 35, 39 are off, and 40, 45, 65 are on.
- Full pipeline: end-to-end, expects detected 0,0,0,0,0,1,1,1.

## How to use

1. Create a Vivado project for the Basys 3 (xc7a35tcpg236-1).
2. Add the files in `src/` as design sources, `constraints/basys3.xdc` as constraints, and `sim/` as simulation sources.
3. Run the testbenches, then generate the bitstream and program the board.

## Known limitations and next steps

- The output is marked valid on the first sample, with no warm-up flag for the 4-sample window.
- No synchronizer or debounce on the button input.
- Tests are directed with hardcoded expectations. Next: random tests against a Python reference model, reset mid-stream, and 0 and 255 corner cases.
