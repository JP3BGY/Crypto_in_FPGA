// Filename: aes_decrypt.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved


module aes_decrypt
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic clk,
    input logic rst_n,

    input logic [32*Nk-1:0] key,

    input logic load,
    input logic [127:0] ct,

    output logic [127:0] pt,
    output logic valid
);
wire [4:0] key_avail;
wire [127:0] k_sch;
aes_key_expand #(Nk) key_expand(.*);
aes_inv_cipher #(Nk) inv_cipher(.*);

endmodule: aes_decrypt
