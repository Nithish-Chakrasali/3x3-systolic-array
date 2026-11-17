
module systolic_array_3x3 (

    input wire clk,
    input wire rst,
    input wire clear,

    // Three horizontal A inputs
    input wire signed [7:0] a_in [0:2],

    // Three vertical B inputs
    input wire signed [7:0] b_in [0:2],

    // Valid signals for A and B
    input wire a_valid_in [0:2],
    input wire b_valid_in [0:2],

    // Nine accumulated results
    output wire signed [31:0] c_out [0:2][0:2]

);

    // ------------------------------------------------
    // 1. Internal communication buses
    // ------------------------------------------------

    wire signed [7:0] a_bus [0:2][0:3];
    wire signed [7:0] b_bus [0:3][0:2];

    wire a_valid_bus [0:2][0:3];
    wire b_valid_bus [0:3][0:2];


    // ------------------------------------------------
    // 2. Connect external inputs to boundary buses
    // ------------------------------------------------

    genvar i, j;

    generate

        for (i = 0; i < 3; i = i + 1) begin : INPUT_A

            assign a_bus[i][0] = a_in[i];

            assign a_valid_bus[i][0] = a_valid_in[i];

        end

        for (j = 0; j < 3; j = j + 1) begin : INPUT_B

            assign b_bus[0][j] = b_in[j];

            assign b_valid_bus[0][j] = b_valid_in[j];

        end

    endgenerate


    // ------------------------------------------------
    // 3. Instantiate 9 Processing Elements
    // ------------------------------------------------

    generate

        for (i = 0; i < 3; i = i + 1) begin : ROW

            for (j = 0; j < 3; j = j + 1) begin : COL

                processing_element PE (

                    .clk(clk),
                    .rst(rst),
                    .clear(clear),

                    // A moves horizontally
                    .a_in(a_bus[i][j]),
                    .a_out(a_bus[i][j+1]),

                    .a_valid_in(a_valid_bus[i][j]),
                    .a_valid_out(a_valid_bus[i][j+1]),


                    // B moves vertically
                    .b_in(b_bus[i][j]),
                    .b_out(b_bus[i+1][j]),

                    .b_valid_in(b_valid_bus[i][j]),
                    .b_valid_out(b_valid_bus[i+1][j]),


                    // Local accumulation
                    .acc(c_out[i][j])

                );

            end

        end

    endgenerate

endmodule
