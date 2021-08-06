`timescale 1ns / 1ps

module main_UART(
    input           sys_clk,            //外部100M时钟
    input           sys_rst_n,          //外部复位信号，低有效
    input           uart_rxd,           //UART接收端口
    output[31:0] datedata_out,
    output[23:0] timedata_out,
    output [3:0] led_cnt
    );

    //parameter define
    parameter  CLK_FREQ = 100_000000;         //定义系统时钟频率
    parameter  UART_BPS = 115200;           //定义串口波特率
    localparam  BPS_CNT  = CLK_FREQ/UART_BPS;       //为得到指定波特率，
                                                //需要对系统时钟计数BPS_CNT次

    //wire define   
    wire       uart_recv_done;              //UART接收完成
    wire [7:0] uart_recv_data;              //UART接收数据

    //串口接收模块     
    uart_recv #(                          
        .CLK_FREQ       (CLK_FREQ),         //设置系统时钟频率
        .UART_BPS       (UART_BPS))         //设置串口接收波特率
    u_uart_recv(                 
        .sys_clk        (sys_clk), 
        .sys_rst_n      (sys_rst_n),
        
        .uart_rxd       (uart_rxd),
        .uart_done      (uart_recv_done),
        .uart_data      (uart_recv_data)
        );
    
    reg [3:0] cnt1; //2^4=16
    reg [31:0] datedata;
    reg [23:0] timedata;

    wire StartFlag;
    //打拍处理
    reg uart_recv_done_d0, uart_recv_done_d1;
    //捕获接收端口上升沿(起始位)，得到一个时钟周期的脉冲信号
    assign  StartFlag = (uart_recv_done_d0) & (~uart_recv_done_d1);    
    //延迟两个时钟周期
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n) begin 
            uart_recv_done_d0 <= 1'b0;
            uart_recv_done_d1 <= 1'b0;          
        end
        else begin
            uart_recv_done_d0  <= uart_recv_done;                   
            uart_recv_done_d1  <= uart_recv_done_d0;
        end
    end

    //接收16帧数据，首帧起始位，第1~8帧日期，第9帧校验位，第11~15帧时间
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt1 <= 4'd0;
        else if (StartFlag) begin
            case(cnt1)
                //启始标志
                4'd0: begin
                    if (uart_recv_data==8'b0111_1110)
                        cnt1 <= 4'd1;
                end
                //寄存日期数据
                4'd8 : begin
                    datedata[3:0] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
                4'd7 : begin
                    datedata[7:4] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd6 : begin
                    datedata[11:8] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd5 : begin
                    datedata[15:12] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
                4'd4 : begin
                    datedata[19:16] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd3 : begin
                    datedata[23:20] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
                4'd2 : begin
                    datedata[27:24] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
                4'd1 : begin
                    datedata[31:28] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end

                //检验位
                4'd9 : begin
                    if (uart_recv_data!=8'b1000_1000)
                        cnt1 <= 4'd0;
                    else
                        cnt1 <= cnt1 + 1; 
                end

                //寄存时间数据
                4'd15 : begin
                    timedata[3:0] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd14 : begin
                    timedata[7:4] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd13 : begin
                    timedata[11:8] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd12 : begin
                    timedata[15:12] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end 
                4'd11 : begin
                    timedata[19:16] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
                //结束位
                4'd10 : begin
                    timedata[23:20] <= uart_recv_data[3:0];
                    cnt1 <= cnt1 + 1;
                end
            endcase
        end
    end
    
    assign datedata_out = datedata;
    assign timedata_out = timedata;

    assign led_cnt = cnt1;

endmodule
