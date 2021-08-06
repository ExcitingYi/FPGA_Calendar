module smg(
    input      clk,
    input      rst,
    input      stop_state,      //閺勵垰鎯侀弳鍌氫粻閿燂拷??
    input      [2:0] btn_pos,    //闂傤亞鍎婃担宥囩枂閿燂拷??
    input      [31:0]true_date, //閺勫墽銇氶弮鍫曟？閿燂拷??
    input      [7:0] point,   
    output reg [7:0] seg,
    output reg [7:0] an
    // output reg [3:0] disp_dat,
    // output reg [2:0] disp_bit,
    // output reg [16:0] divclk_cnt
	);
    //wire [31:0] dispdata;
    reg [16:0] divclk_cnt = 0;
    reg [23:0] flash_div_cnt = 0;
    reg        divclk;
    reg        flashclk;
    reg [3:0]  disp_dat;  
    reg [2:0]  disp_bit; 
    reg        dot_disp; 
	parameter maxcnt = 16'd50000;
	parameter maxflashcnt = 24'd10000000;       //閸氬酣娼伴崘宥嗘暭

    //assign dispdata = true_date;        //濞夈劍鍓版潻娆忓綖閿燂拷??

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
		begin
		    flashclk <= 1'b0;
            flash_div_cnt <= 24'd0;
		end
		else if(flash_div_cnt == maxflashcnt)
        begin
            flashclk     <= ~flashclk;
            flash_div_cnt <= 24'd0;
        end
        else
        begin
            flash_div_cnt <= flash_div_cnt + 1'b1;
        end
    end

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
		begin
		    divclk     <= 1'b0;
            divclk_cnt <= 17'd0;
		end
		else if(divclk_cnt == maxcnt)
        begin
            divclk     <= ~divclk;
            divclk_cnt <= 17'd0;
        end
        else
        begin
            divclk_cnt <= divclk_cnt + 1'b1;
        end
    end
    always@(posedge divclk or negedge rst)
    begin
		if(!rst)
		begin
		 	an       <= 8'b00000000;
		 	disp_bit <= 3'd0;
		 	dot_disp <= 1'b0;
		end
		else
		// begin
		//     if(disp_bit == 3'd6)
		//         disp_bit <= 3'd0;
		//     else
		    begin
                disp_bit <= disp_bit + 1'b1;
                case(disp_bit)
                    3'h0:
                    begin
                        disp_dat <= true_date[3:0];
                        dot_disp <= point[0];
                        an <= {7'b0000000,(~btn_pos[0])|flashclk};
                    end
                    3'h1:
                    begin
                        disp_dat <= true_date[7:4];
                        dot_disp <= point[1];
                        an <= 8'b00000010;
                    end
                    3'h2:
                    begin
                        disp_dat <= true_date[11:8];
                        dot_disp <= point[2];
                        an <= {5'b00000,(~btn_pos[1])|flashclk,2'b00};
                    end
                    3'h3:
                    begin
                        disp_dat <= true_date[15:12];
                        dot_disp <= point[3];
                        an <= 8'b00001000;
                    end
                    3'h4:
                    begin
                        disp_dat <= true_date[19:16];
                        dot_disp <= point[4];
                        an <= {3'b000,(~btn_pos[2])|flashclk,4'b0000};
                    end
                    3'h5:
                    begin
                        disp_dat <= true_date[23:20];
                        dot_disp <= point[5];
                        an <= 8'b00100000;
                    end
                    3'h6:
                    begin
                        disp_dat <= true_date[27:24];
                        dot_disp <= point[6];
                        an <= 8'b01000000;
                    end
                    3'h7:
                    begin
                        disp_dat <= true_date[31:28];
                        dot_disp <= point[7];
                        an <= 8'b10000000;
                    end
                    default: an <= 8'b00000000;
                endcase
            end
        // end
    end

    always@(disp_dat)
    begin
        case(disp_dat)
			4'h0: seg = {dot_disp,7'b0111111};
			4'h1: seg = {dot_disp,7'b0000110};
			4'h2: seg = {dot_disp,7'b1011011};
			4'h3: seg = {dot_disp,7'b1001111};
			4'h4: seg = {dot_disp,7'b1100110};
			4'h5: seg = {dot_disp,7'b1101101};
			4'h6: seg = {dot_disp,7'b1111101};
			4'h7: seg = {dot_disp,7'b0000111};
			4'h8: seg = {dot_disp,7'b1111111};
			4'h9: seg = {dot_disp,7'b1101111};

			default: seg = 8'h00;
		endcase
    end
endmodule



