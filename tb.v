`timescale 1ns/1ns

module tb ;


reg prescaler1;                //entradas
reg prescaler2; 
reg sys_clock; 
reg sys_reset; 
reg [5:0]chain_input;
reg [5:0]chain_output;
reg stop;
reg comparison_result;
wire [5:0]K; 								 //saidas
wire [2:0]bist_decoder_input; 
wire mode_mux_sel; 
wire sel_chain_input; 
wire sel_chain_output; 
wire clock_mux_sel; 
wire clock; 
wire reset; 
wire [4:0]mux_decoder_input; 
wire error_flag;
wire [6:0]dispUnidade; 
wire [6:0]dispDezena; 
wire [6:0]dispCentena; 
wire [6:0]dispMilhar; 
reg [2:0]switchesH;
reg [2:0]switchesL;
reg continua;
					 




initial begin
sys_clock=0;
sys_reset=0; 
#5 sys_reset = 1;
prescaler1=0;
prescaler2=0;
stop=0;
chain_input=0;
chain_output=1;
switchesH=0;
switchesL=0;
continua=1;
end


TOP TOP_c (     .prescaler1(prescaler1),                
					 .prescaler2(prescaler2), 
					 .sys_clock(sys_clock), 
					 .sys_reset(sys_reset), 
					 .chain_input(chain_input),
					 .chain_output(chain_output),
					 .stop(stop),
					 .comparison_result(comparison_result),
					 .K(K), 								 
					 .bist_decoder_input(bist_decoder_input), 
					 .mode_mux_sel(mode_mux_sel), 
					 .sel_chain_input(sel_chain_input), 
					 .sel_chain_output(sel_chain_output), 
					 .clock_mux_sel(clock_mux_sel), 
					 .clock(clock), 
					 .reset(reset), 
					 .mux_decoder_input(mux_decoder_input), 
					 .error_flag(error_flag),
					 .dispUnidade(dispUnidade), 
					 .dispDezena(dispDezena), 
					 .dispCentena(dispCentena), 
					 .dispMilhar(dispMilhar),
					 .switchesH(switchesH),
					 .switchesL(switchesL),
					 .continua(continua));
					 
always begin
		#1 sys_clock <= ~sys_clock;
		
end					 
					 
					 
endmodule