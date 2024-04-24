module Controlador_banco (
    input wire CLK,
    input wire Reset,
    input wire Tarjeta_recibida,
    input wire [15:0] Pin,
    input wire [3:0] Digito,
    input wire D_stb,
    input wire Transaccion_tipo,
    input wire [31:0] Monto,
    input wire M_stb,
    output reg Balance_actualizado,
    output reg Entregar_plata,
    output reg Sin_fondos,
    output reg Pin_incorrecto,
    output reg Advertencia,
    output reg Bloqueo
);
//Declaración de variables intermedias
reg [2:0] Actual, Siguiente;
reg [63:0] Balance, Prox_Balance;
reg M_stb_anterior, Prox_M_stb_anterior;
//Necesarios para el PIN
reg [15:0] Pin_entrada, Prox_Pin_entrada;
reg [2:0] Cantidad_digitos, Prox_Cantidad_digitos;
reg [1:0] Intentos, Prox_Intentos;

//Numero del estado 
parameter Estado_inicial = 3'b000; //Estado inicial, eperando tarjeta 
parameter Pin_correcto = 3'b001; //Estado esperando pin correcto
parameter Esperando_tipo_transaccion = 3'b010; //Esperando tipo de transaccion
parameter Retiro = 3'b011; //Tipo de transaccion retiro, esperando monto
parameter Deposito = 3'b111; //Tipo de transaccion deposito
parameter Bloqueo_pin_incorrecto = 3'b101; //Bloqueo, estado de bloqueo por 3 intentos fallidos

//Indicaciones del pin
always @(posedge CLK) begin
    if (Reset == 2'b01)begin
        Actual <= Estado_inicial; 
        Balance <= 32'h0AF0_0000;
        M_stb_anterior <= 0;
        Intentos <= 0;
        Pin_entrada <= 0;
        Cantidad_digitos <= 0;
    end else begin
        Actual <= Siguiente;
        Balance <= Prox_Balance;
        M_stb_anterior <= Prox_M_stb_anterior;
        Intentos <= Prox_Intentos;
        Pin_entrada <= Prox_Pin_entrada;
        Cantidad_digitos <= Prox_Cantidad_digitos;

    end
end

always @(*) begin
    //Flip-Flops
    Siguiente = Actual;
    Prox_Balance = Balance;
    Prox_M_stb_anterior <= M_stb;
    Prox_Cantidad_digitos = Cantidad_digitos;
    Prox_Pin_entrada = Pin_entrada;
    Prox_Intentos = Intentos;
    
    //Necesario inicializar las salidas
    Advertencia = 0;
    Bloqueo = 0;
    Entregar_plata = 0;
    Sin_fondos = 0;
    Balance_actualizado = 0;
    Pin_incorrecto = 0; 

    //Se empiezan con la descripcion de la maquina de estados
    case (Actual)
        //Primer estado, valor binario 3'b000
        Estado_inicial: begin
            if (Tarjeta_recibida == 1) begin
                Siguiente = Pin_correcto;
                Prox_Pin_entrada = 0; 
            end else begin
                // Sin cambio
            end
        end
        //Segundo estado, valor binario 3'b001
        //Se revisan las condiciones de Pin, es decir, si es correcto, incorrecto, si se pone en alto
        //advertencia, si se pone en alto bloqueo, si aumenta intentos...
        Pin_correcto: begin
            if (D_stb && Cantidad_digitos < 4) begin
                Prox_Pin_entrada = {Pin_entrada[11:0], Digito};
                Prox_Cantidad_digitos = Cantidad_digitos + 1;
            end
            if (Cantidad_digitos == 4) begin
                Prox_Cantidad_digitos = 0;
            end
            if (Cantidad_digitos == 4 && Pin_entrada != Pin) begin
                Prox_Intentos = Intentos + 1;
            end
            Pin_incorrecto = (Cantidad_digitos == 4 && Pin_entrada != Pin);
            Advertencia = Pin_incorrecto && (Intentos == 1) && (Actual == Pin_correcto);
            Bloqueo = Pin_incorrecto && (Intentos == 2) && (Actual == Pin_correcto);
            if (Pin_entrada == Pin) begin
                Siguiente = Esperando_tipo_transaccion;
            end else if (Intentos == 3) begin
                Siguiente = Bloqueo_pin_incorrecto;
            end else begin
                Siguiente = Pin_correcto;
            end
        end
        //Tercer estado, valor binario 3'b010
        //Se espera el tipo de transacción
        Esperando_tipo_transaccion: begin
            if (Transaccion_tipo == 1) begin
                Siguiente = Deposito;
            end else begin
                Siguiente = Retiro;
            end
        end
        //Cuarto estado, 3'b011
        //Hace las operaciones de retiro, hace la comparacion entre monto y retiro, enciende las 
        //señales Balance_actualizado, Sin_fondos, Entregar_plata... dependiendo de las condiciones
        Retiro: begin
            if (M_stb == 1 && M_stb_anterior == 0) begin
                if (Monto <= Balance) begin
                    Prox_Balance = Balance - Monto;
                    Entregar_plata = 1; 
                end else begin
                    Sin_fondos = 1;  
                end
            end
            if (Prox_Balance != Balance) begin
                Balance_actualizado = 1;
            end
            if (Tarjeta_recibida == 0) begin
                Siguiente = Estado_inicial;
            end 
        end
        //Quinto estado, 3'b111
        //Suma monto y deposito, si se actualiza entonces se prende Balance_actualizado
        Deposito: begin
            if (M_stb == 1 && M_stb_anterior == 0) begin
                Prox_Balance = Balance + Monto;
            end
            if (Prox_Balance != Balance) begin
                Balance_actualizado = 1;
            end 
            if (Tarjeta_recibida == 0) begin
                Siguiente = Estado_inicial;
            end 
        end
        //Sexto estado, 3'b101
        //El sistema esta en un estado de bloqueo, hasta que se mande la señal de 
        //reinicio no se podran hacer mas operaciones.
        Bloqueo_pin_incorrecto: begin
            if (Reset == 1) begin
                Siguiente = Estado_inicial;
            end else begin
                Siguiente = Bloqueo_pin_incorrecto;
            end
        end
    endcase
end
endmodule
