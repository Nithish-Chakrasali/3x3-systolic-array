# 3×3 Systolic Array Accelerator for Matrix Multiplication

A hardware accelerator designed using Verilog/SystemVerilog to perform 3×3 matrix multiplication using an **output-stationary systolic array architecture**.

## Project Overview

This project implements a 3×3 systolic array consisting of nine Processing Elements (PEs). Each PE performs multiply-accumulate (MAC) operations while passing input data to neighboring PEs.

The accelerator includes:
- Processing Element (PE)
- 3×3 Systolic Array
- Input Scheduler
- Integrated Accelerator Top Module
- Verilog/SystemVerilog Testbenches

## Architecture

The accelerator uses an output-stationary dataflow architecture.

- Each PE contains a 32-bit accumulator.
- Matrix A elements propagate horizontally from left to right.
- Matrix B elements propagate vertically from top to bottom.
- Each PE performs multiplication and accumulation when both input-valid signals are asserted.
- Accumulated results remain stored locally in the PE.

### Block Diagram

```text
             Matrix B
                |
                v
          +-----+-----+-----+
Matrix A  | PE(0,0)   | PE(0,1)   | PE(0,2) |
--------->|           |           |         |
          +-----------+-----------+---------+
          | PE(1,0)   | PE(1,1)   | PE(1,2) |
          +-----------+-----------+---------+
          | PE(2,0)   | PE(2,1)   | PE(2,2) |
          +-----------+-----------+---------+
                     |
                     v
               Output Matrix C
```

## Hardware Specifications

| Parameter | Description |
|---|---|
| Array size | 3×3 |
| Number of PEs | 9 |
| Input data width | 8-bit signed |
| Multiplier output | 16-bit signed |
| Accumulator width | 32-bit signed |
| Dataflow | Output-stationary |
| Clocking | Single clock |
| Reset | Synchronous, active-high |
| Operation | Multiply-Accumulate (MAC) |

## Project Structure

```text
3x3-Systolic-Array/
│
├── processing_element.sv
├── systolic_array_3x3.sv
├── input_scheduler_3x3.sv
├── systolic_accelerator_3x3.sv
│
├── tb_processing_element.sv
├── tb_input_scheduler_3x3.sv
├── tb_systolic_accelerator_3x3.sv
│
├── .gitignore
└── README.md
```

## Matrix Multiplication Example

### Input Matrix A

```text
1  2  3
4  5  6
7  8  9
```

### Input Matrix B

```text
9  8  7
6  5  4
3  2  1
```

### Expected Output Matrix C

```text
30   24   18
84   69   54
138  114  90
```

The accelerator successfully produced the expected output matrix during simulation.

## Simulation and Verification

The design was simulated using **Icarus Verilog**.

### Tools Used

- Verilog/SystemVerilog
- Icarus Verilog
- GTKWave (optional, for waveform analysis)
- Visual Studio Code
- Git and GitHub

### Run the Integrated Accelerator Testbench

Compile the design:

```powershell
iverilog -g2012 -s tb_systolic_accelerator_3x3 -o accelerator_sim processing_element.sv systolic_array_3x3.sv input_scheduler_3x3.sv systolic_accelerator_3x3.sv tb_systolic_accelerator_3x3.sv
```

Run the simulation:

```powershell
vvp accelerator_sim
```

### Verification Results

```text
=================================
  3x3 SYSTOLIC ACCELERATOR TEST
=================================

Accelerator completed successfully!

Output Matrix C:
30      24      18
84      69      54
138     114     90

Verification:
PASS: All 9 output elements

ALL ACCELERATOR TESTS PASSED!
```

## Key Features

- Modular RTL design.
- Nine parallel Processing Elements.
- Signed multiplication and accumulation.
- Independent input-valid signals.
- Automatic input scheduling and data alignment.
- Integrated accelerator with busy and done control signals.
- Testbench-based functional verification.

## Future Improvements

- Parameterizable systolic array dimensions.
- Support for larger matrix sizes.
- FPGA implementation and resource utilization analysis.
- Performance and timing analysis.
- Support for additional data widths.

## Author

**Nithish Chakrasali**

GitHub: [Nithish-Chakrasali](https://github.com/Nithish-Chakrasali)

---

*This project was developed as a hands-on RTL design and digital hardware architecture project.*