`include "flops.svh"
`include "aes.svh"

module divider(clk, rst, clkout);
        input clk, rst;
        output clkout;

        reg [15:0] counter;

        always @(posedge clk or negedge rst) begin
                if(!rst) counter <= 16'b0;
                else counter <= counter + 16'b1;
        end

        assign clkout = counter[15];
endmodule

module chattering_remover(clk, rst, key_in, key_out);
        input clk, rst;
        input [17:0] key_in;
        output [17:0] key_out;
        reg [17:0] key_out;
		  wire clk_divided;

        always @(posedge clk_divided) key_out <= key_in;

        divider div(clk, rst, clk_divided);
endmodule



module aes
(
    input logic clk,
    input logic rst_n,
    input btn,
	 input btn2,
	 input btn3,
    output [7:0] led,
	 output flag,
	 output load
);

reg [3:0] pos;
wire [7:0] in[16];
wire [127:0] inp;
wire [127:0] outp;
wire [7:0] out[16];
wire [4*8*4-1:0] key;
wire btn_out;

assign key = 128'hfefd00d583ef87e9b7e6ab3a655f68db;
assign inp = {in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7],in[8],in[9],in[10],in[11],in[12],in[13],in[14],in[15]};
assign outp = {out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7],out[8],out[9],out[10],out[11],out[12],out[13],out[14],out[15]};

aes_encrypt #(4) encrypt(.clk(ckl),.rst_n(rst_n),.key(key),.load(load),.pt(inp),.ct(outp),.valid(flag));

chattering_remover chat_rem(.clk(clk),.rst(rst_n),.key_in(btn),.key_out(btn_out));
chattering_remover chat_rem2(.clk(clk),.rst(rst_n),.key_in(btn2),.key_out(btn2_out));
chattering_remover chat_rem3(.clk(clk),.rst(rst_n),.key_in(btn3),.key_out(btn3_out));


genvar i;
generate
for(i = 5;i < 21; i++) begin :data
    assign in[i-5] = i;
end
endgenerate

initial
begin
	led <= in[0];
	load <= 0;
end

always @(negedge btn_out or negedge btn2_out or negedge btn3_out or negedge rst_n)
begin
    if(!rst_n)
    begin
        load <= 0;
        pos <= 0;
		  led <= in[0];
    end
	 else if(!btn2_out)
	 begin
	     load <= load^1;
	 end
    else if(!btn_out)
    begin
        pos = pos + 1;
        led = out[pos];
    end
	 else if(!btn3_out)
	 begin
	     pos = pos + 1;
		  led = in[pos];
	 end
end


endmodule


