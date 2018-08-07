
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
