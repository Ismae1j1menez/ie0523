IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
OUTFILE = ondas
VERILOG_FILES = Testbench.v

# Instrucciones
all:
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
	rm -f $(OUTFILE) ondas.vcd

.PHONY: all compile run wave clean
