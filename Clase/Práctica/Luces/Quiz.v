module quiz (
	input CLK,
	input START,
	input VEL,
	input RESET,
	output reg LUZ_ROJA,
	output reg LUZ_VERDE,
	output reg LUZ_AMARILLA 
);
reg  [2:0] ESTADO_ACTUAL, ESTADO_ACTUAL_SIGUIENTE;
reg  [4:0]CUENTA_ACTUAL, CUENTA_ACTUAL_SIGUIENTE;

localparam E_INICIAL = 3'b000;
localparam E_LENTO = 3'b001;
localparam E_RAPIDO = 3'b010;
localparam E_FINAL = 3'b100;

always @(posedge CLK) begin
 	if(RESET) begin
 	 ESTADO_ACTUAL <= E_INICIAL;
 	 CUENTA_ACTUAL <= 0;
 	end else begin
 	 ESTADO_ACTUAL <= ESTADO_ACTUAL_SIGUIENTE;
 	 CUENTA_ACTUAL <= CUENTA_ACTUAL_SIGUIENTE;
 	end
end
 
always @(*) begin
  CUENTA_ACTUAL_SIGUIENTE = CUENTA_ACTUAL;
  ESTADO_ACTUAL_SIGUIENTE = ESTADO_ACTUAL;
  LUZ_ROJA = 0;
  LUZ_AMARILLA = 0;
  LUZ_VERDE = 0;
  
  case(ESTADO_ACTUAL)
  	E_INICIAL: begin
  	LUZ_ROJA = 1;
  	CUENTA_ACTUAL_SIGUIENTE = 0;
  	if(START) begin
  		if(VEL == 0)begin
  		ESTADO_ACTUAL_SIGUIENTE = E_LENTO;
  		end else begin
  		ESTADO_ACTUAL_SIGUIENTE = E_RAPIDO;
  		end
  	end
  	end 
  	E_LENTO:begin
  	LUZ_AMARILLA = 1;
  	if(CUENTA_ACTUAL == 20) begin
  		ESTADO_ACTUAL_SIGUIENTE = E_FINAL;
  	end else begin
  		ESTADO_ACTUAL_SIGUIENTE = E_LENTO;
  	end
  	CUENTA_ACTUAL_SIGUIENTE = CUENTA_ACTUAL + 1;
  	end 
  	E_RAPIDO: begin
  	LUZ_VERDE = 1;
  	if(CUENTA_ACTUAL == 10) begin
  		ESTADO_ACTUAL_SIGUIENTE = E_FINAL;
  	end else begin
  		ESTADO_ACTUAL_SIGUIENTE = E_RAPIDO;
  	end
  	CUENTA_ACTUAL_SIGUIENTE = CUENTA_ACTUAL + 1;
  	end 
  	E_FINAL: begin
  	LUZ_ROJA = 1;
	LUZ_AMARILLA = 1;
  	LUZ_VERDE = 1;
  	end 
    endcase
end
endmodule