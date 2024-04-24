# Repositorio de Tareas del Curso IE-0523 - Circuitos Digitales 2

Este repositorio alberga las tareas correspondientes al curso de Circuitos Digitales 2 (IE-0523), las cuales incluyen una serie de diseños y simulaciones de circuitos digitales complejos y protocolos de comunicación en verilog. Cada tarea está organizada en su propia carpeta y contiene todos los archivos necesarios para la síntesis y simulación de los circuitos.

## Organización de las Tareas

Dentro del repositorio, las tareas están estructuradas de la siguiente manera:

### Tarea 1
- `Contador4b.v` y `Contador16b.v`: Contienen la implementación de un contador digital de 4 y 16 bits, respectivamente.
- `Testbench.v`: Banco de pruebas para el contador.
- `Tester.v`: Script de prueba para la verificación del contador.
- `Makefile`: Utilizado para ejecutar simulaciones y limpiar archivos ejecutables o innecesarios.

### Tarea 2
- `Contador4b.v`, `Contador16b.v`, y `Contador.ys`: Archivos de Verilog y scripts de síntesis para el contador de 16 bits con submódulos de 4 bits.
- `Testbench.v` y `Tester.v`: Scripts para pruebas y simulaciones.
- `Makefile`: Facilita la compilación y limpieza del proyecto.

### Tarea 3
- `Controlador_banco.v`: Diseño de una máquina de estados que simula las operaciones de un banco.
- `Banco.ys`: Script de síntesis para la máquina de estados.
- `Testbench.v` y `Tester.v`: Scripts de prueba para la máquina de estados.
- `Makefile`: Permite la ejecución de simulaciones y la limpieza del entorno.

### Tarea 4
- `I2C_master.v` y `I2C_slave.v`: Implementación de la lógica maestro-esclavo del protocolo I2C.
- `Testbench.v` y `Tester.v`: Bancos de pruebas para el protocolo I2C.
- `Makefile`: Automatiza tareas de síntesis y limpieza de los módulos I2C.

### Tarea 5
- `Master.v` y `Slave.v`: Implementación de los módulos maestro y esclavo del protocolo SPI.
- `Testbench.v` y `Tester.v`: Banco de pruebas y scripts para la simulación del protocolo SPI.
- `Makefile`: Para compilar, ejecutar y limpiar los proyectos SPI.

Cada carpeta de tarea incluye una biblioteca de celdas CMOS (`cmos_cells.lib`) y un archivo de descripción de celdas CMOS (`cmos_cells.v`) necesarios para la simulación y síntesis de los circuitos.

## Uso de Makefile

En cada carpeta de tarea se proporciona un `Makefile` para simplificar las tareas de compilación y limpieza

Estos Makefiles están preconfigurados para trabajar con los archivos específicos de cada tarea, simplificando el proceso de desarrollo y prueba de los circuitos digitales.


