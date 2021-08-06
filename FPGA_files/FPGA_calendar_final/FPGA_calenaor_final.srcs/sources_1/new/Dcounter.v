`timescale 1ns / 1ps

module Dcounter(
    input ini_clk,      //打拍专用时钟�?
    input clk,
    input[1:0] btns,    //按键，加减用。五�?按键，能用到的只有上下两�?�?
    input btn_ena,      //按键使能位。暂停了且选中了才能调时间�?
    input arstn,
    input ena,
    input load,
    input[7:0]  data,       
    input[1:0] exp_code,//特殊情况代码
    output c_D, 
    output[4:0] day_out
    );
    
    reg [4:0] state; //2^5=32>31
    wire [4:0] day;
    wire up,down;
    assign up = btn_ena & btns[1];
    assign down = btn_ena & btns[0];
    assign day = state + 1'b1; //日期没有0�?


    // 打拍，边沿�?�测�?
    reg up_d0, up_d1;
    always @ (posedge ini_clk or negedge arstn) begin
        if (~arstn) begin
            up_d0 <= 1'b0;
            up_d1 <= 1'b0;
        end
        else begin 
            up_d0 <= up;
            up_d1 <= up_d0;
        end
    end

    reg down_d0, down_d1;
    always @ (posedge ini_clk or negedge arstn) begin
        if (~arstn) begin
            down_d0 <= 1'b0;
            down_d1 <= 1'b0;
        end
        else begin 
            down_d0 <= down;
            down_d1 <= down_d0;
        end
    end

    reg clk_d0,clk_d1;
    always @(posedge ini_clk or negedge arstn) begin
        if (~arstn) begin 
            clk_d0 <= 0;
            clk_d1 <= 0;
        end
        else begin 
            clk_d0 <= clk;
            clk_d1 <= clk_d0;
        end
    end
    
    //日�?�数�?，�?�数�?30进位
    always @ (posedge ini_clk or negedge arstn) begin
        if (~arstn) begin
            state <= 5'd0;
        end
        else if (load) begin
            state <= 10*data[7:4]+data[3:0]-1;
        end
        else if (clk_d0&(~clk_d1)) begin          
            if (((state>=5'd27)&&(exp_code==2'b00))||
                ((state>=5'd28)&&(exp_code==2'b01))||
                ((state>=5'd29)&&(exp_code==2'b10))||
                ((state>=5'd30)&&(exp_code==2'b11)))
                state <= 5'd0;
            else
                state <= state + 1'b1;
        end
        else if (up_d0&(~up_d1)) begin
            if (((state>=5'd27)&&(exp_code==2'b00))||
                ((state>=5'd28)&&(exp_code==2'b01))||
                ((state>=5'd29)&&(exp_code==2'b10))||
                ((state>=5'd30)&&(exp_code==2'b11)))
                state <= 5'd0;
            else 
                state <= state + 1'b1;
        end
        else if (down_d0&(~down_d1)) begin
            if (state == 5'd0) 
                state <= 5'd0;
            else 
                state <= state - 1'b1;
        end
        else
            state <= state;
    end

    // 写在两个always块里�?会报错。同一�?寄存器�?�个信号同时赋值�?
    // always @(posedge (up) or posedge (down)) begin 
    //     if (up == 1) begin
    //         if (((state>=5'd27)&&(exp_code==2'b00))||
    //             ((state>=5'd28)&&(exp_code==2'b01))||
    //             ((state>=5'd29)&&(exp_code==2'b10))||
    //             ((state>=5'd30)&&(exp_code==2'b11)))
    //         state <= 5'd0;
    //         else 
    //             state <= state + 1;
    //     end
    //     else if (down ==1) begin
    //         if (state == 0) 
    //             state <= 5'd0;
    //         else 
    //             state <= state-1;
    //     end
    // end


    //数码输出
    assign day_out = day;

    //进位输出
    assign c_D = (((day==5'd28)&&(exp_code==2'b00))||
                ((day==5'd29)&&(exp_code==2'b01))||
                ((day==5'd30)&&(exp_code==2'b10))||
                ((day==5'd31)&&(exp_code==2'b11)));

endmodule