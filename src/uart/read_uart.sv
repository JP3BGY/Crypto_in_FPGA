module read_uart
#(
    parameter freq = 347
)
(
    input RxD,
    input clk,
    input rst_n,
    output [7:0] data,
    output flag
);
reg [8:0] clk_cnt;
reg [8:0] first;
reg [7:0] data_reg;
reg [3:0] num;
reg read_flag;
reg fin_flag;
wire timing_flag;
assign timing_flag = (clk_cnt == first);
assign data = data_reg;
assign flag = fin_flag;
initial begin
    data_reg = 0;
    read_flag = 0;
    fin_flag = 1;
    num = 0;
end
always @(negedge RxD)
begin
    if(read_flag != 1)
        begin
            first = clk_cnt-1;
            read_flag = 1;
            fin_flag = 0;
            num = 0;
        end
end
always @(negedge timing_flag)
begin
    if(read_flag == 1)
    begin
        if(num != 8)
            data_reg[num[2:0]] = RxD;
        //else

        num = num + 1;
        if(num == 9)
        begin
            read_flag = 0;
            fin_flag = 1;
            num = 0;
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
