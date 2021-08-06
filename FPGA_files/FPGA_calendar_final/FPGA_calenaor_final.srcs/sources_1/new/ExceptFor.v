`timescale 1ns / 1ps

module ExceptFor(
    input[13:0] year,
    input[3:0] month,
    output reg [1:0] exp_code
    // output reg LeapYear, BigMonth, Feb
);
    //  特殊情况判断表
    //  exp_code=00     平年2月-28天
    //  exp_code=01     闰年2月-29天
    //  exp_code=10     小月-30天
    //  exp_code=11     大月-31天

    reg LeapYear;  //是否闰年
    reg BigMonth, Feb; //是否大月，是否二月

    //是否闰年
    always @ (*) begin
        if (year%4==0) begin
            if (year%100!=0)
                LeapYear = 1'b1;
            else if (year%400==0) begin
                if (year%3200!=0)
                    LeapYear = 1'b1;
                else
                    LeapYear = 1'b0;
            end
        end
        else
            LeapYear = 1'b0;
    end

    //是否大月
    always @ (*) begin
        if (
            (month==4'd1)||
            (month==4'd3)||
            (month==4'd5)||
            (month==4'd7)||
            (month==4'd8)||
            (month==4'd10)||
            (month==4'd12)
            )
            BigMonth = 1'b1;
        else
            BigMonth = 1'b0;
    end

    //是否二月
    always @ (*) begin
        Feb = (month==4'd2);
    end
    // assign Feb = (month==4'd2);

    //特殊情况码
    always @ (*) begin
        if (Feb) begin
            if (~LeapYear)
                exp_code = 2'b00;
            else
                exp_code = 2'b01;
        end
        else begin
            if (~BigMonth)
                exp_code = 2'b10;
            else
                exp_code = 2'b11; 
        end
    end

endmodule