`include "I2C_master.v"
`include "Tester.v"
`include "I2C_slave.v"

// Declaracion de entradas, salidas, wires y regs
module Testbench (
    input wire CLK,
    input wire Reset,
    input wire Rnw,
    input wire [6:0] I2c_addr_master,
    input wire [6:0] I2c_addr_slave,
    input wire [15:0] Wr_data_master,
    input wire [15:0] Rd_data_slave,
    input wire Start_stb,
    input wire SDA_out,
    input wire SDA_oe,
    input wire SDA_in,
    input wire SCL
);

initial begin
    $dumpfile("ondas.vcd");
    $dumpvars;
end

// Instancias de módulos, el transmisorm, receptor y tester
master_i2c I2c_transmisor (
    .CLK(CLK),
    .Reset(Reset),
    .Rnw(Rnw),
    .I2c_addr_master(I2c_addr_master),
    .Wr_data_master(Wr_data_master),
    .Start_stb(Start_stb),
    .SDA_out(SDA_out),
    .SDA_oe(SDA_oe),
    .SDA_in(SDA_in),
    .SCL(SCL)
);

Tester probador (
    .CLK(CLK),
    .Reset(Reset),
    .Rnw(Rnw),
    .I2c_addr_master(I2c_addr_master),
    .I2c_addr_slave(I2c_addr_slave),
    .Wr_data_master(Wr_data_master),
    .Rd_data_slave(Rd_data_slave),
    .Start_stb(Start_stb),
    .SDA_oe(SDA_oe),
    .SDA_in(SDA_in),
    .SCL(SCL)
);

receptor_mdio I2c_receptor (
    .CLK(CLK),
    .Reset(Reset),
    .I2c_addr_slave(I2c_addr_slave),
    .Rd_data_slave(Rd_data_slave),
    .SDA_out(SDA_out),
    .SDA_oe(SDA_oe),
    .SDA_in(SDA_in),
    .SCL(SCL)
);

endmodule
