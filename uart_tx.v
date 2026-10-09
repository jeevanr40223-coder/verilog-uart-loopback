module uart_tx #(
    parameter CLKS_PER_BIT = 16
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_busy
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [7:0] data_reg;
    reg [3:0] bit_index;
    reg [31:0] clk_count;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            data_reg  <= 8'd0;
            bit_index <= 4'd0;
            clk_count <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    clk_count <= 32'd0;
                    bit_index <= 4'd0;

                    if (tx_start) begin
                        data_reg  <= tx_data;
                        tx        <= 1'b0;
                        tx_busy   <= 1'b1;
                        state     <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'd0;
                        bit_index <= 4'd0;
                        tx        <= data_reg[0];
                        state     <= DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'd0;

                        if (bit_index == 4'd7) begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            tx <= data_reg[bit_index + 1'b1];
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'd0;
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state     <= IDLE;
                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    clk_count <= 32'd0;
                end
            endcase
        end
    end

endmodule
