.PHONY: sim_aes
sim_aes: src/test/test_aes_encrypt.cpp src/AES/hdl/*
	verilator --trace --trace-structs --trace-params --trace-underscore --trace-depth 10 -cc -I./src/AES/include -y ./src/AES/hdl  src/AES/hdl/aes_encrypt.sv --exe src/test/test_aes_encrypt.cpp
	cd obj_dir/ && make -f Vaes_encrypt.mk && ./Vaes_encrypt
.PHONY: sim_uart_read
sim_uart_read: src/test/test_read_uart.cpp src/uart/read_uart.sv
	verilator --trace --trace-structs --trace-params --trace-underscore --trace-depth 10 -cc -I./src/AES/include  src/uart/read_uart.sv --exe src/test/test_read_uart.cpp
	cd obj_dir/ && make -f Vread_uart.mk && ./Vread_uart

.PHONY: sim_uart_write
sim_uart_write: src/test/test_write_uart.cpp src/uart/write_uart.sv
	verilator --trace --trace-structs --trace-params --trace-underscore --trace-depth 10 -cc -I./src/AES/include  src/uart/write_uart.sv --exe src/test/test_write_uart.cpp
	cd obj_dir/ && make -f Vwrite_uart.mk && ./Vwrite_uart
