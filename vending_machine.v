module vending_machine (
    input clk,                
    input reset,               
    input [3:0] product_select,  
    input [3:0] coin_insert,     
    input item_dispensed,       
    output reg [7:0] lcd_display,     
    output reg [3:0] motor_control,
    output reg [3:0] status_led    
);

    localparam IDLE = 3'b000;
    localparam PRODUCT_SELECTED = 3'b001;
    localparam WAITING_FOR_PAYMENT = 3'b010;
    localparam DISPENSING = 3'b011;
    localparam ERROR_STATE = 3'b100;

    reg [2:0] current_state;
    reg [2:0] next_state;

    reg [7:0] product_price [0:3];
    initial begin
        product_price[0] = 8'd50;   //50¢
        product_price[1] = 8'd75;   //75¢
        product_price[2] = 8'd100;  //$1
        product_price[3] = 8'd150;  //$1.50
    end

    reg [7:0] coin_value [0:3];
    initial begin
        coin_value[0] = 8'd10;    // 10¢
        coin_value[1] = 8'd20;    // 20¢
        coin_value[2] = 8'd50;    // 50¢
        coin_value[3] = 8'd100;   // $1
    end

    reg [7:0] collected_coin;
    reg [3:0] selected_product;
    reg out_of_stock [0:3];  

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            collected_coin <= 8'd0;
            selected_product <= 4'd0;
        end else begin
            current_state <= next_state;
        end
    end

    always @* begin
        case (current_state)
            IDLE:
                if (product_select != 4'd0) begin
                    selected_product <= product_select;
                    next_state = PRODUCT_SELECTED;
                end else begin
                    next_state = IDLE;
                end

            PRODUCT_SELECTED:
                if (out_of_stock[selected_product]) begin
                    next_state = ERROR_STATE;
                end else begin
                    next_state = WAITING_FOR_PAYMENT;
                end

            WAITING_FOR_PAYMENT:
                if (coin_insert != 4'd0) begin
                    collected_coin = collected_coin + coin_value[coin_insert];
                    if (collected_coin >= product_price[selected_product]) begin
                        next_state = DISPENSING;
                    end else begin
                        next_state = WAITING_FOR_PAYMENT;
                    end
                end else begin
                    next_state = WAITING_FOR_PAYMENT;
                end

            DISPENSING:
                if (item_dispensed) begin
                    collected_coin <= 8'd0;
                    next_state = IDLE;
                end else begin
                    next_state = DISPENSING;
                end

            ERROR_STATE:
                if (reset) begin
                    next_state = IDLE;
                end else begin
                    next_state = ERROR_STATE;
                end

            default:
                next_state = IDLE;
        endcase
    end

    always @* begin
        case (current_state)
            IDLE:
                begin
                    lcd_display = 8'b00000001;   
                    motor_control = 4'b0000;     
                    status_led = 4'b0000;       
                end

            PRODUCT_SELECTED:
                begin
                    lcd_display = 8'b00000010;  
                    motor_control = 4'b0000;     
                    status_led = 4'b0001;       
                end

            WAITING_FOR_PAYMENT:
                begin
                    lcd_display = 8'b00000100; 
                    motor_control = 4'b0000;     
                    status_led = 4'b0010;      
                end

            DISPENSING:
                begin
                    lcd_display = 8'b00001000;   
                    motor_control = 4'b0001 << selected_product;   
                    status_led = 4'b0100;       
                end

            ERROR_STATE:
                begin
                    lcd_display = 8'b00010000;   
                    motor_control = 4'b0000;    
                    status_led = 4'b1000;       
                end

            default:
                begin
                    lcd_display = 8'b00000000;   
                    motor_control = 4'b0000;    
                    status_led = 4'b0000;        
                end
        endcase
    end

endmodule
