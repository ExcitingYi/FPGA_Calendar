`timescale 1ns / 1ps

module main_UART(
    input           sys_clk,            //�ⲿ100Mʱ��
    input           sys_rst_n,          //�ⲿ��λ�źţ�����Ч
    input           uart_rxd,           //UART���ն˿�
    output[31:0] datedata_out,
    output[23:0] timedata_out,
    output [3:0] led_cnt
    );

    //parameter define
    parameter  CLK_FREQ = 100_000000;         //����ϵͳʱ��Ƶ��
    parameter  UART_BPS = 115200;           //���崮�ڲ�����
    localparam  BPS_CNT  = CLK_FREQ/UART_BPS;       //Ϊ�õ�ָ�������ʣ�
                                                //��Ҫ��ϵͳʱ�Ӽ���BPS_CNT��

    //wire define   
    wire       uart_recv_done;              //UART�������
    wire [7:0] uart_recv_data;              //UART��������

    //���ڽ���ģ��     
    uart_recv #(                          
        .CLK_FREQ       (CLK_FREQ),         //����ϵͳʱ��Ƶ��
        .UART_BPS       (UART_BPS))         //���ô��ڽ��ղ�����
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
    //���Ĵ���
    reg uart_recv_done_d0, uart_recv_done_d1;
    //������ն˿�������(��ʼλ)���õ�һ��ʱ�����ڵ������ź�
    assign  StartFlag = (uart_recv_done_d0) & (~uart_recv_done_d1);    
    //�ӳ�����ʱ������
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

    //����16֡���ݣ���֡��ʼλ����1~8֡���ڣ���9֡У��λ����11~15֡ʱ��
    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt1 <= 4'd0;
        else if (StartFlag) begin
            case(cnt1)
                //��ʼ��־
                4'd0: begin
                    if (uart_recv_data==8'b0111_1110)
                        cnt1 <= 4'd1;
                end
                //�Ĵ���������
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

                //����λ
                4'd9 : begin
                    if (uart_recv_data!=8'b1000_1000)
                        cnt1 <= 4'd0;
                    else
                        cnt1 <= cnt1 + 1; 
                end

                //�Ĵ�ʱ������
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
                //����λ
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
