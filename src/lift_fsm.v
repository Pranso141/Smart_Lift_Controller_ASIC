`timescale 1ns / 1ps

module lift_fsm(
input clk,
input rst,
input [3:0] pending_mask,
input [1:0] curr_floor,
output motor_en,
output motor_dir,
output up_led,
output down_led,
output clear_floor
    );
    
    localparam IDLE = 2'b00;
    localparam UP   = 2'b01;
    localparam DOWN = 2'b10;

    reg [1:0] state, next_state;

    wire [3:0] curr_onehot = 4'b0001 << curr_floor;          
    wire [3:0] below_mask  = curr_onehot - 4'b0001;          
    wire [3:0] above_mask  = ~(below_mask | curr_onehot);    

    wire stop_here = |(pending_mask & curr_onehot);          
    wire req_above = |(pending_mask & above_mask);          
    wire req_below = |(pending_mask & below_mask);          

    
    always @(posedge clk or negedge rst) begin
        if (!rst) state <= IDLE;
        else      state <= next_state;
    end

    always @(*) begin
        next_state = IDLE;
        case (state)
            IDLE: begin
                if      (req_above) next_state = UP;
                else if (req_below) next_state = DOWN;
                else                next_state = IDLE;
            end
            UP: begin
                if      (req_above) next_state = UP;
                else if (req_below) next_state = DOWN;
                else                next_state = IDLE;
            end
            DOWN: begin
                if      (req_below) next_state = DOWN;
                else if (req_above) next_state = UP;
                else                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    assign clear_floor = stop_here;
    assign motor_en    = ~stop_here & ((state == UP   & req_above) | (state == DOWN & req_below));
    assign motor_dir   = (state == UP);
    assign up_led      = (state == UP);
    assign down_led    = (state == DOWN);
    
endmodule
