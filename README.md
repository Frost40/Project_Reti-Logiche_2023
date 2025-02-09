# Logic Networks Project - README

## Table of Contents

- [Overview](#overview)
- [Project Specifications](#project-specifications)
  - [Inputs and Outputs](#inputs-and-outputs)
  - [Functionality](#functionality)
  - [Timing Constraints](#timing-constraints)
- [Component Interface](#component-interface)
- [Memory Description](#memory-description)
- [Evaluation](#evaluation)
- [Conclusion](#conclusion)

## Overview
The project was developed as part of the curriculum for the Politecnico di Milano, showcasing my understanding and application of digital logic design principles.
It conists in an implementation of a hardware module described in VHDL, designed to interface with memory and adhere to the specifications outlined for the Academic Year 2022-2023. The system receives instructions regarding a memory location, retrieves the content, and directs it to one of four available output channels.

## Project Specifications

### Inputs and Outputs

- **Primary Inputs:**
  - `W`: 1-bit input for serial data.
  - `START`: 1-bit input to initiate the process.

- **Primary Outputs:**
  - `Z0`, `Z1`, `Z2`, `Z3`: Four 8-bit output channels.
  - `DONE`: 1-bit output indicating the completion of the operation.

- **Control Signals:**
  - `CLK`: Clock signal for synchronization.
  - `RESET`: Signal to initialize the module.

### Functionality

1. **Initialization:**
   - Upon reset, all outputs (`Z0`, `Z1`, `Z2`, `Z3`) are set to `00000000`, and `DONE` is set to `0`.

2. **Data Input:**
   - The input data is received serially on the `W` line, organized as follows:
     - 2 bits for header (indicating the output channel).
     - N bits for the memory address (0 to 16 bits).

3. **Output Channel Identification:**
   - The first bit of the header indicates the most significant bit, while the second indicates the least significant bit:
     - `00` → `Z0`
     - `01` → `Z1`
     - `10` → `Z2`
     - `11` → `Z3`

4. **Memory Addressing:**
   - The memory address is constructed from the N bits, padded with zeros if necessary to form a 16-bit address.

5. **Operation Timing:**
   - The sequence is valid when `START` is high and ends when `START` is low.
   - The `DONE` signal transitions from `0` to `1` when the message is written to the output channel and returns to `0` after one clock cycle.

### Timing Constraints

- The maximum time to produce a result (from `START=0` to `DONE=1`) must be less than 20 clock cycles.
- The `START` signal remains low until `DONE` returns to `0`.

## Component Interface

The module is defined with the following interface:

```vhdl
  entity project_reti_logiche is
      port (
          i_clk       : in std_logic;
          i_rst       : in std_logic;
          i_start     : in std_logic;
          i_w         : in std_logic;
          o_z0        : out std_logic_vector(7 downto 0);
          o_z1        : out std_logic_vector(7 downto 0);
          o_z2        : out std_logic_vector(7 downto 0);
          o_z3        : out std_logic_vector(7 downto 0);
          o_done      : out std_logic;
          o_mem_addr  : out std_logic_vector(15 downto 0);
          i_mem_data  : in std_logic_vector(7 downto 0);
          o_mem_we    : out std_logic;
          o_mem_en    : out std_logic
      );
  end project_reti_logiche;
```

## Memory Description
The memory is instantiated within the test bench and is not synthesized. It operates in a single-port block RAM write-first mode, allowing for both read and write operations based on the control signals.

## Evaluation
This project was evaluated, and I received a score of **30/30**.

## Conclusion
This project aims to provide a robust implementation of a logic network module that effectively interfaces with memory, adhering to the specified requirements. The design is structured to ensure clarity and functionality, making it suitable for educational and practical applications in digital logic design.
