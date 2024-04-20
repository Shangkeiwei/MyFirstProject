module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy); 
input clk; 
input reset; 
input [7:0] datain; 
input [2:0] cmd; 
input cmd_valid; 
output reg [7:0] dataout; 
output reg output_valid; 
output reg busy; 
//define point
reg [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15;
reg [7:0] ImageBuffer[107:0];
reg [2:0] current_state,next_state;
reg [6:0] read_counter; 
reg [4:0] display_counter;
reg display_flag;
//define states 
parameter read_state = 3'd0;
parameter zoom_fit_state = 3'd1;
parameter zoom_in_state = 3'd2;
parameter display_fit_state = 3'd3;
parameter display_in_state = 3'd4;
parameter operate_fit_state = 3'd5;
parameter operate_in_state = 3'd6;
//assign point ,initial point p0 = 6'd28
always@(*)
begin
    p1=p0+6'd1;
    p2=p0+6'd2;
    p3=p0+6'd3;
    p4=p0+6'd12;
    p5=p0+6'd13;
    p6=p0+6'd14;
    p7=p0+6'd15;
    p8=p0+6'd24;
    p9=p0+6'd25;
    p10=p0+6'd26;
    p11=p0+6'd27;
    p12=p0+6'd36;
    p13=p0+6'd37;
    p14=p0+6'd38;
    p15=p0+6'd39;
end
//state switch
always@(posedge clk or posedge reset)
begin
    if(reset)begin
        current_state<=zoom_fit_state;
        read_counter<=0;
        display_counter<=0;
        busy<=0;
        output_valid<=0;
        dataout<=0;
        p0 <= 6'h28;
        display_flag<=0;
    end
    else current_state<=next_state;
end

//next state logic
always@(*)begin
    case(current_state)
        read_state:
        begin
            output_valid=0;
            busy=1;
            if(read_counter==7'd107) next_state<=display_fit_state;
            else next_state<=read_state;
        end
        zoom_fit_state:
        begin
            busy=0;
            if(cmd_valid && cmd==0) //load data
            begin 
            next_state = read_state;
            p0 = 6'h28;
            end
            else if(cmd_valid && cmd==1) // zoom in
            begin 
                next_state = operate_fit_state;
                p0 = 6'h28;
            end
            else 
            begin
                next_state = display_fit_state;
            end
        end
        zoom_in_state:
        begin
            busy=0;
            if(cmd_valid && cmd==0) //load data
            begin
                next_state=read_state;
                p0 = 6'h28;
            end
            else if(cmd_valid && cmd==3'd2)//zoom fit
            begin
                next_state=display_fit_state;
                p0 = 6'h28;
            end
            else if(cmd_valid && cmd != 0 && cmd != 3'd2)
            begin
                next_state=operate_in_state;
            end
            else
            begin
                next_state=display_in_state;
            end
        end
        operate_fit_state:
        begin
            busy=1;
            next_state=display_in_state;
            display_counter=0;
        end
        operate_in_state:
        begin
            busy=1;
            next_state=display_in_state;
            display_counter=0;
        end
        display_fit_state:
        begin
            busy=1;
            display_flag=1;
            if(display_counter==5'd15) next_state<=zoom_fit_state;
            else next_state<=display_fit_state;
        end
        display_in_state:
        begin
            busy=1;
            display_flag=1;
            if(display_counter==5'd15) next_state<=zoom_in_state;
            else next_state<=display_in_state;
        end
    endcase
end
//calculate read counter
always@(posedge clk or reset)
begin
    if(reset) read_counter<=0;
    else if(current_state==read_state)
    begin
        if(read_counter==7'd107) read_counter<=0;
        else read_counter<=read_counter+1;
    end
end
//calculate display counter
always@(posedge clk or posedge reset)
begin
    if(reset)display_counter<=0;
    else
    begin
        if(display_flag)
        begin
            if(display_counter==5'd15)
            begin
                display_flag<=0;
                display_counter<=0;
            end
            else display_counter<=display_counter+5'd1;
        end
    end
end
//operate
always@(posedge clk or posedge reset)
begin
    if(reset) p0 <= 6'h28;
    else
    begin
        if(current_state==zoom_in_state)
        begin
            case(cmd)
            3'd3: //shift right
            begin
                if(p0==8'h8||p0==8'h14||p0==8'h20||p0==8'h2c||p0==8'h38||p0==8'h44||p0==8'h50||p0==8'h5c||p0==8'h68)
                p0<=p0;
                else p0<=p0+8'd1;
            end
            3'd4: //shift left
            begin
                if(p0==8'h0||p0==8'hc||p0==8'h18||p0==8'h24||p0==8'h30||p0==8'h3c||p0==8'h48||p0==8'h54||p0==8'h60)
                p0<=p0;
                else p0<=p0-8'd1;
            end
            3'd5: //shift up
            begin
                if(p0<8'hc) p0<=p0;
                else p0<=p0-8'd12;
            end
            3'd6: //shift down
            begin
                if(p0>8'h3b)p0<=p0;
                else p0<=p0+8'd12;
            end
            endcase
        end
    end
end
//output logic
always@(posedge clk or posedge reset)
begin
    case(current_state)
    read_state: ImageBuffer[read_counter]<=datain;
    zoom_fit_state:
    begin
        output_valid=0;
    end
    zoom_in_state:
    begin
        output_valid=0;
    end
    operate_fit_state:
    begin
        output_valid=0;
    end
    operate_in_state:
    begin
        output_valid=0;
    end
    display_fit_state:
    begin
        output_valid<=1;
        case(display_counter)
        5'd0:dataout<=ImageBuffer[8'hd];
        5'd1:dataout<=ImageBuffer[8'h10];
        5'd2:dataout<=ImageBuffer[8'h13];
        5'd3:dataout<=ImageBuffer[8'h16];
        5'd4:dataout<=ImageBuffer[8'h25];
        5'd5:dataout<=ImageBuffer[8'h28];
        5'd6:dataout<=ImageBuffer[8'h2b];
        5'd7:dataout<=ImageBuffer[8'h2e];
        5'd8:dataout<=ImageBuffer[8'h3d];
        5'd9:dataout<=ImageBuffer[8'h40];
        5'd10:dataout<=ImageBuffer[8'h43];
        5'd11:dataout<=ImageBuffer[8'h46];
        5'd12:dataout<=ImageBuffer[8'h55];
        5'd13:dataout<=ImageBuffer[8'h58];
        5'd14:dataout<=ImageBuffer[8'h5b];
        5'd15:dataout<=ImageBuffer[8'h5e];
        endcase
    end
    display_in_state:
    begin
        output_valid<=1;
        case(display_counter)
        5'd0:dataout<=ImageBuffer[p0];
        5'd1:dataout<=ImageBuffer[p1];
        5'd2:dataout<=ImageBuffer[p2];
        5'd3:dataout<=ImageBuffer[p3];
        5'd4:dataout<=ImageBuffer[p4];
        5'd5:dataout<=ImageBuffer[p5];
        5'd6:dataout<=ImageBuffer[p6];
        5'd7:dataout<=ImageBuffer[p7];
        5'd8:dataout<=ImageBuffer[p8];
        5'd9:dataout<=ImageBuffer[p9];
        5'd10:dataout<=ImageBuffer[p10];
        5'd11:dataout<=ImageBuffer[p11];
        5'd12:dataout<=ImageBuffer[p12];
        5'd13:dataout<=ImageBuffer[p13];
        5'd14:dataout<=ImageBuffer[p14];
        5'd15:dataout<=ImageBuffer[p15];
        endcase
    end
    endcase
end
endmodule