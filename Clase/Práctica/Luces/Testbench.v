`include "Tester.v"
`include "Quiz.v"

module testbench;
	
	wire CLK;
	wire START;
	wire VEL;
	wire RESET;
	
	wire LUZ_ROJA;
	wire LUZ_VERDE;
	wire LUZ_AMARILLA; 

    initial begin   
        $dumpfile("quiz.vcd"); // Generador del archivo para que lo lea GTKWave.
        $dumpvars(-1, UUT); //Nombre del modulo UUT
        //$monitor ("Contador (Q) : %b, con RCO: %b y una paridad %b ", Q, RCO, PARIDAD ); // cambiar luego
    end

    quiz UUT(
	.CLK(CLK),
	.START(START),
	.VEL(VEL),
	.RESET(RESET),
	
	.LUZ_ROJA(LUZ_ROJA),
	.LUZ_VERDE(LUZ_VERDE),
	.LUZ_AMARILLA(LUZ_AMARILLA)
    ) ;

    tester BPUUT(
	.CLK(CLK),
	.START(START),
	.VEL(VEL),
	.RESET(RESET),
	
	.LUZ_ROJA(LUZ_ROJA),
	.LUZ_VERDE(LUZ_VERDE),
	.LUZ_AMARILLA(LUZ_AMARILLA)); 
    	
endmodule