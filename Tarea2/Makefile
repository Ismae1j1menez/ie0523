IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
OUTFILE = ondas
VERILOG_FILES = Testbench.v
YOSYS=yosys


# Instrucciones
all:
	$(YOSYS) -s Contador.ys 
	$(IVERILOG) -o  $(OUTFILE) $(VERILOG_FILES)
	$(VVP) $(OUTFILE)
	$(GTKWAVE) ondas.vcd 
# Compila los archivos Verilog
compile:
	$(IVERILOG) -o $(OUTFILE) $(VERILOG_FILES)

# Ejecuta la simulación
run: 
	$(VVP) $(OUTFILE)

# Abre la onda generada en GTKWave
gtkwave:
	$(GTKWAVE) ondas.vcd

# Limpia los archivos generados
clean:
	rm -f $(OUTFILE) ondas.vcd contador_synth.v 

.PHONY: all compile run wave clean
