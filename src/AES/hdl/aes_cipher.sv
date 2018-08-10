// Filename: aes_cipher.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved

`include "aes.svh"

module aes_cipher
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic clk,
    input logic rst_n,

    input logic [127:0] k_sch ,
    input key_avail,

    input logic load,
    input logic [127:0] pt,

    output logic [127:0] ct,
    output logic valid
);

logic [127:0] state [0:1] /*verilator public*/;

logic [3:0] valids /*verilator public*/;

logic [3:0] key_valids  /*verilator public*/;


always_comb ct = state[0];
always_comb valid = (valids==Nr+1);
/*
`DFFEN(state[0], AddRoundKey(pt, k_sch[0]), load, clk)
`DFF_ARN(valids[0], load, clk, rst_n, 1'b0)
genvar i;
generate
    for (i = 1; i < Nr; ++i) begin: round
        always_comb s_box[i] = SubBytes(state[i-1]);
        always_comb s_row[i] = ShiftRows(s_box[i]);
        always_comb m_col[i] = MixColumns(s_row[i]);
        `DFFEN(state[i], AddRoundKey(m_col[i], k_sch[i]), valids[i-1], clk)
        `DFF_ARN(valids[i], valids[i-1], clk, rst_n, 1'b0)
    end: round
endgenerate

always_comb s_box[Nr] = SubBytes(state[Nr-1]);
always_comb s_row[Nr] = ShiftRows(s_box[Nr]);
`DFFEN(state[Nr], AddRoundKey(s_row[Nr], k_sch[Nr]), valids[Nr-1], clk)
`DFF_ARN(valids[Nr], valids[Nr-1], clk, rst_n, 1'b0)
*/
function logic [31:0]
SubWord(logic [3:0] [7:0] w);
    return {SBOX[w[3]], SBOX[w[2]], SBOX[w[1]], SBOX[w[0]]};
endfunction
function logic [31:0]
RotWord(logic [3:0] [7:0] w);
    return {w[0], w[3], w[2], w[1]};
endfunction
function logic [127:0]
AddRoundKey(logic [3:0] [31:0] state, logic [3:0] [31:0] key);
    return {
        state[3] ^ key[3],
        state[2] ^ key[2],
        state[1] ^ key[1],
        state[0] ^ key[0]
    };
endfunction
function logic [127:0]
SubBytes(logic [3:0] [31:0] state);
    return {
        SubWord(state[3]),
        SubWord(state[2]),
        SubWord(state[1]),
        SubWord(state[0])
    };
endfunction
function logic [127:0]
ShiftRows(logic [3:0] [3:0] [7:0] state);
    return { state[2][3], state[1][2], state[0][1], state[3][0],
             state[1][3], state[0][2], state[3][1], state[2][0],
             state[0][3], state[3][2], state[2][1], state[1][0],
             state[3][3], state[2][2], state[1][1], state[0][0] };
endfunction
function logic [31:0]
Multiply(bit [15:0] a [4], logic [31:0] col);
    return {
        RowXCol(a[3], col),
        RowXCol(a[2], col),
        RowXCol(a[1], col),
        RowXCol(a[0], col)
    };
endfunction
function logic [7:0]
RowXCol(bit [3:0] [3:0] row, logic [3:0] [7:0] col);
    RowXCol = 8'h0;
    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 4; ++j)
            if (row[i][j]) RowXCol ^= xtime(col[3-i], j);
endfunction
function logic [7:0]
xtime(logic [7:0] b, int n);
    xtime = b;
    for (int i = 0; i < n; ++i)
        xtime = {xtime[6:0], 1'b0} ^ (8'h1b & {8{xtime[7]}});
endfunction
function logic [127:0]
MixColumns(logic [3:0] [31:0] state);
    return {
        Multiply(MA, state[3]),
        Multiply(MA, state[2]),
        Multiply(MA, state[1]),
        Multiply(MA, state[0])
    };
endfunction

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        valids = 0;
        key_valids = 0;
        state[0] = 0;
        state[1] = 0;
        k_sch[0] = 0;
        k_sch[1] = 0;
        key_pos = 0;
    end
    else if(!load)begin
        valids = 0;
        key_valids = 0;
        state[0] = 0;
        state[1] = 0;
        k_sch[0] = 0;
        k_sch[1] = 0;
        key_pos = 0;
    end
    else if(load)begin
        if(valids != Nr+1 && valids == key_avail)begin
            if(valids == 0)begin
                state[0] <= AddRoundKey(pt,k_sch);
            end
            else if(valids != Nr)begin
                state[valids[0]]<=AddRoundKey(MixColumns(ShiftRows(SubBytes(state[valids[0]^1]))),k_sch);
            end
            else begin
                state[valids[0]]<=AddRoundKey(ShiftRows(SubBytes(state[valids[0]^1])),k_sch);
            end
            valids <= valids + 1;
        end
    end
end

endmodule: aes_cipher
