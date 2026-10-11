`timescale 1ns/1ps
module uart_rx #(
    parameter CLKS_PER_BIT = 16
)(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_valid
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data_reg  <= 0;
            rx_data   <= 0;
            rx_valid  <= 0;
        end else begin
            rx_valid <= 0;

            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx == 0)
                        state <= START;
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT / 2) - 1) begin
                        clk_count <= 0;

                        if (rx == 0)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx;

                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= IDLE;

                        if (rx == 1) begin
                            rx_data  <= data_reg;
                            rx_valid <= 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
