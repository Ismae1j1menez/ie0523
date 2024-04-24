module parte_probador (
    output reg CLK,
    output reg ENB,
    output reg [1:0] MODO,
    output reg [15:0] D,  
    input wire [15:0] Q,  
    input wire RCO,
    input wire Paridad
);

    initial begin
      // Prueba #1, prueba ascendente
        CLK = 0;   
        ENB = 1;   
        MODO = 2'b11;   
        D = 0;    
        #5;
        #5;    
        MODO = 2'b00;   
        #10;
        #150;
        ENB = 0;
        #40; //Tiempo de espera

      // Prueba #2, prueba descendente 
        ENB = 1; 
        D = 120;
        MODO = 2'b11;
        #10;
        MODO = 2'b01;
        #150; 
        ENB = 0;
        #40 //Tiempo de espera

      //Prueba #3, cuenta ascendente de 3 en 3
        ENB = 1;
        D = 0; 
        MODO = 2'b11;
        #10;
        MODO = 2'b10;
        #170;
        ENB = 0;
        #40; //Tiempo de espera 

      //Prueba #4, carga en paralelo
        ENB = 1;
        MODO = 2'b11;
        D = 4'b0000;
        #10;
        D = 4'b1001;
        #10;
        MODO = 2'b00;
        #10;
        D = 4'b1101;
        MODO = 2'b11;
        #10;
        MODO =2'b10;
        #10;
        D = 4'bxxxx;
        MODO = 2'b11;
        #10;
        MODO = 2'b01;
        #10;
        MODO = 2'b11;
        D = 2'b0101;
        #30; 
        ENB = 0;
        #35;//Tiempo de espera 

      //Prueba #5, contador de 16 bits
        ENB = 1;
        D = 0;
        MODO = 2'b11;
        #5;
        MODO = 2'b00;
        #120;
        MODO = 2'b01;
        #120;
        MODO = 2'b10;
        #120;
        D = 30;
        MODO = 2'b11;
        #200;
        D = 0;
        #60 $finish;
    end

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
endmodule







