`timescale 1ns/1ps
module uart_loopback #(
    parameter CLKS_PER_BIT = 16
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       tx_busy,
    output wire       serial_line
);

    // UART transmitter
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(serial_line),
        .tx_busy(tx_busy)
    );

    // UART receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(serial_line),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

endmodule
