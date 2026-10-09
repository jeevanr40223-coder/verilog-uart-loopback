`timescale 1ns/1ps

module tb_uart_loopback;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'hA5;

    wire [7:0] rx_data;
    wire rx_valid;
    wire tx_busy;
    wire serial_line;

    integer received = 0;

    // 16 clocks per bit for a fast simulation
    uart_loopback #(
        .CLKS_PER_BIT(16)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_busy(tx_busy),
        .serial_line(serial_line)
    );

    always #5 clk = ~clk;

    // Check the received byte
    always @(posedge clk) begin
        if (rx_valid) begin
            if (rx_data == 8'hA5) begin
                $display("PASS: UART loopback received 0x%02h", rx_data);
                received = received + 1;
            end else begin
                $display("FAIL: Expected 0xA5, received 0x%02h", rx_data);
                $fatal(1);
            end
        end
    end

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        repeat (5) @(posedge clk);
        rst = 0;

        // Start transmitting one byte
        @(negedge clk);
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;

        // Wait for the complete UART frame
        wait (received == 1);

        $display("PASS: UART loopback test completed.");
        $finish;
    end

    initial begin
        #5000;
        $display("FAIL: Test timed out.");
        $fatal(1);
    end

endmodule
