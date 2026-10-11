`timescale 1ns/1ps

module tb_uart_loopback;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire [7:0] rx_data;
    wire rx_valid;
    wire tx_busy;
    wire serial_line;

    reg [7:0] test_bytes [0:4];
    integer i;
    integer received = 0;

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

    always @(posedge clk) begin
        if (!rst && rx_valid) begin
            if (received >= 5) begin
                $display("FAIL: Unexpected extra received byte");
                $fatal(1);
            end

            if (rx_data !== test_bytes[received]) begin
                $display("FAIL: Test %0d expected 0x%02h, got 0x%02h",
                         received, test_bytes[received], rx_data);
                $fatal(1);
            end

            $display("PASS: Test %0d received 0x%02h",
                     received, rx_data);
            received = received + 1;
        end
    end

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        test_bytes[0] = 8'hA5;
        test_bytes[1] = 8'h00;
        test_bytes[2] = 8'hFF;
        test_bytes[3] = 8'h55;
        test_bytes[4] = 8'hC3;

        repeat (5) @(negedge clk);
        rst = 0;

        for (i = 0; i < 5; i = i + 1) begin
            // Wait until the transmitter is idle.
            wait (tx_busy == 0);
            @(negedge clk);

            tx_data = test_bytes[i];
            tx_start = 1;

            @(negedge clk);
            tx_start = 0;

            // Allow this frame to finish before starting another.
            wait (received == i + 1);
            @(negedge clk);
        end

        if (received != 5) begin
            $display("FAIL: Expected 5 bytes, received %0d", received);
            $fatal(1);
        end

        $display("PASS: All 5 UART loopback tests completed.");
        $finish;
    end

    initial begin
        #20000;
        $display("FAIL: Test timed out; received %0d of 5 bytes", received);
        $fatal(1);
    end

endmodule
