.PHONY: sim_aes
sim_aes: src/test/test_aes_encrypt.cpp src/AES/hdl/*
	verilator --trace --trace-structs --trace-params --trace-underscore --trace-depth 10 -cc -I./src/AES/include -y ./src/AES/hdl  src/AES/hdl/aes_encrypt.sv --exe src/test/test_aes_encrypt.cpp
	cd obj_dir/ && make -f Vaes_encrypt.mk
