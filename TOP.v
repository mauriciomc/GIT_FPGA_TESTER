//`timescale 1ns/1ns
module TOP ( prescaler1,                //entradas
					prescaler2, 
					sys_clock, 
					sys_reset, 
					chain_input,
					chain_output,
					stop,
					comparison_result,
					K, 								//saidas
					bist_decoder_input, 
					mode_mux_sel, 
					sel_chain_input, 
					sel_chain_output, 
					clock_mux_sel, 
					clock, 
					reset, 
					mux_decoder_input, 
					error_flag,
					dispUnidade, 
					dispDezena, 
					dispCentena, 
					dispMilhar,
					switchesH,
					switchesL,
					continua);

//parameter PERIOD = 100;
//parameter COUNTER_COMPARISON = 100000000;

input sys_clock;
input sys_reset;
input stop;
input prescaler1;
input prescaler2;
input comparison_result;
input [5:0]chain_input;
input [5:0]chain_output;
input [2:0]switchesH;
input [2:0]switchesL;
input continua;


output reg error_flag;
output [6:0]dispUnidade;
output [6:0]dispDezena;
output [6:0]dispCentena;
output [6:0]dispMilhar;


output reg [5:0]K;
output reg [2:0]bist_decoder_input;
output reg mode_mux_sel;
output reg clock_mux_sel;
output reg sel_chain_input;
output reg sel_chain_output;
output reg [4:0]mux_decoder_input;
output reg clock;
output reg reset;


reg test_clock;

wire [6:0]dispUnidade;
wire [6:0]dispDezena;
wire [6:0]dispCentena;
wire [6:0]dispMilhar;
wire prescaler1;
wire prescaler2;
wire [2:0]switchesH;
wire [2:0]switchesL;


wire sys_clock;
wire sys_reset;
wire stop;
wire [5:0]chain_input;
wire [5:0]chain_output;
wire [14:0] mux_decoder_input_ext;

reg [14:0] alto;
reg [14:0] baixo;


reg test_ok;
reg test_nok;

wire [14:0]display;

reg [31:0]real_counter;
reg [7:0] fsm_state;


integer reset_counter;
integer clock_counter;
integer counter;
reg [7:0] errors;

always @(posedge sys_clock)
begin
	real_counter = (prescaler1? 20000 : 50000) + (prescaler2 ? 10000 : 50000); 	
end

wire [14:0]total_errors;
wire [14:0]total_tests;

reg [14:0]total_errors_reg;
reg [14:0]total_tests_reg;
								 
address_decoder addressDecod (.address(display),
										.displayUnidade(dispUnidade),
										.displayDezena(dispDezena),
										.displayCentena(dispCentena),
										.displayMilhar(dispMilhar),
										.reset(sys_reset));

										
always @ (posedge sys_clock)
begin

case (switchesH)
		0: alto = chain_input;
		1: alto = chain_output;
		2: alto = K;
		3: alto = mux_decoder_input;
		default: alto = mux_decoder_input;

endcase


case (switchesL)
		0: baixo = chain_input;
		1: baixo = chain_output;
		2: baixo = K;
		3: baixo = mux_decoder_input;
		default: baixo = mux_decoder_input;
		

endcase
end


wire [14:0] display_L;
wire [14:0] display_H;

assign display_H = alto*100;
assign display_L = baixo;

assign display = sys_reset==0? 0: display_H + display_L;
										
										
always @(posedge sys_clock)
begin
        if ( sys_reset == 0 ) begin
                 counter = 0;
                 test_clock<=0;
                
        end         
        else
                begin
                counter = counter + 1;
                if (counter > real_counter)
                begin
                        test_clock <= ~test_clock;
                        counter=0;
                end
        end
end


wire continua;


always @(negedge test_clock or negedge sys_reset)
begin
		if(!sys_reset)
			error_flag = 0;
		else
			error_flag = (((chain_output == chain_input) && (chain_input == K)) ? 0 : 1);
end

always @(posedge test_clock or negedge sys_reset)
begin

		if(!sys_reset) begin
			 clock<=0;
			 K<=0;
			 mode_mux_sel<=0;
			 clock_mux_sel<=0;
			 bist_decoder_input<=6;
			 mux_decoder_input <= 0;
			 sel_chain_input <= 0;
			 sel_chain_output <= 0;
			 reset<=1;
			
		end
		else begin
			 reset<=0;
			 K<=K+1;
			 if(K==63) begin
				mux_decoder_input <= mux_decoder_input + 1;
				K<=0;
				if(mux_decoder_input == 21)
					mux_decoder_input<=0;
			 end
		end
end	
endmodule
