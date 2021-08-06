`timescale 1ns / 1ps

module main_counter(
    input ini_clk,  //打拍专用时钟，原始的100MHz�?
    input clk,
    input arstn,
    input[4:0] btns,
    input load,
    input [31:0] load_date,
    output [31:0] disp_date,
    output stop_info, 
    output [2:0]pos_info
    );

    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;
    wire c_D, c_M, c_Y; 
    wire [1:0] exp_code;
    reg stop_state;
    reg[2:0] dmy_btnena;
    always@(posedge btns[4] or negedge arstn) begin 
        if (!arstn)
            stop_state <=0;
        else
            stop_state <= ~stop_state;  
    end
    assign stop_info = stop_state;

    reg btn0_d0,btn0_d1;
    always@(posedge ini_clk or negedge arstn) begin 
        if (!arstn) begin
            btn0_d0 <= 0;
            btn0_d1 <= 0;
        end
        else begin
            btn0_d0 <= btns[0];
            btn0_d1 <= btn0_d0;
        end
    end

    reg btn1_d0,btn1_d1;
    always@(posedge ini_clk or negedge arstn) begin 
        if (!arstn) begin
            btn1_d0 <= 0;
            btn1_d1 <= 0;
        end
        else begin
            btn1_d0 <= btns[1];
            btn1_d1 <= btn1_d0;
        end
    end

    always @(posedge ini_clk or negedge arstn) begin
        if (~arstn) 
            dmy_btnena <= 3'b001;
        else if (stop_info) begin
            if (btn0_d0&(!btn0_d1)) begin
                dmy_btnena <= {dmy_btnena[0],dmy_btnena[2:1]};   //闂佸憡鐟ョ�?��?�濈�?
            end
            else if (btn1_d0&(!btn1_d1)) begin
            dmy_btnena <= {dmy_btnena[1:0],dmy_btnena[2]};   //閻庡綊�?�绘俊鍥︾昂
            end
        end
        else begin
            dmy_btnena <= dmy_btnena;
            end
    end
    assign pos_info = {dmy_btnena[2]&stop_info,dmy_btnena[1]&stop_info,dmy_btnena[0]&stop_info};
    //闂佸�?鍟ㄩ崕鎾敇閹间礁绫嶉悹铏瑰劋閻濓拷
    Dcounter dayCounter   (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[0]), .arstn(arstn),
                    .ena(1'b1), .load(load), .data(load_date[7:0]),
                    .exp_code(exp_code), .c_D(c_D), .day_out(day));
    //闂佸�?鐗嗛悧鎰邦敇閹间礁绫嶉悹铏瑰劋閻濓拷
    Mcounter monthCounter (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[1]), .arstn(arstn),
                    .ena(c_D), .load(load), .data(load_date[15:8]),
                    .c_M(c_M), .month_out(month));
    //濡ょ姷鍋熼ˉ鎰邦敇閹间礁绫嶉悹铏瑰劋閻濓拷
    Ycounter yearCounter  (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[2]), .arstn(arstn),
                    .ena(c_D&c_M), .load(load), .data(load_date[31:16]),
                    .c_Y(c_Y), .year_out(year));
    //闂佺�?顨�?�～澶愭偩閳哄懎绠氶柛娑卞幖閺�??矂鏌涘▎蹇曅фい鈺婂弮閺佹捇鏁撻敓�???
    ExceptFor except0     (.year(year), .month(month), .exp_code(exp_code));
    
    //婵炲�?�?伴崕鎵箔閸涙潙鍙婃い鏍ㄧ箘濡差垶鏌ｉ鑽ゅ妽閼垛晠鏌ㄩ悤鍌涘?
    //4*4婵炶�?绲界粔鎾�?�閿燂拷
    wire [3:0] YearHH;
    wire [3:0] YearHL;
    wire [3:0] YearLH;
    wire [3:0] YearLL;
    //2*4婵炶�?绲界粔闈涳耿閳э�?
    wire [3:0] MonthH;
    wire [3:0] MonthL;
    //2*4婵炶�?绲界粔闈浳涢敓锟?
    wire [3:0] DayH;
    wire [3:0] DayL;

    //闂佸憡銇炲ù鍥╂崲�?椻偓閺佹捇鏁撻敓�???->BCD闂佹椿鍠曞ù鍥归崱娑樼闁靛繆鍩?娓氣偓閺佹捇鏁撻敓锟??
    assign YearHH = year/1000;
    assign YearHL = year/100 - YearHH*10;
    assign YearLH = year/10 - YearHL*10 - YearHH*100;
    assign YearLL = year%10;

    assign MonthH = month/10;
    assign MonthL = month%10;

    assign DayH = day/10;
    assign DayL = day%10;

    //8*4婵炶�?绲界�?姹闂佹椿鍠曢悞�??螞閳哄懎瀚�?�柣鏇炲?荤粈澶愭煛瀹ュ洤甯剁紒槌栨憰YYY.MM.DD
    assign disp_date = {
        YearHH, YearHL,
        YearLH, YearLL,
        MonthH, MonthL,
        DayH  , DayL
        };
    
endmodule