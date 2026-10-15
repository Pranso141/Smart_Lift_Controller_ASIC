`timescale 1ns / 1ps

module request_manager(
input clk,
input rst,
input [1:0] outsider_loc,
input outsider_dir,
input [1:0] insider_destination,
input req_valid,
input [1:0] curr_floor,
input clear_floor,
output [3:0] pending_mask
    );
    reg [3:0] hall_up, hall_up_next;
    reg [3:0] hall_down, hall_down_next;
    reg [3:0] car_calls, car_calls_next;
    
    wire [3:0] loc_onehot  = 4'b0001 << outsider_loc;
    wire [3:0] dest_onehot = 4'b0001 << insider_destination;
    wire [3:0] curr_onehot = 4'b0001 << curr_floor;

    wire [3:0] set_up   = loc_onehot  & 4'b0111 & {4{req_valid &  outsider_dir}};
    wire [3:0] set_down = loc_onehot  & 4'b1110 & {4{req_valid & ~outsider_dir}};
    wire [3:0] set_car  = dest_onehot &           {4{req_valid}};

    wire [3:0] clr = curr_onehot & {4{clear_floor}};

    always @(*) begin
        hall_up_next   = set_up   | (hall_up   & ~clr);
        hall_down_next = set_down | (hall_down & ~clr);
        car_calls_next = set_car  | (car_calls & ~clr);
    end

    // Asynchronous active-low reset
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            hall_up   <= 4'b0000;
            hall_down <= 4'b0000;
            car_calls <= 4'b0000;
        end else begin
            hall_up   <= hall_up_next;
            hall_down <= hall_down_next;
            car_calls <= car_calls_next;
        end
    end

    assign pending_mask = hall_up | hall_down | car_calls;
    
endmodule