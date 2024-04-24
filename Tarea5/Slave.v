module slave_receptor (
    input wire Begi_trans,
    input wire CKP,
    input wire CPH,
    input wire MOSI,
    input wire SCK,
    output reg MISO,
    input wire SS
);
reg [1:0] E_Actual, E_Siguiente;
reg [15:0] Data_register, Prox_Data_register;
reg [7:0] Data1 = 8'b00000000;
reg [7:0] Data2 = 8'b00001001;
reg data_begin_data_register = 0; 
reg [4:0] Bit_counter;
wire SCK_escogido;
wire [1:0] MODO;
wire Finish_protcol; // Asegúrate de que esto está siendo usado correctamente
assign Finish_protcol = Bit_counter == 5'b10001;
assign MODO = {CKP, CPH};
assign SCK_escogido = (MODO == 0 || MODO == 3) ? SCK : ~SCK;

parameter Reposo = 2'b0;
parameter Transccion_process = 2'b01;


always @(posedge SCK_escogido) begin
    if (Begi_trans == 0) begin
        E_Actual <= 0;
        Bit_counter <= 0;
        MISO <= 0;
        if (data_begin_data_register == 0) begin
            Data_register <= {Data1, Data2};
            data_begin_data_register <= 1; 
        end
    end else begin
        E_Actual <= E_Siguiente;
        Bit_counter <= Bit_counter + 1;
        Data_register <= Prox_Data_register;
    end
end



always @(*) begin
    //FLIP-FLOPS
    Prox_Data_register = Data_register;
    E_Siguiente = E_Actual;

    case(E_Actual)
        Reposo: begin
            Bit_counter = 0; 
            if (Begi_trans && SS == 0) begin
                E_Siguiente = Transccion_process;
            end else begin
                E_Siguiente = Reposo;
            end
        end
        Transccion_process: begin // Cambiado Begi_trans a Transccion_process
            if (Bit_counter == 0) begin
                MISO = Data_register[15];
            end else begin
                MISO = Data_register[15];
                Prox_Data_register = {Data_register, MOSI};
            end
            if (Finish_protcol && SS == 1) begin
                E_Siguiente = Reposo;
                Bit_counter = 0;
            end
        end
    endcase
end
endmodule