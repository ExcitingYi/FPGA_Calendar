module key_debounce(
    input clk_btn,
    input rst,
    input stop_key,
    input up,
    input down,
    input left,
    input right,
    output [4:0] btn_out
);
    reg btn0;
    reg btn1;
    reg btn2;
    //reg[4:0] temp_out;
    always@ (posedge clk_btn or negedge rst)
    begin 
        if (!rst) begin
            btn0<=1'b0;
            btn1<=1'b0;
            btn2<=1'b0;
            //temp_out = 5'b00000;
        end
        else begin
            btn0 <= stop_key | up | right | down | left;
            btn1 <= btn0;
            btn2 <= btn1;
        end
        
    end
    assign btn_out = {stop_key&btn0&btn1&btn2,up&btn0&btn1&btn2,down&btn0&btn1&btn2,left&btn0&btn1&btn2,right&btn0&btn1&btn2};
    //鍚屼竴鏃堕棿鍙兘??娴嬩竴涓寜閿紝澶氫釜鎸夐敭??璧锋寜涓嬬殑璇濅紭鍏堢骇锛氭殏??>up>down>left>rignt;
//    always @(*) begin
//        if (btn0&btn1&btn2 == 1)
//        begin 
//            if (stop_key) begin
//                temp_out = 5'b10000;
//            end
//            else if(up) begin
//                temp_out = 5'b01000;
//            end
//            else if(down) begin
//                temp_out = 5'b00100;
//            end
//            else if(left) begin
//                temp_out = 5'b000010;
//            end
//            else if(right) begin
//                temp_out = 5'b00001;
//            end
//            else begin
//                temp_out = 5'b00000;   //娑堥櫎寤惰繜銆?
//            end
//        end
//        else begin
//            temp_out = 5'b00000;
//        end
//    end
//    assign btn_out = temp_out;

endmodule