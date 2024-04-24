module generador_mdio(/*AUTOARG*/
   // Outputs
   mdio_out, mdio_oe, mdc,
   // Inputs
   clk, reset, start_stb, mdio_in, transaccion
   );

  //Entradas y salidas
  input clk,reset,start_stb,mdio_in;
  input [31:0] transaccion;
  output reg mdio_out, mdio_oe;
  output     mdc;

  //Variables intermedias
  reg [2:0]  estado, prox_estado;
  reg [15:0] dato_recibido, prox_dato_recibido;
  reg [4:0] cuenta_bits, prox_cuenta_bits; //Cuenta bits de la transacción
  wire write,trans_finalizada;
  reg nxt_mdio_oe;
  
  assign write = ~transaccion[29] && transaccion[28];
  assign trans_finalizada = (cuenta_bits == 31);
  //assign trans_finalizada = &cuenta_bits;

  localparam INICIO    = 3'b001;
  localparam ESCRITURA = 3'b010;
  localparam LECTURA   = 3'b100;

  //Fip flops
  always @(posedge clk) begin
    if (reset) begin
      estado        <= INICIO;
      dato_recibido <= 0;
    end else begin
      estado        <= prox_estado;
      dato_recibido <= prox_dato_recibido;
    end
  end

  //Logica combinacional
  always @(*) begin

  prox_estado        = estado;
  prox_dato_recibido = dato_recibido;
  nxt_mdio_oe = mdio_oe;

    case (estado)
      INICIO:
        begin
          nxt_mdio_oe = start_stb;
	  if (start_stb && write) begin
            prox_estado = ESCRITURA;
          end else if (start_stb && ~write) begin
            prox_estado = LECTURA;
	  end
	end
      ESCRITURA: 
        begin
	   if (trans_finalizada) prox_estado = INICIO;
	   nxt_mdio_oe = 1;
	end
      LECTURA:
	begin
           if (trans_finalizada) prox_estado = INICIO;
	   nxt_mdio_oe = (cuenta_bits < 16) ? 1 : 0;
           if (cuenta_bits < 16) prox_dato_recibido = 0;
	   else prox_dato_recibido[31-cuenta_bits] = mdio_in; 
        end
      default:  
        begin
	  prox_estado = INICIO;
	  prox_dato_recibido = 0;
	end
    endcase;
  end

//Generación del reloj de salida MDC  
reg clk_div2; 
wire clk_div4;
reg [1:0] count_clock;

always @(posedge clk) begin
  if (reset) begin
    clk_div2    <= 0;
    count_clock <= 0;
  end else begin
    clk_div2    <= ~clk_div2;
    count_clock <= count_clock+1;
  end
end

assign clk_div4 = count_clock[1];
assign mdc = clk_div2;

// Incremento de cuenta_bits
always @(posedge mdc) begin
   if (reset || start_stb) begin
     cuenta_bits <= 0;
     mdio_oe     <= 0;
   end else begin
     cuenta_bits <= cuenta_bits+1;
     mdio_out    <= transaccion[31-cuenta_bits];
     mdio_oe     <= nxt_mdio_oe;
   end
 end

endmodule