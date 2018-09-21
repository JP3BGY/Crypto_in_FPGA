// Filename: aes_inv_cipher.sv
//
// Copyright (c) 2013, Intel Corporation
// All rights reserved


module aes_inv_cipher
#(
    parameter Nk=4,
    parameter Nr=Nk+6
) (
    input logic clk,
    input logic rst_n,

    input [127:0] k_sch,
    input [4:0] key_avail,

    input logic load,
    input logic [127:0] ct,

    output logic [127:0] pt,
    output logic valid
);

logic [127:0] istate [0:1];

logic [4:0] valids;

always_comb pt = istate[0];
always_comb valid = (valids==Nr+1);
/*
// InvCipher (5.3)
`DFFEN(istate[Nr], AddRoundKey(ct, k_sch[Nr]), load, clk)
`DFF_ARN(valids[Nr], load, clk, rst_n, 1'b0)
genvar i;
generate
    for (i = (Nr-1); i > 0; --i) begin: round
        always_comb is_row[i] = InvShiftRows(istate[i+1]);
        always_comb is_box[i] = InvSubBytes(is_row[i]);
        always_comb ik_add[i] = AddRoundKey(is_box[i], k_sch[i]);
        `DFFEN(istate[i], InvMixColumns(ik_add[i]), valids[i+1], clk)
        `DFF_ARN(valids[i], valids[i+1], clk, rst_n, 1'b0)
    end: round
endgenerate

always_comb is_row[0] = InvShiftRows(istate[1]);
always_comb is_box[0] = InvSubBytes(is_row[0]);
`DFFEN(istate[0], AddRoundKey(is_box[0], k_sch[0]), valids[1], clk)
`DFF_ARN(valids[0], valids[1], clk, rst_n, 1'b0)
*/
function logic [31:0]
InvSubWord(logic [3:0] [7:0] w);
    return {ISBOX[w[3]], ISBOX[w[2]], ISBOX[w[1]], ISBOX[w[0]]};
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
InvSubBytes(logic [3:0] [31:0] state);
    return {
        InvSubWord(state[3]),
        InvSubWord(state[2]),
        InvSubWord(state[1]),
        InvSubWord(state[0])
    };
endfunction
function logic [127:0]
InvShiftRows(logic [3:0] [3:0] [7:0] state);
    return { state[0][3], state[1][2], state[2][1], state[3][0],
             state[3][3], state[0][2], state[1][1], state[2][0],
             state[2][3], state[3][2], state[0][1], state[1][0],
             state[1][3], state[2][2], state[3][1], state[0][0] };
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
function automatic logic [127:0]
InvMixColumns(logic [3:0] [31:0] state);
    return {
        Multiply(IMA, state[3]),
        Multiply(IMA, state[2]),
        Multiply(IMA, state[1]),
        Multiply(IMA, state[0])
    };
endfunction

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        valids <= 0;
        state[0] <= 0;
        state[1] <= 0;
    end
    else if(!load)begin
        valids <= 0;
        state[0] <= 0;
        state[1] <= 0;
    end
    else if(load)begin
        if(valids != Nr+1 && valids == key_avail)begin
            if(valids == 0)begin
                istate[0] <= InvSubBytes(InvShiftRows(AddRoundKey(ct,k_sch)));
            end
            else if(valids != Nr)begin
                istate[valids[0]]<=InvSubBytes(ShiftRows(InvMixColumns(AddRoundKey(istate[valids[0]^1],k_sch))));
            end
            else begin
                istate[valids[0]]<=AddRoundKey(state[valids[0]^1],k_sch);
            end
            valids <= valids + 1;
        end
    end
end

endmodule: aes_inv_cipher
