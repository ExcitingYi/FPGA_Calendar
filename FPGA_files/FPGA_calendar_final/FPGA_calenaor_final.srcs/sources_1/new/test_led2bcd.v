`timescale 1ns / 1ps

module test_led2bcd(
    input [6:0]code,
    output [3:0]bcd_code
    );
    reg [3:0] temp_code;
    assign bcd_code = temp_code;
    always @(*) begin
        case(code)
			7'b0111111: temp_code <= 4'b0000;
			7'b0000110: temp_code <= 4'b0001;
			7'b1011011: temp_code <= 4'b0010;
			7'b1001111: temp_code <= 4'b0011;
			7'b1100110: temp_code <= 4'b0100;
			7'b1101101: temp_code <= 4'b0101;
			7'b1111101: temp_code <= 4'b0110;
			7'b0000111: temp_code <= 4'b0111;
			7'b1111111: temp_code <= 4'b1000;
			7'b1101111: temp_code <= 4'b1001;
			default: temp_code <= 4'h0;
		endcase
	end
endmodule
