// Declaracion de variables 
module master_i2c (
    input wire CLK,
    input wire Reset,
    input wire Rnw,
    input wire [6:0] I2c_addr_master,
    input wire [15:0] Wr_data_master,
    output reg [15:0] Rd_data_master,  
    input wire Start_stb,
    output reg SDA_out,
    output reg SDA_oe,
    input wire SDA_in,
    output reg SCL  // Cambiado a reg, ya que es asignado dentro de always
);

// Variables intermedias importantes utilizadas en la logica
reg [2:0] E_Actual, E_Siguiente;  
reg Prox_SDA_out, Prox_SDA_oe;
reg [15:0] Prox_rd_data_master;

// Parametros utilizados en la maquina de estados
parameter Inicio_idl = 3'b000;
parameter Confirm_adress = 3'b001;
parameter Esperando_recibido_escritura = 3'b010;
parameter Esperando_recibido_lectura = 3'b011;
parameter Escritura = 3'b100; 
parameter Lectura = 3'b101;

// Importante para la generacion del reloj de 1/4 de reloj de frecuencia
reg [1:0] Count_clock;

// Variables intermedias utilizadas para terminar las transacciones
reg [3:0] Bit_counter;
reg number_transaccion = 0; 


// Logica utilizada para la incializadon o devolucion de las varaibles intermedias
// al estado inicial si es activa Reset o Start_stb
// Los estados son manejados en el reloj rapido 
// Y como SCL depende del CLK debe manejarse aqui tambien
always @(posedge CLK) begin
    if (Start_stb) begin
        SDA_out = Prox_SDA_out;
    end
    if (Reset == 1'b1) begin  // Cambiado 2'b01 a 1'b1
        E_Actual <= Inicio_idl;
        Count_clock <= 0;
    end else begin
        E_Actual <= E_Siguiente;
        Count_clock <= Count_clock + 1;
    end
end


// Permite incializar las variables o devolverlas al estado inicial siempre y cuando 
// Start_stb o Reset son activas en un flanco de SCL
always @(posedge SCL) begin
   if (Reset || Start_stb) begin
     Bit_counter <= 0; 
     SDA_oe     <= 1;
     SDA_out <= 0;
     Rd_data_master <= 0; 
   end else begin
     Bit_counter <= Bit_counter + 1; 
     SDA_out    <= Prox_SDA_out;
     SDA_oe     <= Prox_SDA_oe;
     Rd_data_master <= Prox_rd_data_master;
   end
 end


// Logica combinacional
always @(*) begin
    E_Siguiente = E_Actual;
    Prox_SDA_oe = SDA_oe; 
    Prox_SDA_out = SDA_out;
    Prox_rd_data_master = Rd_data_master;

    // Comienzo de la maquina de estados
    // Comienzo del estado 000
    // Este estado es el incial, espera a Start_stb que tiene el objetivo de
    // pasar al estado de Confirm_adress
    case (E_Actual) 
        Inicio_idl: begin 
            SCL = 1; 
            Prox_SDA_oe = 1; 
            SDA_out = 1; 
            Bit_counter = 0; 
            number_transaccion = 0; 
            if (Start_stb) begin 
                SDA_out = 0;  
                E_Siguiente = Confirm_adress; 
            end else begin
                E_Siguiente = Inicio_idl; 
            end
        end
        // Comienzo del estado 001
        // En este caso empieza enviando las direccion adress al slave
        // con el objetivo de comparar el adress y descubrir con cual slave 
        // comenzar la transaccion
        Confirm_adress: begin 
            SCL = Count_clock[1];
            SDA_oe = 1;  
            if (Bit_counter <= 6) begin
                 Prox_SDA_out = I2c_addr_master[6-Bit_counter];
            end
            if (Bit_counter == 7) begin
                Prox_SDA_out = Rnw;
            end
            if (!Rnw && Bit_counter == 8) begin  // Corregido "A" por "Finis_addres"
                E_Siguiente = Esperando_recibido_escritura;    // Corregido "ESCRITURA_1" por "Escritura"
            end 
            if (Rnw && Bit_counter == 8) begin
                E_Siguiente = Esperando_recibido_lectura;
            end 
        end
        // Comienzo del estado 010
        // Tiene como objetivo el esperar el recibido de la escritura para pasar
        // a comenzar la transacción
        Esperando_recibido_escritura: begin 
            Bit_counter = 0; 
            SCL = Count_clock[1];
            Prox_SDA_oe = 0;
            if (SDA_in == 0) begin
                E_Siguiente = Escritura;
                Bit_counter = 0; 
            end
            if (Bit_counter == 4'b1111 && SDA_in == 1) begin
                E_Siguiente = Inicio_idl;
            end
        end
        // Comienzo del estado 011
        // Similar al anterior espera el recibido de lectura para pasar a la lectura
        Esperando_recibido_lectura: begin 
            SCL = Count_clock[1];
            Prox_SDA_oe = 0; 
            if (SDA_in == 0) begin
                E_Siguiente = Lectura;
                Bit_counter = 0; 
            end
            if (Bit_counter == 4'b1111 && SDA_in == 1) begin
                E_Siguiente = Inicio_idl;
            end
        end
        // Comienzo del estado 100
        // Aqui se maneja la logica de la escritura, donde se envian los datos al slave
        // al terminar la transccion vuelve al estado incial
        Escritura: begin 
            SCL = Count_clock[1];
            if (Bit_counter == 4'b1000 && number_transaccion == 0) begin
                Prox_SDA_oe = 0; 
            end else begin
                Prox_SDA_oe = 1;
            end
            if (Bit_counter < 4'b1000 && number_transaccion == 0) begin
                Prox_SDA_out = Wr_data_master[15-Bit_counter];  // Corregido "cuenta_bits" por "Bit_counter"
            end
            if (Bit_counter < 4'b1000 && number_transaccion == 1) begin
                Prox_SDA_out = Wr_data_master[7-Bit_counter];  // Corregido "cuenta_bits" por "Bit_counter"
            end
            if (Bit_counter == 4'b1001 && number_transaccion == 0) begin 
                if (SDA_in == 0) begin
                    Bit_counter = 0; 
                    number_transaccion = 1; 
                end
            end
            if (SCL == 1 && number_transaccion == 1 && Bit_counter == 4'b1001 && SDA_in == 0) begin
                    SCL = 1; 
                    SDA_out =1;
                    E_Siguiente = Inicio_idl;
                    SDA_oe = 0; 
            end
        end
        // Comienzo del estado 101
        // En esta caso si de igual manera se maneja la logica del estado de lectura 
        // Se almacena los datos provenientes del slave, al finalizar vuelve al estado incial 
        Lectura: begin  
            SCL = Count_clock[1];
            if (Bit_counter == 4'b1000) begin
                Prox_SDA_out = 0;
                Prox_SDA_oe = 1; 
            end else begin
                Prox_SDA_out = 1;
                Prox_SDA_oe = 0; 
            end
            if (Bit_counter < 4'b1001 && number_transaccion == 0 && Bit_counter > 4'b0000) begin
                Prox_rd_data_master = {Rd_data_master, ~SDA_in};
            end
            if (Bit_counter < 4'b1001 && number_transaccion == 1 && Bit_counter > 4'b0000) begin
                Prox_rd_data_master = {Rd_data_master, ~SDA_in};
            end
            if (Bit_counter == 4'b1001) begin
                Prox_SDA_out = 1;  
                if (number_transaccion == 0) begin
                    Bit_counter = 0;
                    number_transaccion = 1; 
                end
                if (SCL == 1 && number_transaccion == 1 && Bit_counter == 4'b1001) begin
                    SCL = 1; 
                    Prox_SDA_out =1;
                    E_Siguiente = Inicio_idl;
                end
            end
        end
    endcase
end

endmodule