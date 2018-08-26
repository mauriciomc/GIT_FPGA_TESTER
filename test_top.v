module test_top
(
	clock,
	reset,
	K,
	clock_mux_sel,
	mode_mux_sel,
	bist_decoder_input,
	mux_decoder_input,
	sel_chain_input,
	sel_chain_output,
	chain_input,
	chain_output,
	comparison_result,
	rst_c, 
	error_flag
	//ring_FF,
	//ring_latch
);



input clock;	//FPGA and ASIC
input reset;

//ASIC OUTPUT

input[5:0] chain_input;
input[5:0] chain_output;
input comparison_result;

//ASIC INPUT
output reg rst_c;	//ASIC reset signal
output reg [5:0] K;
output reg clock_mux_sel;
output reg mode_mux_sel;
output reg [2:0] bist_decoder_input;
output reg [4:0] mux_decoder_input;
output reg sel_chain_input;
output reg sel_chain_output;

top_c top_c	//instanciar topo do ASIC para simulação
(
	.clock(clock),
	.reset(rst_c),
	.K(K),
	.clock_mux_sel(clock_mux_sel),
	.mode_mux_sel(mode_mux_sel),
	.bist_decoder_input(bist_decoder_input),
	.mux_decoder_input(mux_decoder_input),
	.sel_chain_input(sel_chain_input),
	.sel_chain_output(sel_chain_output),
	.chain_input(chain_input),
	.chain_output(chain_output),
	.comparison_result(comparison_result),
	.ring_FF(),
	.ring_latch()
);



output reg error_flag;

reg [7:0] fsm_state;
reg [7:0] counter;
wire [5:0] counter_ammount_i;
wire k_counter_clk;
wire k_cnt_enable;
wire end_sync_flag;
reg [5:0] FF_input;

