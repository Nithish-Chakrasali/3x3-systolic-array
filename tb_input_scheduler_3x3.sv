
module tb_input_scheduler_3x3;

    reg clk;
    reg rst;
    reg start;

    reg signed [7:0] A [0:2][0:2];
    reg signed [7:0] B [0:2][0:2];

    wire signed [7:0] a_out [0:2];
    wire signed [7:0] b_out [0:2];

    wire a_valid [0:2];
    wire b_valid [0:2];

    wire busy;
    wire done;

    integer cycle;
    integer i;

    // Instantiate scheduler
    input_scheduler_3x3 DUT (
        .clk(clk),
        .rst(rst),
        .start(start),

        .A(A),
        .B(B),

        .a_out(a_out),
        .b_out(b_out),

        .a_valid(a_valid),
        .b_valid(b_valid),

        .busy(busy),
        .done(done)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        start = 0;

        // Initialize matrix A
        A[0][0] = 1; A[0][1] = 2; A[0][2] = 3;
        A[1][0] = 4; A[1][1] = 5; A[1][2] = 6;
        A[2][0] = 7; A[2][1] = 8; A[2][2] = 9;

        // Initialize matrix B
        B[0][0] = 9; B[0][1] = 8; B[0][2] = 7;
        B[1][0] = 6; B[1][1] = 5; B[1][2] = 4;
        B[2][0] = 3; B[2][1] = 2; B[2][2] = 1;

        // Apply reset
        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // Start scheduler
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        $display("\n===== SCHEDULER VERIFICATION =====");

        // Check all five input-feeding cycles
        for (cycle = 0; cycle < 5; cycle = cycle + 1) begin

            @(posedge clk);
            #1;

            $display("\nCycle %0d", cycle);

            for (i = 0; i < 3; i = i + 1) begin

                // Check A row
                if ((cycle >= i) && (cycle < i + 3)) begin

                    if (a_valid[i] !== 1'b1 ||
                        a_out[i] !== A[i][cycle-i]) begin

                        $fatal(1,
                            "FAIL: A row %0d at cycle %0d",
                            i, cycle);
                    end

                    $display("PASS: A row %0d = %0d",
                             i, a_out[i]);

                end
                else begin

                    if (a_valid[i] !== 1'b0)
                        $fatal(1,
                            "FAIL: A valid row %0d at cycle %0d",
                            i, cycle);

                end

                // Check B column
                if ((cycle >= i) && (cycle < i + 3)) begin

                    if (b_valid[i] !== 1'b1 ||
                        b_out[i] !== B[cycle-i][i]) begin

                        $fatal(1,
                            "FAIL: B column %0d at cycle %0d",
                            i, cycle);
                    end

                    $display("PASS: B column %0d = %0d",
                             i, b_out[i]);

                end
                else begin

                    if (b_valid[i] !== 1'b0)
                        $fatal(1,
                            "FAIL: B valid column %0d at cycle %0d",
                            i, cycle);

                end

            end

            // Check busy and done
            if (cycle < 4) begin
                if (busy !== 1'b1 || done !== 1'b0)
                    $fatal(1, "FAIL: Busy/done at cycle %0d", cycle);
            end
            else begin
                if (busy !== 1'b0 || done !== 1'b1)
                    $fatal(1, "FAIL: Completion signal");
            end

        end

        // Check outputs become invalid after completion
        @(posedge clk);
        #1;

        for (i = 0; i < 3; i = i + 1) begin
            if (a_valid[i] !== 1'b0 || b_valid[i] !== 1'b0)
                $fatal(1, "FAIL: Valid signals did not clear");
        end

        if (done !== 1'b0 || busy !== 1'b0)
            $fatal(1, "FAIL: Done/busy did not return to idle");

        $display("\n================================");
        $display(" ALL SCHEDULER TESTS PASSED!");
        $display("================================");

        $finish;

    end

endmodule
