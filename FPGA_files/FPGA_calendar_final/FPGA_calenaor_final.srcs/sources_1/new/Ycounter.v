`timescale 1ns / 1ps

module Ycounter(
    input ini_clk,     // 打拍专用时钟
    input clk,
    input[1:0] btns,    //閹�?�鏁敍灞藉閸戝繒鏁ら妴鍌欑安娑擃亝瀵滈柨�?�嗙礉閼崇晫鏁ら崚鎵畱閸欘亝婀佹稉濠佺瑓娑撱倓閲滈妴?
    input btn_ena,      //閹�?�鏁担鑳厴娴ｅ�??鍌涙�?閸�??粈绨￠幍宥堝厴鐠�?�?妞傞梻娣???
    input arstn,
    input ena,
    input load,
    input[15:0] data,
    output c_Y, 
    output[13:0] year_out
    );

    reg [13:0] state; //2^5=32>31
    wire [13:0] year;
    assign year = state + 1'b1; //楠炵繝鍞ゅ▽鈩冩�?0�???

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
        if (!arstn) begin
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
            state <= 14'd1948;      //婢跺秳缍�?�??1949閺傞鑵戦崶鑺ュ灇缁斿??
        end
        else if (load) begin
            state <= 1000*data[15:12]+100*data[11:8]+10*data[7:4]+data[3:0]-1;
        end
        else if (ena&clk_d0&(~clk_d1)) begin
            if (state>=14'd9999)
                state <= 14'd0;
            else
                state <= state + 1'b1;
        end
        else if (up_d0&(~up_d1)) begin
            if (state >= 14'd9999)
                state <= 14'b0;
            else
                state <= state + 1'b1;
        end
        else if (down&(~down_d1)) begin
            if (state == 14'd0000)
                state <= 14'd0;
            else 
                state <= state - 1'b1;
        end
        else 
            state <= state;
    end

    //閺佹壆鐖滄潏鎾冲�?
    assign year_out = year;

    //鏉╂稐缍�?潏鎾冲毉
    assign c_Y = (year==14'd9999);
    
endmodule