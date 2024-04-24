`include "Tester.v"
//`include "Controlador_banco.v"
`include "Banco_synth.v"
`include "cmos_cells.v"
module Testbench_banco(
    input wire CLK,
    input wire Reset,
    input wire Tarjeta_recibida,
    input wire [15:0] Pin,
    input wire [3:0] Digito,
    input wire D_stb,
    input wire Transaccion_tipo,
    input wire [31:0] Monto,
    input wire M_stb,
    input wire Balance_actualizado,
    input wire Entregar_plata,
    input wire Sin_fondos,
    input wire Pin_incorrecto,
    input wire Advertencia,
    input wire Bloqueo
);

    initial begin
        $dumpfile("ondas.vcd");
        $dumpvars; 
    end

        Controlador_banco controlador_banco (
        .CLK(CLK),
        .Reset(Reset),
        .Tarjeta_recibida(Tarjeta_recibida),
        .Pin(Pin),
        .Digito(Digito),
        .D_stb(D_stb),
        .Transaccion_tipo(Transaccion_tipo),
        .Monto(Monto),
        .M_stb(M_stb),
        .Balance_actualizado(Balance_actualizado),
        .Entregar_plata(Entregar_plata),
        .Sin_fondos(Sin_fondos),
        .Pin_incorrecto(Pin_incorrecto),
        .Advertencia(Advertencia),
        .Bloqueo(Bloqueo)
    );

        Controlador_banco_Tester contador_tester (
        .CLK(CLK),
        .Reset(Reset),
        .Tarjeta_recibida(Tarjeta_recibida),
        .Pin(Pin),
        .Digito(Digito),
        .D_stb(D_stb),
        .Transaccion_tipo(Transaccion_tipo),
        .Monto(Monto),
        .M_stb(M_stb),
        .Balance_actualizado(Balance_actualizado),
        .Entregar_plata(Entregar_plata),
        .Sin_fondos(Sin_fondos),
        .Pin_incorrecto(Pin_incorrecto),
        .Advertencia(Advertencia),
        .Bloqueo(Bloqueo)
    ); 
endmodule
