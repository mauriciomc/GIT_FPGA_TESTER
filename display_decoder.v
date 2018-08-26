`timescale 1ns/1ns
module display_decoder ( data,
                         display_data );


input [3: 0] data;
output [6:0] display_data ;

wire [3: 0] data;
reg [6: 0] display_data;

always @(data) begin
case (data) 
            //        b'6543210
				'd0 : display_data  =  7'b1000000;
			   'd1 : display_data  =  7'b1111001;
			   'd2 : display_data  =  7'b0100100;
			   'd3 : display_data  =  7'b0110000;
			   'd4 : display_data  =  7'b0011001;
			   'd5 : display_data  =  7'b0010010;
			   'd6 : display_data  =  7'b0000010;
			   'd7 : display_data  =  7'b1111000;
			   'd8 : display_data  =  7'b0000000;
			   'd9 : display_data  =  7'b0010000;
			
	default: display_data = 7'b0000110;
endcase
end
endmodule