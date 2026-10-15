`timescale 1ns / 1ps

module floor_tracker(
input clk,
input rst,
input move_en,
input move_dir,
output [1:0] curr_floor
    );
    
    reg [1:0] currentFloor;
    
    // Asynchronous active-low reset
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
                currentFloor <= 2'b00;
        end 
        else begin
            if (move_en) begin
                if ( (currentFloor == 2'b11 &&  move_dir == 1'b1) | (currentFloor == 2'b00 &&  move_dir == 1'b0) )  begin 
                    currentFloor <= currentFloor + 2'b00; 
                end
                else begin
                    if (move_dir) begin
                        currentFloor <= currentFloor + 2'b01;
                    end
                    else begin
                        currentFloor <= currentFloor - 2'b01;
                    end
                end
            end
            else begin
                currentFloor <= currentFloor + 2'b00;
            end
        end
    end
    
    assign curr_floor = currentFloor;
endmodule