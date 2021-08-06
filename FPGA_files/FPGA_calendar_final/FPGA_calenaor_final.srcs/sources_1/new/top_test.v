`timescale 1ns / 1ps

module top_test(
    input   clk,
    input   rst,
    input stop_key,
    input up,
    input down,
    input left,
    input right,
    output [7:0] seg_left,
    output [7:0] seg_right,
    output [7:0] an,
    output [3:0] test_code
    );
    
    wire [7:0] seg_out;
    assign seg_left = seg_out;
    assign seg_right = seg_out;
    smg s(
    .clk(clk),
    .rst(rst),
    .stop_state(0),      //是否暂停�??
    .btn_pos(0),    //闪烁位置�??
    .true_date(32'h19491001), //显示时间�??
    .point(8'b00010100),   
    .seg(seg_out),
    .an(an)
	);
    
endmodule
