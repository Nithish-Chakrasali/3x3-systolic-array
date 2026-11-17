
module tb_systolic_accelerator_3x3;

    reg clk;
    reg rst;
    reg start;

    reg signed [7:0] A [0:2][0:2];
    reg signed [7:0] B [0:2][0:2];

    wire signed [31:0] C [0:2][0:2];

    wire busy;
    wire done;

    reg signed [31:0] expected [0:2][0:2];

    integer i, j;
    integer timeout;

    // DUT
    systolic_accelerator_3x3 DUT (

        .clk(clk),
        .rst(rst),
        .start(start),

        .A(A),
        .B(B),

        .C(C),

        .busy(busy),
        .done(done)

    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        start = 0;

        // Matrix A
        A[0][0] = 1; A[0][1] = 2; A[0][2] = 3;
        A[1][0] = 4; A[1][1] = 5; A[1][2] = 6;
        A[2][0] = 7; A[2][1] = 8; A[2][2] = 9;

        // Matrix B
        B[0][0] = 9; B[0][1] = 8; B[0][2] = 7;
        B[1][0] = 6; B[1][1] = 5; B[1][2] = 4;
        B[2][0] = 3; B[2][1] = 2; B[2][2] = 1;

        // Expected matrix C
        expected[0][0] = 30;
        expected[0][1] = 24;
        expected[0][2] = 18;

        expected[1][0] = 84;
        expected[1][1] = 69;
        expected[1][2] = 54;

        expected[2][0] = 138;
        expected[2][1] = 114;
        expected[2][2] = 90;

        // Reset
        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // Start matrix multiplication
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        $display("\n=================================");
        $display("  3x3 SYSTOLIC ACCELERATOR TEST");
        $display("=================================");

        // Wait for complete operation
        timeout = 0;

        while (done !== 1'b1 && timeout < 20) begin
            @(posedge clk);
            #1;
            timeout = timeout + 1;
        end

        if (done !== 1'b1)
            $fatal(1, "FAIL: Accelerator timeout!");

        $display("\nAccelerator completed successfully!");

        // Display result matrix
        $display("\nOutput Matrix C:");

        for (i = 0; i < 3; i = i + 1) begin

            for (j = 0; j < 3; j = j + 1) begin
                $write("%0d\t", C[i][j]);
            end

            $display("");

        end

        // Verify all nine outputs
        $display("\nVerification:");

        for (i = 0; i < 3; i = i + 1) begin

            for (j = 0; j < 3; j = j + 1) begin

                if (C[i][j] !== expected[i][j]) begin

                    $display(
                        "FAIL: C[%0d][%0d] Expected=%0d Actual=%0d",
                        i, j, expected[i][j], C[i][j]
                    );

                    $fatal(1, "Matrix multiplication failed!");

                end

                else begin

                    $display(
                        "PASS: C[%0d][%0d] = %0d",
                        i, j, C[i][j]
                    );

                end

            end

        end

        if (busy !== 1'b0)
            $fatal(1, "FAIL: Busy should be low after completion");

        $display("\n=================================");
        $display(" ALL ACCELERATOR TESTS PASSED!");
        $display("=================================");

        $finish;

    end

endmodule
