module vending_machine(clk, reset, item, sel, dollar_10, dollar_50, amount_to_pay, item_rels, change_return);
input clk;
input reset;    /* active high, synchronous reset*/
input [1:0] item; /* item selection, transition @ negedge(clk) */
input sel;     /* confirm the selection, valid for 1 clock cycle, active high,   
transition @ negedge(clk) */
input dollar_10; /* valid for 1 clock cycle, transition @ negedge(clk) */
input dollar_50; /* valid for 1 clock cycle, transition @ negedge(clk) */
output reg [3:0] amount_to_pay; /* always valid, refer to Table 1, transition @ posedge(clk) */
output reg [2:0] item_rels; /* refer to Table 2, transition @ posedge(clk) */
output reg change_return  /* one clock cycle for one coin return, transition @ posedge(clk) */

reg     current_item    /* hold the value of current (not confirmed yet) item selection */
reg     confirmed_item // hold the value of the confirmed item selection 

reg dollar_10_dly1, dollar_10_dly2;
reg dollar_50_dly1, dollar_50_dly2;
wire dollar_10_pulse, dollar_50_pulse;

assign dollar_10_pulse = dollar_10_dly1 & (~dollar_10_dly2);//one-shot pulse begin
assign dollar_50_pulse = dollar_50_dly1 & (~dollar_50_dly2);
always @(posedge clk) begin
    if(reset) begin
        dollar_10_dly1 <= 1'b0;
        dollar_10_dly2 <= 1'b0;
        dollar_50_dly1 <= 1'b0;
        dollar_50_dly2 <= 1'b0;
    end
    else begin
        dollar_10_dly1 <= dollar_10;
        dollar_10_dly2 <= dollar_10_dly1;
        dollar_50_dly1 <= dollar_50;
        dollar_50_dly2 <= dollar_50_dly1;
    end
end                                                        //one-shot pulse end

//Excitation logic

    


endmodule