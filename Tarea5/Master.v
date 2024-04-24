module master_transmisor (
    input wire Begi_trans,
    input wire CKP,
    input wire CPH,
    input wire CLK,
    input wire Reset,
    input wire MISO,
    output reg MOSI,
    output reg SCK,
    output reg CS
);
reg [1:0] E_Actual, E_Siguiente;
reg [15:0] Data_register, Prox_Data_register;
reg [7:0] Data1 = 8'b00000100, Data1_newdata;
reg [7:0] Data2 = 8'b00000000, Data2_newdata;
reg [4:0] Bit_counter;
wire Finish_protcol; // Asegúrate de que esto está siendo usado correctamente
assign Finish_protcol = Bit_counter == 5'b10001;
wire SCK_escogido;
wire [1:0] MODO;
assign MODO = {CKP, CPH};
assign SCK_escogido = (MODO == 0 || MODO == 3) ? SCK : ~SCK;


// Generacion de el reloj de 1/4 de frecuencia
reg CLK_div2;
reg [1:0] Count_clock;

parameter Reposo = 2'b00;
parameter Transccion_process = 2'b01;

always @(posedge CLK) begin
    if (Reset == 1) begin // Cambiado 2'b01 a 1'b1
        E_Actual <= Reposo;
        CLK_div2 <= 0;
        Count_clock <= 0;
        Data_register <= {Data1, Data2};
        MOSI <= 0;
        Bit_counter <= 0;
    end else begin
        E_Actual <= E_Siguiente;
        CLK_div2 <= ~CLK_div2;
        Count_clock <= Count_clock + 1;
    end
end

always @(posedge SCK_escogido) begin
    if (Begi_trans == 0) begin
        Bit_counter <= 0; 
    end else begin
        Bit_counter <= Bit_counter + 1;
        Data_register <= Prox_Data_register;
    end
end

always @(*) begin
    //Flip-FLops
    Prox_Data_register = Data_register;
    E_Siguiente = E_Actual;

    case(E_Actual)
        Reposo: begin
            Data1_newdata = Data_register[15:8];
            Data2_newdata = Data_register[7:0];
            Bit_counter = 0; 
            CS = 1;
            if (CKP) begin
                SCK = 1;
            end else begin
                SCK = 0;
            end
            if (Begi_trans && Finish_protcol == 0) begin
                E_Siguiente = Transccion_process;
            end else begin
                E_Siguiente = Reposo;
            end
        end
        Transccion_process: begin 
            CS = 0;  
            SCK = Count_clock[1];
            if (Bit_counter == 0) begin
                    MOSI = Data_register[15];
                end else begin
                    MOSI = Data_register[15];
                    Prox_Data_register = {Data_register, MISO};
                end
            if (Finish_protcol) begin
                E_Siguiente = Reposo;
            end
        end
    endcase
end
endmodule