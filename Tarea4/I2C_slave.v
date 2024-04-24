// Declaracion de variables
module receptor_mdio(
    input wire CLK,         // Renombrado de mdc a CLK
    input wire Reset,       // Renombrado de reset a Reset
    output SDA_in,      // Renombrado de mdio_out a sdain
    input wire SDA_oe,      // Se mantiene como SDA_oe
    input wire [15:0] Rd_data_slave, // Renombrado de mdio_data_read a Rd_data
    output reg [15:0] Wr_data_slave, // Renombrado de mdio_data_write a Wr_data
    input wire [6:0] I2c_addr_slave, // Renombrado de reg_addr a I2c_addr (cambiado de 5 bits a 7 bits)
    input wire SDA_out,      // Renombrado de mdio_in a SDA_out
    input wire SCL
    );

// Parametros para la maquina de estados
parameter Inicio = 2'b00; 
parameter Comparando_adrres = 2'b01;
parameter Write = 2'b10;
parameter Read = 2'b11;

//Contador de bits
reg [3:0] Bit_counter;

// Señales intermedias utilizadas en la logica
reg [1:0] E_Actual, E_Siguiente;
reg [6:0] Comparar_adress, Prox_comparar_adress;
reg Prox_sdain;
reg [15:0] Prox_wr_data_slave; 
reg number_transaccion = 0; 
wire SDA_in;
assign SDA_in = ~ sdain;
reg sdain;


// Los estados iniciales se manejan en el CLK porque la logica interna 
// Perite utilizar relojes rapidos
always @(posedge CLK) begin
    if (Reset) begin 
        E_Actual      <= Inicio;
    end else begin
        E_Actual     <= E_Siguiente;
    end
    if (E_Actual == Inicio) begin
        Comparar_adress <= 16'b0000000000000000;
    end
end

// Flip flops sincronizados con el SCL, ademas es utilizado para inicializar
// o para devolverlos al estados inicial al terminar una transacción
always @(posedge SCL) begin
        if (Reset) begin
        Bit_counter <= 0;
        Comparar_adress <= 0; 
        sdain <= 0; 
        Wr_data_slave <= 0; 
        end else begin      
        Bit_counter <= Bit_counter+1;
        Comparar_adress <= Prox_comparar_adress;
        sdain <= Prox_sdain;
        Wr_data_slave <= Prox_wr_data_slave;
        end
end 


// Logica combinacional
always @(*) begin
    E_Siguiente = E_Actual;
    Prox_sdain = sdain; 
    Prox_comparar_adress = Comparar_adress;
    Prox_wr_data_slave = Wr_data_slave;

    // Comienzo de la maquina de estados
    case (E_Actual)
        // Comienza el estado 00
        // Espera la condición de inicio, el cual es que SDA_out este en alto
        // mientras el SCL se mantien en alto, esta condicion le indica que lo siguiente 
        // son los bits necesarios para comparar con la direccion de el mismo
        Inicio: begin 
            sdain = 0; 
            number_transaccion = 0; 
            if (SCL == 1 && SDA_out == 0) begin
                Bit_counter = 0; 
                E_Siguiente = Comparando_adrres; 
            end
        end
        // Comienza el estado 01
        // Este estado tiene dos funciones, primero espera a comparar si el master busca
        // la transsción con este estado o si no es este slave se devuelve al inicio
        Comparando_adrres: begin 
            if (SDA_oe == 1 && Comparar_adress != I2c_addr_slave) begin
                if (Bit_counter <= 7)begin
                    Prox_comparar_adress = {Comparar_adress, SDA_out};
                end
            end   
            if (Comparar_adress == I2c_addr_slave && Bit_counter == 4'b1001) begin 
                if (SDA_out == 0) begin
                    E_Siguiente = Write;
                    Bit_counter = 0; 
                end
                if (SDA_out == 1) begin
                    E_Siguiente = Read;
                    sdain = 1; 
                    Bit_counter = 0; 
                end
            end
            if (Comparar_adress != I2c_addr_slave && Bit_counter == 4'b1001) begin
                E_Siguiente = Inicio;
            end
        end
        // Comienza el estado 10
        // Este estado es el encargado de manejar la lógica de de escritura
        // cuando termina se devuelve al inicio
        Write: begin  
            if (Bit_counter == 4'b0000) begin
                sdain = 1; 
            end else begin
                sdain = 0; 
            end
            if (Bit_counter < 4'b1001 && number_transaccion == 0) begin
                Prox_wr_data_slave = {Wr_data_slave, SDA_out};
            end
            if (Bit_counter < 4'b1001 && number_transaccion == 1 && Bit_counter > 4'b0000) begin
                Prox_wr_data_slave = {Wr_data_slave, SDA_out};
            end
            if (Bit_counter == 4'b1001) begin
                sdain = 1;  
                if (number_transaccion == 0) begin
                    Bit_counter = 0;
                    number_transaccion = 1; 
                end
                if (SCL == 1 && SDA_out == 1 && number_transaccion == 1) begin
                    E_Siguiente = Inicio; 
                end
            end
        end
        // Comienza el estado 11
        // Este estado es el encaragado de manejar los valores en 
        // el estado de lectura, cuando termina vuelve al inicio
        Read: begin 
            if (Bit_counter < 4'b1001 && number_transaccion == 0 && Bit_counter > 4'b0000) begin
                sdain = Rd_data_slave[16-Bit_counter];  // Corregido "cuenta_bits" por "Bit_counter"
            end
            if (Bit_counter < 4'b1001 && number_transaccion == 1) begin
                sdain = Rd_data_slave[8-Bit_counter];  // Corregido "cuenta_bits" por "Bit_counter"
            end
            if (Bit_counter == 4'b1001) begin 
                if (number_transaccion == 0) begin
                    Bit_counter = 0;
                    number_transaccion = 1;
                end
            end
            if (Bit_counter == 4'b1001 && number_transaccion == 1) begin
                    if (SCL == 1 && SDA_out == 1 && number_transaccion == 1) begin
                        E_Siguiente = Inicio; 
                    end
            end
        end
    endcase
end

endmodule