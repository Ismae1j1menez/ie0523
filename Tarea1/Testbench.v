//ISMAEL JIMENEZ CARBALLO
//B94009
//Tarea #1, contador de 16 bits

`include "Tester.v"
`include "Contador16b.v"
module techbench;

    wire CLK;
    wire ENB;  
    wire [1:0] MODO;  
    wire [15:0] D; 
    wire [15:0] Q; 
    wire RCO;
    wire Paridad;

    initial begin
        $display("time\t CLK\t ENB\t MODO\t D\t Q\t RCO\t Paridad");
        $monitor("%d\t %b\t %b\t %b\t %h\t %h\t %b\t %b", $time, CLK, ENB, MODO, D, Q, RCO, Paridad);

        $dumpfile("ondas.vcd");
        $dumpvars(-1, ct16b);
    end

    contador_de16_bits ct16b ( 
        .CLK(CLK), 
        .ENB(ENB), 
        .MODO(MODO), 
        .D(D), 
        .Q(Q), 
        .RCO(RCO), 
        .Paridad(Paridad)
    );

        parte_probador Pr (
        .CLK(CLK),
        .ENB(ENB),
        .MODO(MODO),
        .D(D),
        .Q(Q),
        .RCO(RCO),
        .Paridad(Paridad)
    );
endmodule









