`include "Contador4b.v"
module contador_de16_bits #(parameter N = 16) (
    input wire CLK,
    input wire ENB,
    input wire [1:0] MODO,
    input wire [N-1:0] D,
    output wire [N-1:0] Q,
    output reg RCO,
    output wire Paridad
);

    // Declaracion de las señales intermedias
    wire [3:0] D_array[N/4-1:0];
    wire [3:0] Q_array[N/4-1:0];
    wire RCO_array[N/4-1:0];
    wire Paridad_array[N/4-1:0];

    genvar i;
    
    generate
        for (i = 0; i < N/4; i = i + 1) begin : ct4b
            assign D_array[i] = D[i*4 +: 4];
            
            wire ENB_temp = (i == 0) ? (
                (MODO == 2'b00 || MODO == 2'b10 || MODO == 2'b11) ? 
                ((Q_array[0] == 4'b0000 && Q_array[1] == 4'b0000 && Q_array[2] == 4'b0000 && Q_array[3] == 4'b0000) ? 1'b1 : ENB) :
                ((Q_array[0] == 4'b0000 && Q_array[1] == 4'b0000 && Q_array[2] == 4'b0000 && Q_array[3] == 4'b0000) ? 1'b0 : ENB)
            ) : (
                (MODO == 2'b01 && Q_array[i] == 4'b0000) ? 1'b0 : RCO_array[i-1]
            );

            wire [1:0] MODO_temp = (i == 0) ? MODO : ((MODO == 2'b10) ? 2'b00 : MODO);

            contador_de4_bits ct4b (
                .CLK(CLK),
                .ENB(ENB_temp),
                .MODO(MODO_temp),
                .D(D_array[i]),
                .Q(Q_array[i]),
                .RCO(RCO_array[i]),
                .Paridad(Paridad_array[i])
            );
            assign Q[i*4 +: 4] = Q_array[i];
        end
    endgenerate

     always @(posedge CLK) begin
    RCO <= RCO_array[0] & RCO_array[1] & RCO_array[2] & RCO_array[3];
end

    assign Paridad = Paridad_array[0] ^ Paridad_array[1] ^ Paridad_array[2] ^ Paridad_array[3];

endmodule
