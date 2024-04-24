module receptor_mdio(/*AUTOARG*/
   // Outputs
   mdio_data_write, reg_addr, mdio_in,
   // Inputs
   mdc, reset, mdio_out, mdio_oe, mdio_data_read
   );
  input mdc,reset,mdio_out,mdio_oe;
  input [15:0] mdio_data_read;
  output [15:0] mdio_data_write;
  output [5:0]  reg_addr;
  output reg mdio_in;

  //ESTADOS
  localparam REC_BITS = 2'b01;
  localparam ENV_BITS = 2'b10;

  //VARIABLES INTERMEDIAS
  reg [31:0] transaccion,prox_transaccion;
  reg [1:0] estado, prox_estado;
  reg [4:0] cuenta_bits;
  reg mdio_oe_d;
  wire posedge_mdio_oe, trans_finalizada, mitad_transaccion, start, write;

  // CONSTRUCCION DE VARIABLES INTERMEDIAS
  assign trans_finalizada  = (cuenta_bits == 31);
  assign mitad_transaccion = (cuenta_bits == 16);
  assign start             = ~transaccion[31] & transaccion[30]; // START = 01
  assign lectura           = transaccion[29]  & ~transaccion[28]; // READ = 10
  assign mdio_data_write   = transaccion[15:0];
  assign reg_addr          = transaccion[22:18];

  //DETECCION DEL FLANCO POSITIVO DE MDIO_OE
  assign posedge_mdio_oe = mdio_oe && !mdio_oe_d;

  //FLIP FLOPS PARA LAS TRANSACCIONES
  always @(posedge mdc) begin
	  if (reset || posedge_mdio_oe) begin
		estado      <= REC_BITS;
//		mdio_oe_d   <= 0;
		transaccion <= 0;
		cuenta_bits <= 0;
	  end else begin      
		estado      <= prox_estado;
//		mdio_oe_d   <= mdio_oe;
		transaccion <= prox_transaccion;
		cuenta_bits <= cuenta_bits+1;
	  end
  end 

//FLIP FLOP PARA DETECTAR EL FLANCO DE MDIO
//NO PUEDE DEPENDER DE POSEDGE DE MDIO PORQUE
//HACE REFERENCIA CIRCULAR

  always @(posedge mdc) begin
          if (reset) begin
                mdio_oe_d   <= 0;
          end else begin
                mdio_oe_d   <= mdio_oe;
          end
  end



  //LOGICA COMBINACIONAL
  always @(*) begin
    //RETROALIMENTACION PARA SOSTENER EL ESTADO Y LA TRANSACCION HASTA QUE SE
    //RECIBE UN CAMBIO
    prox_estado = estado;
    prox_transaccion = transaccion;

    case (estado)
      REC_BITS:
          begin
            if (mdio_oe) prox_transaccion[31-cuenta_bits] = mdio_out;
            if (lectura && mitad_transaccion) prox_estado = ENV_BITS;
	  end
      ENV_BITS:
	  begin
	    if (!mdio_oe) mdio_in = mdio_data_read[cuenta_bits-16];
            if (trans_finalizada) prox_estado = REC_BITS;
          end
    endcase
  end

endmodule