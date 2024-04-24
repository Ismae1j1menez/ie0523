module Tester (
    output reg Begi_trans,
    output reg CKP,
    output reg CPH,
    output reg CLK,
    output reg Reset,
    input wire SCK
);

// Secuencia de pruebas
initial begin
    // Inicialización
    CLK = 0;
    CKP = 0;
    CPH = 0;
    Reset = 1;
    Begi_trans = 0;
    #20;

    // Estados de reposo
    Reset = 0;
    #28;

    //primer modo;
    CKP = 0;
    CPH = 1;
    #20;
    Begi_trans = 1;
    #138;
    Begi_trans = 0;
    #50;

    //Segundo modo
    CKP = 1;
    CPH = 0;
    #50;
    Begi_trans = 1;
    #130;
    Begi_trans = 0;
    #50;

    //Tercer modo
    CKP = 0;
    CPH = 0;
    #50;
    Begi_trans = 1;
    #130;
    Begi_trans = 0;
    #50;

    //Cuarto modo
    CKP = 1;
    CPH = 1;
    #50;
    Begi_trans = 1;
    #138;
    Begi_trans = 0;
    #50;

    //Estado de reposo
    CKP = 0; 
    #30; 
    CKP = 1; 
    #30; 
    CKP = 0; 
    #30; 
    CKP = 1; 

    // Fin del Testbench
    #50 $finish;
    end



    always begin
    #1 CLK = !CLK;
end

endmodule