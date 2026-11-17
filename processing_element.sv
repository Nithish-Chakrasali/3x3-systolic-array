module processing_element(
    input wire clk,
    input wire rst,
    
    input wire clear,

    input wire signed [7:0] a_in,
    input wire signed [7:0] b_in,

    input wire a_valid_in,
    input wire b_valid_in,

    output reg a_valid_out,
    output reg b_valid_out,

    output reg signed [7:0] a_out,
    output reg signed [7:0] b_out,

    output reg signed [31:0] acc
);

wire signed [15:0] product;

assign product = a_in * b_in;

always @(posedge clk) begin
    if(rst)begin
        a_out <= 8'd0;
        b_out <= 8'd0;
        acc <= 32'd0;
        a_valid_out <= 1'b0;
        b_valid_out <= 1'b0;
    end
    else begin
        a_out <= a_in;
        b_out <= b_in;

        a_valid_out <= a_valid_in;
        b_valid_out <= b_valid_in;

        if (clear) begin
            acc <= 32'd0;
        end
        else if (a_valid_in && b_valid_in) begin
            acc <= acc + {{16{product[15]}},product};
        end
    end
end
endmodule
