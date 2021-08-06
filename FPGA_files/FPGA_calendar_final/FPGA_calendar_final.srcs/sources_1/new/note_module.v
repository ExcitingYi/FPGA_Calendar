// ֱ�Ӵ�main_counter�︴�ƹ����޸ġ�
module note_module(
    input note_key, //��R2�ӹ�����note�źš�
    input ini_clk,  //100MHz��ԭʼʱ�ӡ�
    input clk,      //1Hz�ķ�Ƶ���ʱ�ӡ� 
    input arstn,
    input[4:0] btns,            //��������key_debounce����õ���
    input load,                 //װ�س�ֵ��ʹ���źš�
    input [31:0] load_date,     //װ�ĳ�ֵ��
    output [31:0] disp_date,    //��ʾ��ֵ������������bcd?��
    output stop_info,           //ֹͣ��Ϣ��
    //���֮�������ֹͣ�ģ����о���������˵ֹͣʵ����ûɶ�ã���������ͱ����"ʱ�������ʹ��λ"��
    output [2:0]pos_info        //��������λ�á������꣬�����£������գ���
    );
    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;
    wire c_D, c_M, c_Y;         //��λ��Ϣ��
    wire [1:0] exp_code;        //��С�£����������Ϣ��
    reg stop_state;             //���������stop_info
    reg[2:0] dmy_btnena;        //���������pos_info�����е㲻һ����
    
    //"ʱ�����"ʹ��λ��
    // always@(posedge btns[4] or negedge arstn) begin 
    //     if (!arstn)
    //         stop_state <=0;
    //     else
    //         stop_state <= ~stop_state;  
    // end
    // assign stop_info = stop_state;
    assign stop_info = note_key;

    //���ġ�
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

    //�տ�ʼ����ini_clk���ġ���ֱ����posedge btn[0]�����⣬�����źŷǳ��ǳ����ȶ���
    always @(posedge ini_clk or negedge arstn) begin
        if (~arstn) 
            dmy_btnena <= 3'b001;
        else if (stop_info) begin
            if (btn0_d0&(!btn0_d1)) begin
                dmy_btnena <= {dmy_btnena[0],dmy_btnena[2:1]};   //ѭ�����ơ�
            end
            else if (btn1_d0&(!btn1_d1)) begin
            dmy_btnena <= {dmy_btnena[1:0],dmy_btnena[2]};   //ѭ�����ơ�
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
    

    //ת��λBCD�롣
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

