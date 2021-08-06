`timescale 1ns / 1ps

module hms_counter(
    input clk,
    input arstn,
    input stop,
    input load,
    input [23:0] data,
    input speedUP,
    output[23:0] disp_time,
    output c
    );

    reg [19:0] divclk_cnt;
    reg divclk;
    reg[3:0] sec_l;
    reg[3:0] sec_h;
    reg[3:0] min_l;
    reg[3:0] min_h;
    reg[3:0] hour_l;
    reg[3:0] hour_h;

    //�����ü���ģ��
    parameter MAXCNT = 1000000;
    parameter MINCNT = 1156; 
    reg [19:0] time_cnt;
    always @ (*) begin
        if (speedUP)
            time_cnt = MINCNT;
        else
            time_cnt = MAXCNT;
    end

    assign disp_time = {hour_h, hour_l, min_h, min_l, sec_h, sec_l};
    //输入时钟10MHZ，目的时�?100Hz，�?�先实现1M分�??
    always @ (posedge clk or negedge arstn) begin
        if(!arstn) begin
            divclk <= 1'b0;
            divclk_cnt <= 20'd0;
        end
        //偶数分�?�（1M分�?�），上�?1M/2-1
        else if (divclk_cnt==time_cnt/2-1'b1) begin
            divclk <= ~divclk;
            divclk_cnt <= 20'd0;
        end
        else begin
            divclk_cnt <= divclk_cnt + 1'b1;
        end
    end

    //暂停功能�?
    reg state;
    reg stop_now, stop_last;
    always @ (posedge clk or negedge arstn) begin
        stop_now <= stop;
        stop_last <= stop_now;
        if (!arstn)
            state <= 1'b0;
        else if ({stop_last, stop_now}==2'b01)
            state <= state^stop;
        else
            state <= state;
    end

    always @ (posedge divclk or negedge arstn or posedge load) begin
        if (!arstn)
            {hour_h, hour_l,
             min_h, min_l,
             sec_h, sec_l} <= 24'h15_00_00;
        else if (load)
             {hour_h, hour_l,
             min_h, min_l,
             sec_h, sec_l} <= data;
        else if (!state) begin
            sec_l <= sec_l + 1'b1;
            if (sec_l==4'd9) begin
                sec_l <= 4'd0;
                sec_h <= sec_h + 1'b1;
                if (sec_h==4'd5) begin
                    sec_h <= 4'd0;
                    min_l <= min_l + 1'b1;
                    //注意一分钟60秒，�?59秒的下一�?沿�?�进�?
                    if (min_l==4'd9) begin
                        min_l <= 4'd0;
                        min_h <= min_h + 1'b1;
                        if (min_h==4'd5) begin
                            min_h <= 4'd0;
                            hour_l <= hour_l + 1'b1;
                            //同理，一小时23分钟
                            if (hour_l==4'd3) begin
                                hour_l <= 4'd0;
                                hour_h <= hour_h + 1'b1;
                                if(hour_h==4'd2) begin
                                    hour_h <= 4'd0;
                                end
                            end
                        end
                    end
                end 
            end
        end
        else
            {hour_h, hour_l,min_h, min_l,sec_h, sec_l} <= {hour_h, hour_l,min_h, min_l,sec_h, sec_l};
    end
    
    assign c = ({hour_h, hour_l,min_h, min_l, sec_h, sec_l}==24'h235959);

endmodule

