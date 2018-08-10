`include "aes.svh"

module aes
(
    input logic clk,
    input logic rst_n,
    input btn,
	 input btn2,
	 input btn3,
    output [7:0] led,
	 output flag,
	 output load,
	 output [7:0] seg_led [0:7]
);

reg [1:0] pos1;
reg [3:0] pos2;
wire [31:0] segment_led_buf;
wire [7:0] in[15:0];
wire [127:0] inp;
wire [127:0] outp;
wire [7:0] out[15:0];
wire [4*8*4-1:0] key;
wire btn_out;
wire btn2_out;
wire btn3_out;

assign key = 128'hfefd00d583ef87e9b7e6ab3a655f68db;
assign inp = {in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7],in[8],in[9],in[10],in[11],in[12],in[13],in[14],in[15]};
//assign outp = {out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7],out[8],out[9],out[10],out[11],out[12],out[13],out[14],out[15]};

aes_encrypt #(4) encrypt(.clk(clk),.rst_n(rst_n),.key(key),.load(load),.pt(inp),.ct(outp),.valid(flag));

chattering_remover chat_rem(.clk(clk),.rst(rst_n),.key_in(btn),.key_out(btn_out));
chattering_remover chat_rem2(.clk(clk),.rst(rst_n),.key_in(btn2),.key_out(btn2_out));
chattering_remover chat_rem3(.clk(clk),.rst(rst_n),.key_in(btn3),.key_out(btn3_out));

genvar i;
generate
for(i = 5;i < 21; i++) begin :data
    assign in[i-5] = i;
end
endgenerate

generate
    for (i = 0; i < 8; i++) begin :segment_led
        seg_led segment(.data(segment_led_buf[i*4+:4]),.seg(seg_led[7-i]));
    end
endgenerate

assign segment_led_buf = outp [pos1*32+31-:32];
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        load <= 0;
        pos1 <= 3;
        pos2 <= 0;
        led <= in[0];
    end
    else if(!btn2_out)
    begin
        load <= load^1;
    end
    else if(!btn_out)
    begin
        if(pos2 == 10)pos2 <= 0;
        else pos2 <= pos2 + 1;
    end
    else if(!btn3_out)
    begin
        pos1 <= pos1 - 1;
    end
end
endmodule
