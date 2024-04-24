module Tester (
    output reg CLK,
    output reg Reset,
    output reg Rnw,
    output reg [6:0] I2c_addr_master,
    output reg [6:0] I2c_addr_slave,
    output reg [15:0] Wr_data_master,
    output reg [15:0] Rd_data_slave,
    output reg Start_stb,
    input wire SDA_oe,
    input wire SDA_in,
    input wire SCL
);

// Inicialización de las señales
initial begin
    CLK = 0;
    Reset = 0;
    Rnw = 0;
    I2c_addr_master = 7'b0001001;
    I2c_addr_slave = 7'b0001001;
    Wr_data_master = 16'b1010101010101010;
    Rd_data_slave = 16'b1100110011001100;
    Start_stb = 0;
    
    // Pruebas del modo de escritura, el receptor tiene que responder
    #10 Reset = 1;
    #10 Reset = 0;
    #10; 
    Start_stb = 1;
    Rnw = 0;
    #2 Start_stb = 0; 
    #400; 

    // Pruebas del modo de lectura, el receptor tiene que responder
    Start_stb = 1;
    Rnw = 1;
    #2 Start_stb = 0;
    #400;

    //Pruebas de si el receptor ignora adress diferentes al suyo
    I2c_addr_master = 7'b1111111;
    Start_stb = 1;
    Rnw = 1;
    #2 Start_stb = 0;
    #400 $finish;  // Finaliza la simulación luego de 400 unidades de tiempo
end

// Generador de reloj
always begin
    #1 CLK = ~CLK;
end

endmodule
