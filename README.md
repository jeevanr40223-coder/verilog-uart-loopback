# UART Loopback System in Verilog

## Overview

A UART loopback system that connects a UART transmitter directly to a UART receiver. It verifies serial transmission and reception by sending a byte and checking that the same byte is recovered.

## Features

* Integrated UART transmitter and receiver
* Configurable clock cycles per bit
* Serial TX-to-RX loopback connection
* Self-checking simulation testbench
* Yosys synthesis and structural checks

## Design Parameters

* `CLKS_PER_BIT`: Number of clock cycles per UART bit (default: 16)

## Files

* `uart_tx.v` — UART transmitter
* `uart_rx.v` — UART receiver
* `uart_loopback.v` — Top-level loopback module
* `tb_uart_loopback.v` — Self-checking testbench
* `synthesis_report.txt` — Yosys synthesis report

## Verification

The testbench transmits `8'hA5` and checks that the receiver returns the same byte.

Expected result:

* `PASS: UART loopback received 0xa5`
* `PASS: UART loopback test completed.`

## Simulation

Requires Icarus Verilog.

```bash
iverilog -g2012 -o uart_loopback_sim uart_tx.v uart_rx.v uart_loopback.v tb_uart_loopback.v
vvp uart_loopback_sim
```

## Synthesis

Requires Yosys.

```bash
yosys -p "read_verilog uart_tx.v uart_rx.v uart_loopback.v; hierarchy -top uart_loopback; proc; opt; check; stat" | tee synthesis_report.txt
```

The structural check reported zero problems.

## Tools

* Verilog HDL
* Icarus Verilog
* Yosys
* Ubuntu on WSL
