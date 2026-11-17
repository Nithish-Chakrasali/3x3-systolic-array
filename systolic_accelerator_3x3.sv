
module systolic_accelerator_3x3 (

    input wire clk,
    input wire rst,
    input wire start,

    input wire signed [7:0] A [0:2][0:2],
    input wire signed [7:0] B [0:2][0:2],

    output wire signed [31:0] C [0:2][0:2],

    output reg busy,
    output reg done

);

    // Scheduler outputs
    wire signed [7:0] a_stream [0:2];
    wire signed [7:0] b_stream [0:2];

    wire a_valid [0:2];
    wire b_valid [0:2];

    wire scheduler_busy;
    wire scheduler_done;

    // Array accumulator clear
    wire clear_acc;

    // Completion tracking
    reg draining;
    reg [1:0] drain_count;

    // Clear accumulators when a new operation starts
    assign clear_acc = start && !busy;

    // ---------------------------------
    // INPUT SCHEDULER
    // ---------------------------------

    input_scheduler_3x3 SCHEDULER (

        .clk(clk),
        .rst(rst),
        .start(start && !busy),

        .A(A),
        .B(B),

        .a_out(a_stream),
        .b_out(b_stream),

        .a_valid(a_valid),
        .b_valid(b_valid),

        .busy(scheduler_busy),
        .done(scheduler_done)

    );

    // ---------------------------------
    // 3x3 SYSTOLIC ARRAY
    // ---------------------------------

    systolic_array_3x3 ARRAY (

        .clk(clk),
        .rst(rst),
        .clear(clear_acc),

        .a_in(a_stream),
        .b_in(b_stream),

        .a_valid_in(a_valid),
        .b_valid_in(b_valid),

        .c_out(C)

    );

    // ---------------------------------
    // BUSY AND DONE CONTROL
    // ---------------------------------

    always @(posedge clk) begin

        if (rst) begin

            busy <= 0;
            done <= 0;

            draining <= 0;
            drain_count <= 0;

        end

        else begin

            done <= 0;

            // A new operation has started
            if (start && !busy)
                busy <= 1;

            // Scheduler has finished feeding inputs
            if (scheduler_done) begin

                draining <= 1;
                drain_count <= 0;

            end

            // Allow remaining operands to propagate
            else if (draining) begin

                if (drain_count == 2) begin

                    draining <= 0;
                    drain_count <= 0;

                    busy <= 0;
                    done <= 1;

                end

                else begin

                    drain_count <= drain_count + 1;

                end

            end

        end

    end

endmodule
