module contador_de4_bits (
    input wire CLK,
    input wire ENB,
    input wire [1:0] MODO,
    input wire [3:0] D,
    output reg [3:0] Q,
    output reg RCO,
    output reg Paridad
);

    always @(posedge CLK) begin  
        if (MODO == 2'b11) begin
            Q <= D;
        end 
        else if (ENB == 1) begin
            case (MODO)
                2'b00: Q <= Q + 1; // Cuenta ascendente
                2'b01: Q <= Q - 1; // Cuenta descendente
                2'b10: Q <= Q + 3; // Cuenta ascendente de 3 en 3
            endcase
        end
    end
    
    always @* begin 
        Paridad = ^Q;    
        RCO <= (Q == 4'b1111 && MODO == 2'b00) || (Q == 4'b0000 && MODO == 2'b01) || (Q == 4'b1101 && MODO == 2'b10) 
            || (Q == 4'b1110 && MODO == 2'b10) || (Q == 4'b1111 && MODO == 2'b10); 
    end

endmodule 





