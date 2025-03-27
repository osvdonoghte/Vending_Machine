`include "vending_machine.v" 

module tb_vending_machine;

    reg clk;
    reg reset;
    reg [3:0] product_select;
    reg [3:0] coin_insert;
    reg item_dispensed;
    wire [7:0] lcd_display;
    wire [3:0] motor_control;
    wire [3:0] status_led;

    vending_machine uut (
        .clk(clk),
        .reset(reset),
        .product_select(product_select),
        .coin_insert(coin_insert),
        .item_dispensed(item_dispensed),
        .lcd_display(lcd_display),
        .motor_control(motor_control),
        .status_led(status_led)
    );

    reg clock = 0;
    always #5 clock = ~clock;

    initial begin
        clk = 0;
        reset = 1;
        product_select = 4'b0000;
        coin_insert = 4'b0000;
        item_dispensed = 0;

        #10;
        reset = 0;

        #20;
        product_select = 4'b0001; 
        coin_insert = 4'b0100;    
        coin_insert = 4'b0000;     

       
        #100;
        item_dispensed = 1;        

        
        #20;
        product_select = 4'b0010;   

     
        #50;
        product_select = 4'b0000;   
        #10;
        reset = 1;               

        #100;
        $finish;
       $display("test complete") ; 
    end

endmodule
