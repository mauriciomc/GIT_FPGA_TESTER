`timescale 1ns/1ns
module address_decoder ( address,
                         displayUnidade,
							    displayDezena,
							    displayCentena,
							    displayMilhar,
								 reset );



input [14:0] address;
input reset;
output [6:0] displayUnidade;
output [6:0] displayDezena;
output [6:0] displayCentena;
output [6:0] displayMilhar;

wire [14:0] address;
wire [6:0] displayUnidade;
wire [6:0] displayDezena;
wire [6:0] displayCentena;
wire [6:0] displayMilhar;

reg done;
integer counter;

integer nmilhar;
integer ncentena;
integer ndezena;
integer nunidade;

reg [3:0] decod;
reg [3:0] unidade;
reg [3:0] dezena;
reg [3:0] centena;
reg [3:0] milhar;

wire [3:0] unit;
wire [3:0] tens;
wire [3:0] hund;
wire [3:0] thou;

wire [12:0] rmilhar;
wire [12:0] rcentena;
wire [12:0] rdezena;


//assign rmilhar  =  address-dezena*10-unit-centena*100;
//assign rcentena =  address-milhar*1000-dezena*10-unit;
//assign rdezena  =  address-milhar*1000-centena*100-unit;

assign unit = unidade;
assign tens = dezena;//rdezena [4:0];     //dezena;//((address-milhar*1000-centena*100-unidade)/10)[4:0];
assign hund = centena;//rcentena [4:0];       //centena;//((address-milhar*1000- unidade- dezena*10)/100)[4:0];
assign thou = milhar;//rmilhar [4:0];       //milhar;//((address-centena*100-dezena*10-unidade)/1000)[4:0];

display_decoder decodUnidade (.data (unit),
								      .display_data (displayUnidade));
								
display_decoder decodDezena (.data (tens),
								     .display_data (displayDezena));
								

display_decoder decodCentena (.data (hund),
								      .display_data (displayCentena));

display_decoder decodMilhar ( .data (thou),
										.display_data (displayMilhar));						

										
//assign rmilhar =	address-1000 > 0 ? (address - 2000 > 0: 									
										
			
always @ (address)
begin
	nmilhar=0;
	ncentena=0;
	ndezena=0;
	nunidade=0;
	
	nmilhar=address/1000;
	ncentena=(address-(nmilhar*1000))/100;
	ndezena=(address-(nmilhar*1000)-(ncentena*100))/10;
	nunidade=(address-(nmilhar*1000)-(ncentena*100)-(ndezena*10));
	
	milhar<=nmilhar[3:0];	
	centena<=ncentena[3:0];
	dezena<=ndezena[3:0];
	unidade<=nunidade[3:0];
	
end


endmodule