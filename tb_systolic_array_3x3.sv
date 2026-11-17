
module tb_systolic_array_3x3;

    reg clk;
    reg rst;
    reg clear;

    reg signed [7:0] a_in [0:2];
    reg signed [7:0] b_in [0:2];

    reg a_valid_in [0:2];
    reg b_valid_in [0:2];

    wire signed [31:0] c_out [0:2][0:2];

    // Instantiate the systolic array
    systolic_array_3x3 DUT (
        .clk(clk),
        .rst(rst),
        .clear(clear),

        .a_in(a_in),
        .b_in(b_in),

        .a_valid_in(a_valid_in),
        .b_valid_in(b_valid_in),

        .c_out(c_out)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Input matrices
    reg signed [7:0] A [0:2][0:2];
    reg signed [7:0] B [0:2][0:2];

    integer cycle;
    integer i, j, k;

    // Expected output
    reg signed [31:0] expected [0:2][0:2];

    initial begin

        clk = 0;
        rst = 1;
        clear = 0;

        // Initialize inputs
        for (i = 0; i < 3; i = i + 1) begin
            a_in[i] = 0;
            b_in[i] = 0;
            a_valid_in[i] = 0;
            b_valid_in[i] = 0;
        end

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

        // Apply reset
        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // Clear all accumulators
        clear = 1;
        @(posedge clk);
        #1;
        clear = 0;

        // Feed skewed operands
        // A[i][k] enters at cycle k+i
        // B[k][j] enters at cycle k+j

        for (cycle = 0; cycle < 7; cycle = cycle + 1) begin

            for (i = 0; i < 3; i = i + 1) begin
                a_in[i] = 0;
                a_valid_in[i] = 0;

                for (k = 0; k < 3; k = k + 1) begin
                    if (cycle == k + i) begin
                        a_in[i] = A[i][k];
                        a_valid_in[i] = 1;
                    end
                end
            end

            for (j = 0; j < 3; j = j + 1) begin
                b_in[j] = 0;
                b_valid_in[j] = 0;

                for (k = 0; k < 3; k = k + 1) begin
                    if (cycle == k + j) begin
                        b_in[j] = B[k][j];
                        b_valid_in[j] = 1;
                    end
                end
            end

            @(posedge clk);
            #1;
        end

        // Wait for the final results
        repeat (2) @(posedge clk);
        #1;

        // Display output matrix
        $display("\n=================================");
        $display("       SYSTOLIC ARRAY OUTPUT");
        $display("=================================");

        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                $write("%0d\t", c_out[i][j]);
            end
            $display("");
        end

        // Verify results
        $display("\n=================================");
        $display("       VERIFICATION");
        $display("=================================");

        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin

                if (c_out[i][j] !== expected[i][j]) begin
                    $display("FAIL: C[%0d][%0d] Expected=%0d Actual=%0d",
                             i, j, expected[i][j], c_out[i][j]);
                end
                else begin
                    $display("PASS: C[%0d][%0d] = %0d",
                             i, j, c_out[i][j]);
                end

            end
        end

        $display("\nSimulation completed!");
        $finish;

    end

endmodule
