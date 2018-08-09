// Filename: aes_cipher.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved

`include "flops.svh"

module aes_cipher
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic clk,
    input logic rst_n,

    input logic [127:0] k_sch [0:Nr],

    input logic load,
    input logic [127:0] pt,

    output logic [127:0] ct,
    output logic valid
);

logic [127:0] state [0:1];

logic [0:3] valids;

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
const bit [7:0] SBOX [256] = '{
    8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
    8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
    8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
    8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
    8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
    8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
    8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
    8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
    8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
    8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
    8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
    8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
    8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
    8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
    8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
    8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
};
const bit [15:0] MA [4] = '{16'h2311, 16'h1231, 16'h1123, 16'h3112};
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

always @(*) begin
    if(!rst_n | !load)begin
        valids <= 0;
    end
    else if(load)begin
        if(valids != Nr+1)begin
            if(valids == 0)begin
                state[0] <= AddRoundKey(pt,k_sch[0]);
            end
            else if(valids != Nr)begin
                state[valids[0]^1]<=AddRoundKey(MixColumns(ShiftRows(SubBytes(state[valids[0]]))),k_sch[valids]);
            end
            else begin
                state[valids[0]^1]<=AddRoundKey(ShiftRows(SubBytes(state[valids[0]])),k_sch[valids]);
            end
            valids <= valids + 1;
        end
    end
end

endmodule: aes_cipher
