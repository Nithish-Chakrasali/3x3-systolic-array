
module input_scheduler_3x3 (

    input wire clk,
    input wire rst,
    input wire start,

    input wire signed [7:0] A [0:2][0:2],
    input wire signed [7:0] B [0:2][0:2],

    output reg signed [7:0] a_out [0:2],
    output reg signed [7:0] b_out [0:2],

    output reg a_valid [0:2],
    output reg b_valid [0:2],

    output reg busy,
    output reg done

);

    integer cycle;
    integer i;

    always @(posedge clk) begin

        if (rst) begin

            cycle <= 0;
            busy <= 0;
            done <= 0;

            for (i = 0; i < 3; i = i + 1) begin
                a_out[i] <= 0;
                b_out[i] <= 0;
                a_valid[i] <= 0;
                b_valid[i] <= 0;
            end

        end

        else begin

            done <= 0;

            // Clear outputs by default every cycle
            for (i = 0; i < 3; i = i + 1) begin
                a_out[i] <= 0;
                b_out[i] <= 0;
                a_valid[i] <= 0;
                b_valid[i] <= 0;
            end

            if (start && !busy) begin

                cycle <= 0;
                busy <= 1;

            end

            else if (busy) begin

                for (i = 0; i < 3; i = i + 1) begin

                    // Feed A row-wise
                    if ((cycle >= i) && (cycle < i + 3)) begin

                        a_out[i] <= A[i][cycle-i];
                        a_valid[i] <= 1;

                    end

                    // Feed B column-wise
                    if ((cycle >= i) && (cycle < i + 3)) begin

                        b_out[i] <= B[cycle-i][i];
                        b_valid[i] <= 1;

                    end

                end

                if (cycle == 4) begin

                    busy <= 0;
                    done <= 1;

                end

                cycle <= cycle + 1;

            end

        end

    end

endmodule
