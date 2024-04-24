`include "generador_mdio.v"
`include "receptor_mdio.v"
  

// Testbench Code Goes here
module mdio_tb;

reg         clock, reset, mdio_start_stb;
reg  [31:0] transaccion;
reg  [15:0] mdio_data_read;
wire [15:0] mdio_data_write;
wire [15:0] reg_addr;
wire        mdc, mdio_out, mdio_oe, mdio_in;

initial begin
	$dumpfile("mdio.vcd");
	$dumpvars(-1, U0);
	$dumpvars(-1, U1);
end


initial begin
  clock = 0;
  reset = 0;

  #20 reset = 1;
  #120 reset = 0;
      mdio_start_stb = 0;
      transaccion = 32'h55555555;
  #80 mdio_start_stb = 1;
  #40 mdio_start_stb = 0;
  #7800 transaccion = 32'h65557777;
        mdio_data_read = 16'h2468;
  #160  mdio_start_stb = 1;
  #40   mdio_start_stb = 0;
  #8000 $finish;
end

always begin
 #20 clock = !clock;
end


generador_mdio U0 (
/*AUTOINST*/
		   // Outputs
		   .mdio_out		(mdio_out),
		   .mdio_oe		(mdio_oe),
		   .mdc			(mdc),
		   // Inputs
		   .clk			(clock),
		   .reset		(reset),
		   .start_stb		(mdio_start_stb),
		   .mdio_in		(mdio_in),
		   .transaccion		(transaccion[31:0]));


receptor_mdio U1 (
/*AUTOINST*/
		  // Outputs
		  .mdio_data_write	(mdio_data_write[15:0]),
		  .reg_addr		(reg_addr[5:0]),
		  .mdio_in		(mdio_in),
		  // Inputs
		  .mdc			(mdc),
		  .reset		(reset),
		  .mdio_out		(mdio_out),
		  .mdio_oe		(mdio_oe),
		  .mdio_data_read	(mdio_data_read[15:0]));


endmodule