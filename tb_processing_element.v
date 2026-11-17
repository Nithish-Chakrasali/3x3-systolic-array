
`timescale 1ns/1ps

module tb_processing_element;

    reg clk;
    reg rst;
    reg clear;

    reg signed [7:0] a_in;
    reg signed [7:0] b_in;

    reg a_valid_in;
    reg b_valid_in;

    wire a_valid_out;
    wire b_valid_out;

    wire signed [7:0] a_out;
    wire signed [7:0] b_out;

    wire signed [31:0] acc;

    // DUT instantiation
    processing_element dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),

        .a_in(a_in),
        .b_in(b_in),

        .a_valid_in(a_valid_in),
        .b_valid_in(b_valid_in),

        .a_valid_out(a_valid_out),
        .b_valid_out(b_valid_out),

        .a_out(a_out),
        .b_out(b_out),

        .acc(acc)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check accumulator
    task check_acc;
        input signed [31:0] expected;
        begin
            if (acc !== expected) begin
                $display("FAIL: Time=%0t Expected ACC=%0d, Actual ACC=%0d",
                         $time, expected, acc);
                $fatal(1);
            end
            else begin
                $display("PASS: Time=%0t ACC=%0d",
                         $time, acc);
            end
        end
    endtask

    // Task to apply inputs and sample after clock edge
    task apply_test;
        input signed [7:0] a;
        input signed [7:0] b;
        input av;
        input bv;
        input clr;
        input signed [31:0] expected_acc;

        begin
            @(negedge clk);

            a_in = a;
            b_in = b;

            a_valid_in = av;
            b_valid_in = bv;
            clear = clr;

            @(posedge clk);
            #1;

            check_acc(expected_acc);

            // Check forwarding
            if (a_out !== a || b_out !== b) begin
                $display("FAIL: Data forwarding error");
                $fatal(1);
            end

            if (a_valid_out !== av || b_valid_out !== bv) begin
                $display("FAIL: Valid forwarding error");
                $fatal(1);
            end

            $display("PASS: Forwarding A=%0d B=%0d AV=%b BV=%b",
                     a_out, b_out, a_valid_out, b_valid_out);
        end
    endtask

    initial begin

        // Initialize inputs
        rst = 1;
        clear = 0;

        a_in = 0;
        b_in = 0;

        a_valid_in = 0;
        b_valid_in = 0;

        $dumpfile("pe_waveform.vcd");
        $dumpvars(0, tb_processing_element);

        // TEST 1: Reset
        @(posedge clk);
        #1;

        check_acc(0);

        if (a_out !== 0 || b_out !== 0 ||
            a_valid_out !== 0 || b_valid_out !== 0)
            $fatal(1, "FAIL: Reset error");

        $display("TEST 1: Reset PASSED");

        // Release reset
        @(negedge clk);
        rst = 0;

        // TEST 2: Positive multiplication
        // ACC = 0 + (3 * 4) = 12
        apply_test(3, 4, 1, 1, 0, 12);

        // TEST 3: Negative multiplication
        // ACC = 12 + (-3 * 4) = 0
        apply_test(-3, 4, 1, 1, 0, 0);

        // TEST 4: Clear accumulator
        // ACC = 0 regardless of multiplication
        apply_test(5, -2, 1, 1, 1, 0);

        // TEST 5: B invalid
        // ACC remains 0
        apply_test(7, 3, 1, 0, 0, 0);

        // TEST 6: A invalid
        // ACC remains 0
        apply_test(7, 3, 0, 1, 0, 0);

        // TEST 7: Both valid
        // ACC = 0 + (2 * 6) = 12
        apply_test(2, 6, 1, 1, 0, 12);

        // TEST 8: Accumulator hold
        // Neither operand valid
        // ACC remains 12
        apply_test(8, 9, 0, 0, 0, 12);

        // TEST 9: Maximum positive multiplication
        // ACC = 12 + (127 * 127) = 16141
        apply_test(127, 127, 1, 1, 0, 16141);

        // TEST 10: Minimum signed multiplication
        // First clear, then calculate (-128 * -128)
        apply_test(0, 0, 0, 0, 1, 0);
        apply_test(-128, -128, 1, 1, 0, 16384);

        $display("--------------------------------");
        $display("ALL TESTS PASSED SUCCESSFULLY!");
        $display("--------------------------------");

        #10;
        $finish;

    end

endmodule
