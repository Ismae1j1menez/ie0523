module tester(
	output reg CLK,
	output reg START,
	output reg VEL,
	output reg RESET,
	
	input wire LUZ_ROJA,
	input wire LUZ_VERDE,
	input wire LUZ_AMARILLA 
);

initial begin
 CLK = 0;
 VEL = 0;
 START = 0;
 RESET = 1;
 
 #10;
 RESET = 0;
 
 #10;
 START = 1;
 
 #250;
 RESET = 1;
 
 #10;
 RESET = 0;
 START = 1;
 VEL =   1;
 #250;

$finish;
end

always begin                                    
        #5 CLK = !CLK;                              
end

endmodule

