// Filename: aes_key_expand.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved

`include "flops.svh"
`include "aes.svh"
module aes_key_expand
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic [32*Nk-1:0] key,
    output logic [127:0] k_sch [0:Nr]
);
/* verilator lint_off UNOPTFLAT */
logic [31:0] temp [4*(Nr+1)]/*verilator public*/;
/* verilator lint_on UNOPTFLAT */
genvar i;
generate
for (i = 0; i < Nk; ++i) begin :key_ex
        always_comb
            temp[i] = key[32*i+:32];
    end

    for (i = Nk; i < 4*(Nr+1); ++i) begin :main_loop
        if (i % Nk == 0)
            /* verilator lint_off ALWCOMBORDER */
            always_comb
                temp[i] = temp[i-Nk]
                        ^ SubWord(RotWord(temp[i-1]))
                        ^ {24'h0, RCON[i/Nk]};
            /* verilator lint_on ALWCOMBORDER */
        else if (Nk > 6 && (i % Nk == 4))
            always_comb
                temp[i] = temp[i-Nk] ^ SubWord(temp[i-1]);
        else
            always_comb
                temp[i] = temp[i-Nk] ^ temp[i-1];
    end
endgenerate

generate
for (i = 0; i <= Nr; ++i) begin :little_endian
        always_comb
            k_sch[i] = {temp[4*i+3], temp[4*i+2], temp[4*i+1], temp[4*i+0]};
    end
endgenerate

endmodule: aes_key_expand
