// Filename: aes_key_expand.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved

`include "aes.svh"
module aes_key_expand
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic clk,
    input logic rst_n,

    input logic [32*Nk-1:0] key,
    input logic load,

    output [127:0] k_sch ,
    output logic [4:0] key_avail
);
logic [32*Nk-1:0] state_keys [0:1]/*verilator public*/;
logic [(Nk+2)/4-1:0] key_pos/*verilator public*/;
logic [3:0] key_round;
wire [128*(Nk/2)-1:0] key_all;
wire [127:0] k_schs [0:Nk/2-1];
assign k_sch = k_schs[key_pos];
assign key_all = {state_keys[1],state_keys[0]};
genvar i;
generate
    for(i=0;i<Nk/2;i++)begin
        assign k_schs[i] = key_all[128*i+:128];
    end
endgenerate
function logic [31:0]
RotWord(logic [3:0] [7:0] w);
    return {w[0], w[3], w[2], w[1]};
endfunction
function logic [31:0]
SubWord(logic [3:0] [7:0] w);
    return {SBOX[w[3]], SBOX[w[2]], SBOX[w[1]], SBOX[w[0]]};
endfunction
function logic [32*Nk-1:0] key_expansion(logic [32*Nk-1:0] key,logic [3:0] round);
    reg [31:0] temp [0:Nk*2-1];
    begin
        for(int i = 0;i < Nk;i++)
            temp[i] = key[i*32+:32];
        for(int i = Nk;i < Nk*2;i++)begin
            if (i == Nk)
                temp[i] = temp[i-Nk]
                        ^ SubWord(RotWord(temp[i-1]))
                        ^ {24'h0, RCON[round]};
            else if (Nk > 6 && (i % Nk == 4))
                temp[i] = temp[i-Nk] ^ SubWord(temp[i-1]);
            else
                temp[i] = temp[i-Nk] ^ temp[i-1];
        end
        for(int i = 0;i < Nk;i++)
            key_expansion [i*32+:32] = temp[i+Nk];
    end
endfunction
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        key_avail <= 16;
        key_pos <= 0;
        state_keys[0] <= 0;
        state_keys[1] <= 0;
        key_round <= 0;
    end
    else if(!load)begin
        key_avail <= 16;
        key_pos <= 0;
        state_keys[0] <= 0;
        state_keys[1] <= 0;
        key_round <= 0;
    end
    else if(load)begin
        if(key_avail != 15)begin
            if(key_avail == 16)begin
                state_keys[0] <= key;
                state_keys[1] <= key_expansion(key,key_round+1);
                key_pos <= 0;
                key_avail <= 0;
                key_round <= 1;
            end
            else begin
                /* verilator lint_off WIDTH */
                if(key_pos == (Nk/4-1))begin
                    state_keys[0] <= key_expansion(state_keys[1],key_round + 1);
                    key_round <= key_round + 1;
                    key_pos <= key_pos + 1;
                end
                else if(key_pos == (Nk/2-1))begin
                    state_keys[1] <= key_expansion(state_keys[0],key_round + 1);
                    key_round <= key_round + 1;
                    key_pos <= 0;
                end
                /* verilator lint_on WIDTH */
                else begin
                    key_pos <= key_pos + 1;
                end
                key_avail <= key_avail + 1;
            end
        end
    end
end

///* verilator lint_off UNOPTFLAT */
//logic [31:0] temp [4*(Nr+1)]/*verilator public*/;
///* verilator lint_on UNOPTFLAT */
//genvar i;
//generate
//for (i = 0; i < Nk; ++i) begin :key_ex
//        always_comb
//            temp[i] = key[32*i+:32];
//    end
//
//    for (i = Nk; i < 4*(Nr+1); ++i) begin :main_loop
//        if (i % Nk == 0)
//            /* verilator lint_off ALWCOMBORDER */
//            always_comb
//                temp[i] = temp[i-Nk]
//                        ^ SubWord(RotWord(temp[i-1]))
//                        ^ {24'h0, RCON[i/Nk]};
//            /* verilator lint_on ALWCOMBORDER */
//        else if (Nk > 6 && (i % Nk == 4))
//            always_comb
//                temp[i] = temp[i-Nk] ^ SubWord(temp[i-1]);
//        else
//            always_comb
//                temp[i] = temp[i-Nk] ^ temp[i-1];
//    end
//endgenerate
//
//generate
//for (i = 0; i <= Nr; ++i) begin :little_endian
//        always_comb
//            k_sch[i] = {temp[4*i+3], temp[4*i+2], temp[4*i+1], temp[4*i+0]};
//    end
//endgenerate
//
endmodule: aes_key_expand
