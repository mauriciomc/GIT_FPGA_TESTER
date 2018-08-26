//////////////////////////////////////////////////////////////////////////////////
// Company: CEITEC-SA
// Engineer: Lauro Puricelli
// 
// Create Date:    10:36:32 10/09/2013 
// Design Name: 
// Module Name:    K_COUNTER
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module k_counter(clk, rst, counter_ammount_i, end_test_flag);

/*parameter DATA_WIDTH = 8;
parameter NUMBER_OF_COMBINATIONS = 9'b100000000;
parameter HALF_COMBINATIONS      = 12'b010000000;*/

parameter DATA_WIDTH = 6;
parameter NUMBER_OF_COMBINATIONS = 7'b1000000;
parameter HALF_COMBINATIONS     = 7'b0100000;

input clk;
input rst;

output reg end_test_flag;
output reg [DATA_WIDTH-1:0] counter_ammount_i;		//counter K.

reg dff_reset_i;
reg [DATA_WIDTH-1:0] add_2_n;
reg [DATA_WIDTH-1:0] div_n;
reg [DATA_WIDTH : 0] counter; //9 bits
reg [DATA_WIDTH-1:0] prev_counter_ammount_i;	//register the previous value of K
reg error_sync;
reg error_bist;
reg age_test;
reg [6:0] state;


reg diag_mode;
reg [3:0] block_number;

reg [2:0] state_rst;


	reg [2:0] state_error;	

	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			counter_ammount_i <= 0;
			counter <= 0;
			add_2_n <= 0;
			state <= 0;			
			block_number <= 4'hF;			
			end_test_flag <= 0;
		end
		else begin
			state <= state;
			case (state)				
				0: begin
					counter_ammount_i <= 0;
					counter <= 0;					
					state <= state + 1;
				end
				1: begin
					age_test <= 0;		//caso se deseje fazer teste de aging, "age_test <= 1"	
					counter_ammount_i <= counter_ammount_i + 1;
					counter <= counter + 1;
					state <= state + 1;				
				end
				2: begin									
					if (counter_ammount_i == 0) begin	//fim da sequencia de teste sncrono
						state <= state + 10;		
					end
					else begin						
						counter <= counter + 1;
						if (counter_ammount_i % 2 == 0) begin	//somador par
							state <= state + 2;											
						end
						else begin					
							state <= state  + 1;
						end
					end
				end									
				3: begin							
					if (counter == 7'b100_0000) begin
						state <= state - 1;
						counter_ammount_i <= counter_ammount_i + 1;
						counter <= 0;						 
					end
					else begin					
						state <= state;
						counter_ammount_i <= counter_ammount_i;
						counter <= counter + 1;					
					end
				end
				4: begin					
					counter <= counter + 1;
					prev_counter_ammount_i <= counter_ammount_i;
					if(counter_ammount_i % 128 == 0) begin
						state <= state + 1;
						div_n <= 128;
					end
					else 
						if(counter_ammount_i % 64 == 0) begin
							state <= state + 1;						
							div_n <= 64;
						end
					else 
						if(counter_ammount_i % 32 == 0) begin
							state <= state + 1;
							div_n <= 32;					
						end
					else
						if(counter_ammount_i % 16 == 0) begin
							state <= state + 1;
							div_n <= 16;					
						end
					else
						if(counter_ammount_i % 8 == 0) begin
							state <= state + 1;
							div_n <= 8;						
						end
					else
						if(counter_ammount_i % 4 == 0) begin
							state <= state + 1;
							div_n <= 4;					
						end					
					else begin						
						state <= state + 5;
					end	
				end
				5: begin					
					if(counter * div_n == NUMBER_OF_COMBINATIONS) begin
						counter_ammount_i <= prev_counter_ammount_i;
						state <= state + 1;
						add_2_n <= add_2_n + 1;
						counter <= 0;
					end
					else begin
						state <= state;
						counter_ammount_i <= prev_counter_ammount_i;
						counter <= counter + 1;
						add_2_n <= add_2_n;
					end
				end
				6: begin					
					counter <= counter + 1;					
					if(add_2_n == div_n) begin
						state <= state - 5;
						counter_ammount_i <= prev_counter_ammount_i;
						counter <= 0;
						add_2_n <= 0;						
					end
					else begin
						counter_ammount_i <= add_2_n;				
						state <= 5;//state - 1;
						add_2_n <= add_2_n;		
					end	
				end
				7: begin					
				end
				8: begin
				end
				9: begin	//pares "primos"
					counter <= counter + 1;
					if(counter == HALF_COMBINATIONS - 1) begin	//a saida do somador tem o valor 0.
						state <= state + 1;
						counter_ammount_i <= 1;
					end
					else begin	
						state <= state;
					end
				end
				10: begin
					counter_ammount_i <= prev_counter_ammount_i;
					counter <= counter + 1;
					state <= state + 1;					
				end
				11: begin
					if (counter == 7'b1000000) begin
						state <= 1;
						counter <= 7'b0000000;
					end
					else begin
						state <= state;
						counter <= counter + 1;					
					end
				end
				12: begin	//estado final do teste sincrono. ver leds.					
					counter <= 0;					
					state <= state;
					end_test_flag <= 1;
				end			
				
				default: begin
					state <= 0;
				end		
			endcase
		end
	end		
endmodule
