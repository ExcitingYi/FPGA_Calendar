`timescale 1ns / 1ps
module disp_counter(
    input clk,
    input arstn,
    input[4:0] btns,
    output [31:0] disp_date,
    output stop_info,
    output [2:0] pos_info
    );

    //浠ヤ笅鏄鏃舵ā锟??
    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;
    wire c_D, c_M, c_Y; //杩涗綅淇″彿
    wire [1:0] exp_code;//鐗规畩鎯呭喌浠ｇ爜
    //浠ヤ笅鏄寜閿垽鏂拷??
    reg stop_state = 0;
    reg[2:0] dmy_btnena = 3'b001;
    always@(posedge btns[4]) begin 
        stop_state = !stop_state;  
    end
    assign stop_info = stop_state;

    always @(posedge btns[0] or posedge btns[1]) begin
        if (stop_state == 0) begin 
            dmy_btnena <= dmy_btnena;
        end
        else begin
            if (btns[0] == 1) 
                dmy_btnena <= {dmy_btnena[0],dmy_btnena[2:1]};   //鍙崇Щ
            else
                dmy_btnena <= {dmy_btnena[1:0],dmy_btnena[2]};   //宸︾Щ
        end
    end
    assign pos_info = {dmy_btnena[2]&stop_state,dmy_btnena[1]&stop_state,dmy_btnena[0]&stop_state};
    
    //鏃ヨ鏃跺櫒
    Dcounter dayCounter   (.clk(clk), .btns(btns[3:2]), .btn_ena(dmy_btnena[0]&stop_state), .arstn(arstn), .ena(!stop_state), .exp_code(exp_code), .c_D(c_D), .day_out(day));
    //鏈堣鏃跺櫒
    Mcounter monthCounter (.clk(clk), .btns(btns[3:2]), .btn_ena(dmy_btnena[1]&stop_state), .arstn(arstn), .ena(c_D), .c_M(c_M), .month_out(month));
    //骞磋鏃跺櫒
    Ycounter yearCounter  (.clk(clk), .btns(btns[3:2]), .btn_ena(dmy_btnena[2]&stop_state), .arstn(arstn), .ena(c_D&c_M), .c_Y(c_Y), .year_out(year));
    //鐗规畩鎯呭喌鍙嶉锟??
    ExceptFor except0     (.year(year), .month(month), .exp_code(exp_code));
    
    //浠ヤ笅鏄瘧鐮佹ā锟??
    //4*4浣嶅勾
    wire [3:0] YearHH;
    wire [3:0] YearHL;
    wire [3:0] YearLH;
    wire [3:0] YearLL;
    //2*4浣嶆湀
    wire [3:0] MonthH;
    wire [3:0] MonthL;
    //2*4浣嶆棩
    wire [3:0] DayH;
    wire [3:0] DayL;

    //鍗佽繘锟??->BCD鐮佽浆鎹㈡ā锟??
    assign YearHH = year/1000;
    assign YearHL = year/100 - YearHH*10;
    assign YearLH = year/10 - YearHL*10 - YearHH*100;
    assign YearLL = year%10;

    assign MonthH = month/10;
    assign MonthL = month%10;

    assign DayH = day/10;
    assign DayL = day%10;

    //8*4浣岯CD鐮佹棩鏈燂紝鏍煎紡YYYY.MM.DD
    assign disp_date = {
        YearHH, YearHL,
        YearLH, YearLL,
        MonthH, MonthL,
        DayH  , DayL
        };
    
endmodule
