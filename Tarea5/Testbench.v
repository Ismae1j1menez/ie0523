`include "Master.v"
`include "Tester.v"
`include "Slave.v"
module Testbench (
    input wire Begi_trans,
    input wire CKP,
    input wire CPH,
    input wire CLK,
    input wire Reset,
    input wire MISO,
    input wire MOSI,
    input wire SCK,
    input wire CS,
    input wire SS
);

initial begin
$dumpfile("ondas.vcd");
$dumpvars;
end
wire MISO_to_slave2;
wire MISO_to_slave3;
wire CS_to_SS;

master_transmisor maestro (
    .Begi_trans(Begi_trans),
    .CKP(CKP),
    .CPH(CPH),
    .CLK(CLK),
    .Reset(Reset),
    .MISO(MISO),
    .MOSI(MOSI),
    .SCK(SCK),
    .CS(CS_to_SS)
);

Tester probador (
    .Begi_trans(Begi_trans),
    .CKP(CKP),
    .CPH(CPH),
    .CLK(CLK),
    .Reset(Reset),
    .SCK(SCK)
);

// Primer slave
slave_receptor slave1 (
    .Begi_trans(Begi_trans),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO_to_slave2),  // Esta línea cambió
    .MOSI(MOSI),
    .SCK(SCK),
    .SS(CS_to_SS)
);

//Segundo slave
slave_receptor slave2 (
    .Begi_trans(Begi_trans),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO_to_slave3),  // Esta línea cambió
    .MOSI(MISO_to_slave2),  // Esta línea cambió
    .SCK(SCK),
    .SS(CS_to_SS)
);

//Tercer slave
slave_receptor slave3 (
    .Begi_trans(Begi_trans),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO),            // Esta línea se mantiene igual
    .MOSI(MISO_to_slave3),  // Esta línea cambió
    .SCK(SCK),
    .SS(CS_to_SS)
);


endmodule