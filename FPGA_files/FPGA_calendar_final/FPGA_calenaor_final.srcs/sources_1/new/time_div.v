//鏃堕敓鎺ュ嚖鎷烽閿熸枻鎷?
module time_div(clk_in,clk_out,clk_btn);
	input clk_in;
	output reg clk_out=0;
    output reg clk_btn=0;
 	reg[26:0] clk_div_cnt=0;
    reg[19:0] clk_div_cnt2=0;
        always @ (posedge clk_in)
        begin
            if (clk_div_cnt==27'd49999999)
            begin
                clk_out <= ~clk_out;
                clk_div_cnt<=0;
            end
            else
                clk_div_cnt<=clk_div_cnt+1;
        end
        always @(posedge clk_in)
        begin
            if (clk_div_cnt2 == 20'd999999) begin
               clk_btn<=~clk_btn;
               clk_div_cnt2 <= 0;
            end
            else 
                clk_div_cnt2 <= clk_div_cnt2 + 1;
       end
 endmodule

//閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹閿??24h閿熶茎鈽呮嫹
//module time_div(clk_in,clk_out);
//	input clk_in;
//	output reg clk_out=0;
// 	reg[26:0] clk_div_cnt=0;
// 	reg[16:0] temp_div=0;
//        always @ (posedge clk_in)
//        begin
//            if (clk_div_cnt==99999999)
//            begin
//                temp_div = temp_div + 1;
//                clk_div_cnt=0;
//            end
//            else begin
//                clk_div_cnt=clk_div_cnt+1;
//            end
//            if (temp_div == 86400/2)
//            begin
//                clk_out = !clk_out;
//                clk_div_cnt = 0;
//                temp_div = 0;
//            end
//       end
// endmodule