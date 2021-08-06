`timescale 1ns / 1ps

module Mcounter(
    input ini_clk,      //打拍专用时钟�?
    input clk,
    input[1:0] btns,    
    input btn_ena,      
    input arstn,    
    input ena,
    input load,
    input[7:0] data,
    output c_M, 
    output[3:0] month_out
    );

    reg [3:0] state; //2^4=16>12
    wire [3:0] month;
    assign month = state + 1'b1; 
    // reg cc;
    // assign c_M = cc;
    wire up,down;
    assign up = btn_ena & btns[1];
    assign down = btn_ena & btns[0];

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

    reg down_d0,down_d1;
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

    always @ (posedge ini_clk or negedge arstn or posedge load) begin
        if (~arstn) begin
            state <= 4'd9;         //澶嶄綅缁?1949.10.01
            // cc <= 1'b0;
        end
        else if (load) begin
            state <= 10*data[7:4]+data[3:0]-1;
        end
        else if (ena&clk_d0&(~clk_d1)) begin
            if (state >= 4'd11)     
                state <= 4'd0;
            else
                state <= state + 1'b1;
        end
        else if (up_d0&(~up_d1)) begin
            if (state >= 4'd11)
            state <= 4'd0;
            else 
                state <= state + 1'b1;
        end
        else if (down_d0&(~down_d1)) begin
            if (state == 4'd0) 
                state <= 4'd0;
            else 
                state <= state-1'b1;
        end
        else 
            state <= state;
    end
    // always @(posedge (up) or posedge (down)) begin 
    //     if (up == 1) begin
    //         if (state >= 4'd11)
    //         state <= 4'd0;
    //         else 
    //             state <= state + 1;
    //     end
    //     else if (down == 1) begin
    //         if (state == 0) 
    //             state <= 4'd0;
    //         else 
    //             state <= state-1;
    //     end
    // end

    //鏁扮爜杈撳嚭
    assign month_out = month;

    //杩涗綅杈撳嚭
    assign c_M = (month==4'd12);

endmodule