module aes
(
    input logic clk,
    input logic rst_n,
    input btn,
    output [31:0] seg_led
);

reg flag;
reg load;
reg [1:0] pos;
wire [7:0] in[16];
wire [127:0] inp;
wire [127:0] outp;
wire [7:0] out[16];
wire [4*8*4-1:0] key;

assign key = 128'hfefd00d583ef87e9b7e6ab3a655f68db;
assign inp = {in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7],in[8],in[9],in[10],in[11],in[12],in[13],in[14],in[15]};
assign outp = {out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7],out[8],out[9],out[10],out[11],out[12],out[13],out[14],out[15]};


aes_encrypt #(4) encrypt(.clk(ckl),.rst_n(rst_n),.key(key),.load(load),.pt(inp),.ct(outp),.valid(flag));

generate
for(genvar i = 0;i < 16; i++) begin :data
    assign in[i] = i;
end
endgenerate
always @(flag or negedge btn or negedge rst_n)
begin
    if(!rst_n)
    begin
        load <= 0;
        pos <= 0;
    end
    else if(flag)
    begin
        if(!btn)
        begin
            pos = pos + 1;
            seg_led = {in[pos*4+0],in[pos*4+1],in[pos*4+2],in[pos*4+3]};
        end
    end
end



endmodule
