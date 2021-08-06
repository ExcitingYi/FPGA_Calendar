// 直接从main_counter里复制过来修改。
module note_module(
    input note_key, //从R2接过来的note信号。
    input ini_clk,  //100MHz的原始时钟。
    input clk,      //1Hz的分频后的时钟。 
    input arstn,
    input[4:0] btns,            //按键，由key_debounce输出得到。
    input load,                 //装载初值的使能信号。
    input [31:0] load_date,     //装的初值。
    output [31:0] disp_date,    //显示的值。最后输出的是bcd?。
    output stop_info,           //停止信息。
    //设计之初是想搞停止的，但感觉对日历来说停止实在是没啥用，这个后来就变成了"时间调整的使能位"。
    output [2:0]pos_info        //按键所在位置。（调年，还是月，还是日？）
    );
    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;
    wire c_D, c_M, c_Y;         //进位信息。
    wire [1:0] exp_code;        //大小月，闰年二月信息。
    reg stop_state;             //就是上面的stop_info
    reg[2:0] dmy_btnena;        //就是上面的pos_info，但有点不一样。
    
    //"时间调整"使能位。
    // always@(posedge btns[4] or negedge arstn) begin 
    //     if (!arstn)
    //         stop_state <=0;
    //     else
    //         stop_state <= ~stop_state;  
    // end
    // assign stop_info = stop_state;
    assign stop_info = note_key;

    //打拍。
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

    //刚开始不是ini_clk检测的。是直接用posedge btn[0]这个检测，但是信号非常非常不稳定。
    always @(posedge ini_clk or negedge arstn) begin
        if (~arstn) 
            dmy_btnena <= 3'b001;
        else if (stop_info) begin
            if (btn0_d0&(!btn0_d1)) begin
                dmy_btnena <= {dmy_btnena[0],dmy_btnena[2:1]};   //循环右移。
            end
            else if (btn1_d0&(!btn1_d1)) begin
            dmy_btnena <= {dmy_btnena[1:0],dmy_btnena[2]};   //循环左移。
            end
        end
        else begin
            dmy_btnena <= dmy_btnena;
            end
    end
    assign pos_info = {dmy_btnena[2]&stop_info,dmy_btnena[1]&stop_info,dmy_btnena[0]&stop_info};

    Dcounter dayCounter   (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[0]), .arstn(arstn),
                    .ena(1'b1), .load(load), .data(load_date[7:0]),
                    .exp_code(exp_code), .c_D(c_D), .day_out(day));
 
    Mcounter monthCounter (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[1]), .arstn(arstn),
                    .ena(c_D), .load(load), .data(load_date[15:8]),
                    .c_M(c_M), .month_out(month));

    Ycounter yearCounter  (.ini_clk(ini_clk), .clk(clk), .btns(btns[3:2]),
                    .btn_ena(pos_info[2]), .arstn(arstn),
                    .ena(c_D&c_M), .load(load), .data(load_date[31:16]),
                    .c_Y(c_Y), .year_out(year));
 
    ExceptFor except0     (.year(year), .month(month), .exp_code(exp_code));
    

    //转化位BCD码。
    wire [3:0] YearHH;
    wire [3:0] YearHL;
    wire [3:0] YearLH;
    wire [3:0] YearLL;

    wire [3:0] MonthH;
    wire [3:0] MonthL;

    wire [3:0] DayH;
    wire [3:0] DayL;

 
    assign YearHH = year/1000;
    assign YearHL = year/100 - YearHH*10;
    assign YearLH = year/10 - YearHL*10 - YearHH*100;
    assign YearLL = year%10;

    assign MonthH = month/10;
    assign MonthL = month%10;

    assign DayH = day/10;
    assign DayL = day%10;

 
    assign disp_date = {
        YearHH, YearHL,
        YearLH, YearLL,
        MonthH, MonthL,
        DayH  , DayL
        };
    
endmodule

