module write_uart
#(
    parameter freq = 347
)
(
    output reg TxD,
    input clk,
    input rst_n,
    input [7:0] data,
    input flag,
    output ready
);
reg [8:0] clk_cnt;
reg [8:0] first;
reg [3:0] num;
reg write_flag;
wire timing_flag;
assign timing_flag = (clk_cnt == first);
assign ready = !write_flag;
initial begin
    num = 0;
    TxD = 1;
    write_flag = 0;
end
always @(posedge flag)
begin
    if(write_flag != 1)
        begin
            first <= clk_cnt-1;
            write_flag <= 1;
            num <= 0;
        end
end
always @(negedge timing_flag)
begin
    if(write_flag == 1)
    begin
        if(num != 8)
            TxD <= data[num];
        else
            TxD <= data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7];

        num <= num + 1;
        if(num == 9)
        begin
            write_flag <= 0;
            num <= 0;
        end
    end
end
always @(posedge clk)
    begin
        clk_cnt <= clk_cnt + 1;
        if(clk_cnt == freq)
            clk_cnt <= 0;
    end
endmodule