k_counter k_counter(
	  .clk(k_counter_clk),
	  .rst(rst_c),
	  .end_test_flag(end_sync_flag),
	  .counter_ammount_i(counter_ammount_i)
);
  //assign k_counter_clk = clock & k_cnt_enable;
  
  //assign k_cnt_enable = (fsm_state >= 12 && fsm_state <= 15) ? 1 : ((fsm_state > 15) ? comparison_result : 0);

  assign k_counter_clk = (fsm_state >= 12 && fsm_state <= 15) ? clock : ((fsm_state > 15 )? comparison_result:0);

  
  always @ (posedge clock or posedge reset) begin
		if(reset) begin
			/*counter_ammount_i <= 0;
			leds <= 0;*/
			counter <= 0;
			fsm_state <= 0;	
			rst_c <= 1;
			K <= 0;
			clock_mux_sel<= 0;
			mode_mux_sel <= 0;
			bist_decoder_input <= 6;
			mux_decoder_input <= 0;
			sel_chain_input <= 0;
			sel_chain_output <= 1;
			fsm_state <= 0;
			error_flag <= 0;

		end
		else begin
			fsm_state <= fsm_state;
			case (fsm_state)
				0: begin	//	1.2.2 Teste do multiplexador chain_input_mux (1)
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 1;
					bist_decoder_input <= 6;
					mux_decoder_input <= 0;
					sel_chain_input <= 0;
					sel_chain_output <= 0;
					fsm_state <= fsm_state + 1;					
				end
				1: begin
					K <= K + 1;		
					if (chain_input != K) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end					
				end									
				2: begin	//1.2.3 Teste do registrador (FF) com reset igual a 1
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 1;
					bist_decoder_input <= 6;
					mux_decoder_input <= 0;
					sel_chain_input <= 0;
					sel_chain_output <= 1;
					fsm_state <= fsm_state + 1;
				end
				3: begin	
					K <= K + 1;		
					if (chain_output != 0) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end				
				end
				4: begin	//1.2.4 Teste do registrador (FF) com reset igual a 0
					rst_c <= 0;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 1;
					bist_decoder_input <= 6;
					mux_decoder_input <= 0;
					sel_chain_input <= 0;
					sel_chain_output <= 1;
					fsm_state <= fsm_state + 1;

				end
				5: begin
					rst_c <= 0;
					K <= K + 1;
					FF_input <= K;	
					if (chain_output != FF_input) begin //compara o valor de saida do FF com o valor anterior de entrada
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end	
				end
				6: begin	//1.2.5 Teste do somador com reset igual a 1 (modo direto)
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 0;
					bist_decoder_input <= 6;
					mux_decoder_input <= 0;
					sel_chain_input <= 0;
					sel_chain_output <= 1;
					fsm_state <= fsm_state + 1;
				
				end
				7: begin
					K <= K + 1;		
					if (chain_input != K) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin
							sel_chain_input <= 1;
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end	
				end
				8: begin	//1.2.5 Teste do somador com reset igual a 1 (passando pelo multiplexador MODE_MUX)
					K <= K + 1;		
					if (chain_input != K) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin							
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end	
				end				
				9: begin	//1.2.6 Teste do multiplexador chain_output_mux
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 1;
					bist_decoder_input <= 6;
					mux_decoder_input <= 0;
					sel_chain_input <= 1;
					sel_chain_output <= 0;
					fsm_state <= fsm_state + 1;					
				end
				10: begin
					K <= K + 1;		
					if (chain_output != K) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin							
							sel_chain_output <= 1;		//modifica o sinal de selecao do multiplexador output_mux
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end
				end
				11: begin	
					K <= K + 1;							
					if (chain_output != 0) begin 
						error_flag <= 1;
					end
					else begin 
						if (K == 63) begin							
							fsm_state <= fsm_state + 1;
						end
						else begin
							fsm_state <= fsm_state;
						end
					end					
				end
				12: begin	//comeco do modo síncrono e diagnostico. Longo reset com 100 ciclos de clock.
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 0;
					mode_mux_sel <= 0;
					bist_decoder_input <= 6;
					mux_decoder_input <= mux_decoder_input;
					sel_chain_input <= 0;
					sel_chain_output <= 0;					
					if(counter < 100) begin
						fsm_state <= fsm_state;
						counter <= counter + 1;
					end
					else begin
						counter <= 0;
						fsm_state <= fsm_state + 1;
					end
				end
				13: begin
					rst_c <= 0;
					K <= counter_ammount_i;
					if(comparison_result != 1)
						error_flag = 1;					
					if(end_sync_flag == 1) begin
						mux_decoder_input <= mux_decoder_input + 1;
						fsm_state <= fsm_state + 1;
					end
				end				
				14: begin
					if(mux_decoder_input == 21) begin
						fsm_state <= fsm_state + 1;						
					end
					else begin
						fsm_state <= fsm_state - 2;
					end
					 
				end
				15: begin
					fsm_state <= fsm_state + 1;
				end
				16: begin
					rst_c <= 1;
					K <= 0;
					clock_mux_sel<= 1;	//modo assincrono
					mode_mux_sel <= 0;
					bist_decoder_input <= 6;
					mux_decoder_input <= 21;
					sel_chain_input <= 0;
					sel_chain_output <= 0;					
					if(counter < 50) begin
						fsm_state <= fsm_state;
						counter <= counter + 1;
					end
					else begin
						counter <= 0;
						fsm_state <= fsm_state + 1;
						K <= 1;
						rst_c <= 0;	//condicoes para ativar a borda de subida do relogio assincrono
					end
				end
				17: begin
					K <= counter_ammount_i;					
					if(end_sync_flag == 1) begin
						fsm_state <= fsm_state + 1;
					end
				end
				18: begin
					fsm_state <= fsm_state;
				end				
				19: begin
				end
				20: begin
				end
				21: begin
				end
				22: begin
				end
				23: begin
				end				
				24: begin
				end
				default: begin
				end		
			endcase
		end
	end	
endmodule


/*module fpga_top (clk, rst_n, fail);parameter DATA_WIDTH = 8;input clk, rst_n;output reg fail;wire [DATA_WIDTH-1:0] counter_ammount_i, previous_state;wire clk_en;wire comparator_flag;wire [DATA_WIDTH-1:0] chain_input, chain_output;wire end_test, flag_miss, end_sum_test;comparator_8b comparator(chain_input, chain_output, comparator_flag);adder_8b adder(clk, rst_n, chain_output, counter_ammount_i, chain_input);k_counter_main K(clk, rst_n, counter_ammount_i, end_test);CB_TOP combinational_block_top(clk, rst_n, chain_input, chain_output);


//sum_indicator sum(clk, clk_en, rst_n, counter_ammount_i, chain_input, flag_miss, end_sum_test);	always @ (posedge clk or negedge rst_n) begin		if(!rst_n) begin			fail <= 0;					end		else begin			fail <= !comparator_flag | fail;		end	end		assign clk_en = clk & end_test;endmodule 

*/






