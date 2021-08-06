module top_file(
    //基本。
    input   clk,
    input   rst,
    input stop_key,
    input up,
    input down,
    input left,
    input right,
    //备忘
    input noteORdate,
    //时钟
    input dateORtime,
    //串口
    input uart_rxd,
    input matchOnline,
    //加速
    input speedUP,
    //显示
    output [7:0] seg_left,
    output [7:0] seg_right,
    output [7:0] an,
    //leds
    output noteORdate_led,
    output dateORtime_led,
    output matchOnline_led,
    output [3:0] led_cnt,
    output speedUP_led,
    output back,
    output [3:0] tixingdeng
    );
    wire [31:0] note_date;
    wire [31:0] disp_date;
    wire [31:0] disp_time;
    wire [23:0] part_time;
    reg [31:0] disp_data;
   
    wire [7:0]seg_data;
    wire clk_out;
    wire clk_btn;
    wire [4:0]btn_out;
    reg stop_info;
    reg [2:0]pos_info;
    assign seg_left  = seg_data;  
    assign seg_right = seg_data; 

    //串口同步数据
    wire [31:0] datedata_UART;
    wire [23:0] timedata_UART;
    
    //leds
    assign noteORdate_led = noteORdate;
    assign dateORtime_led = dateORtime;
    assign matchOnline_led = matchOnline;
    assign speedUP_led = speedUP;
        
    wire c_time;//时分秒模块进位信号

    time_div u_time_div(
        .clk_in(clk),
        .clk_out(clk_out),
        .clk_btn(clk_btn)
    );

    key_debounce u_key_debounce(
        .clk_btn(clk_btn),      
        .rst(rst),              //reset
        .stop_key(stop_key),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .btn_out(btn_out)      
    );

    wire [2:0] pos_info_main;
    wire stop_info_main;
    main_counter u_main_counter(
        .ini_clk(clk),
        .clk(c_time),
        .arstn(rst),
        .btns(btn_out),
        .load(matchOnline&&(led_cnt==4'd0)),
        .load_date(datedata_UART),
        .disp_date(disp_date),
        .stop_info(stop_info_main),
        .pos_info(pos_info_main)
    );

    hms_counter hms_cnt0(
        .clk(clk),
        .arstn(rst),
        .stop(1'b0),
        .load(matchOnline&&(led_cnt==4'd0)),
        .data(timedata_UART),
        .speedUP(speedUP),
        .disp_time(part_time),
        .c(c_time)
    );

    wire [2:0]pos_info_note;
    wire stop_info_note;
    note_module u_note_module(
        .note_key(noteORdate),
        .ini_clk(clk),
        .clk(1'b1),
        .arstn(rst),
        .btns(btn_out),
        .load(0),
        .load_date(32'b0),
        .disp_date(note_date),
        .stop_info(stop_info_note),
        .pos_info(pos_info_note)
    );

    assign disp_time = {8'hFF, part_time};//时间高位补非BCD码
    //切换日历/时钟功能, dateORtime=1显示时间，否则显示日期
    always @ (*) begin
        if (noteORdate) begin
            disp_data = note_date;
            pos_info = pos_info_note;
            stop_info = stop_info_note;
        end
        else if (dateORtime) begin
            disp_data = disp_date;
            pos_info = pos_info_main;
            stop_info = stop_info_main;
        end
        else begin
            disp_data = disp_time; 
            pos_info = pos_info_main;
            stop_info = stop_info_main;
        end
    end

    smg u_smg(
        .clk(clk),     
        .rst(rst), 
        .stop_state(stop_info),     
        .btn_pos(pos_info),       
        .true_date(disp_data),
        .point(8'b00010100),       
        .seg(seg_data),     
        .an(an)
    ); 

    //串口接收器
    main_UART Receivor0 (
        .sys_clk(clk),
        .sys_rst_n(rst),
        .uart_rxd(uart_rxd),
        .datedata_out(datedata_UART),
        .timedata_out(timedata_UART),
        .led_cnt(led_cnt)
    );
    assign back = uart_rxd;
    reg[3:0] regtixingdeng;
    always@(*) begin 
        if (disp_data == note_date) 
            regtixingdeng=4'b1111;
        else 
            regtixingdeng = 4'b0000;
    end
    assign tixingdeng = regtixingdeng;
    // test_led2bcd u_test_led2bcd(
    // .code(seg_data[6:0]),
    // .bcd_code(test_code)
    // );
    
endmodule
