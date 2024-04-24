module Controlador_banco_Tester(
    output reg CLK,
    output reg Reset,
    output reg Tarjeta_recibida,
    output reg [15:0] Pin,
    output reg [3:0] Digito,
    output reg D_stb,
    output reg Transaccion_tipo,
    output reg [31:0] Monto,
    output reg M_stb,
    input wire Balance_actualizado,
    input wire Entregar_plata,
    input wire Sin_fondos,
    input wire Pin_incorrecto,
    input wire Advertencia,
    input wire Bloqueo
);

// Secuencia de pruebas
initial begin
    // Inicialización
    CLK = 0;
    Reset = 1;
    Pin = 16'h8551;
    Tarjeta_recibida = 0; 
    D_stb = 0;
    M_stb = 0;
    Transaccion_tipo = 0;
    #2 Reset = 0;

    // Caso 1: Inserción de tarjeta y Pin incorrecto una vez
    #2 Tarjeta_recibida = 1;
    #4 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b1111; D_stb = 1; #2 D_stb = 0;
    #2;


    // Caso 2: Inserción de tarjeta y Pin incorrecto dos veces (advertencia)
    #4 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b1111; D_stb = 1; #2 D_stb = 0;
    #2;

    // Caso 3: Inserción de tarjeta y Pin incorrecto tres veces (bloqueo)
    #4 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b1111; D_stb = 1; #2 D_stb = 0;
    #2;
    #28;

    // Caso 4: Depósito exitoso con Pin correcto
    #2  Reset = 1;
    #2  Reset = 0;
    Tarjeta_recibida = 1;
    #2 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0001; D_stb = 1; #2 D_stb = 0;
    #2 Transaccion_tipo = 1;
    #4 Monto = 32'hAAA0; M_stb = 1; #2 M_stb = 0;
    #3;
    #10;
    Tarjeta_recibida = 0;
    #10;
    
    // Caso 5: Retiro exitoso con Pin correcto
    Tarjeta_recibida = 1;
    #4 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0001; D_stb = 1; #2 D_stb = 0;
    #2 Transaccion_tipo = 0;
    #4 Monto = 32'h0000_0080; M_stb = 1; #2 M_stb = 0;
    #3;
    #10;
    Tarjeta_recibida = 0;
    #10;
    

    // Caso 6: Retiro con fondos insuficientes con Pin correcto
    Tarjeta_recibida = 1;
    #4 Digito = 4'b1000;  D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0101; D_stb = 1; #2 D_stb = 0;
    #2 Digito = 4'b0001; D_stb = 1; #2 D_stb = 0;
    #2 Transaccion_tipo = 0;
    #4 Monto = 32'hFFFF_FFFF; 
    #2 M_stb = 1; #2 M_stb = 0; 
    #3;
    #10;
    Tarjeta_recibida = 0;
    #10;
    

    // Caso 7: Reset del sistema
    Reset = 1;
    #10 Reset = 0; Tarjeta_recibida = 0;
    #20;
    
    // Fin del Testbench
    #50 $finish;
end



always begin
    #1 CLK = !CLK;
end

endmodule
