module seg_led(
    input [3:0] data,
    output [7:0] seg
);
assign seg = (data==0)?8'b11111100:
             (data==1)?8'b01100000:
             (data==2)?8'b11011010:
             (data==3)?8'b11110010:
             (data==4)?8'b01100110:
             (data==5)?8'b10110110:
             (data==6)?8'b10111110:
             (data==7)?8'b11100000:
             (data==8)?8'b11111110:
             (data==9)?8'b11110110:
             (data==10)?8'b11101110:
             (data==11)?8'b00111110:
             (data==12)?8'b00011010:
             (data==13)?8'b01111010:
             (data==14)?8'b10011110:
             8'b10001110;
endmodule
