`default_nettype none
`timescale 1ns / 1ps

// Tiny Tapeout top-level wrapper around the RISC-V core (top_module).
// 34 core pins (clk, rst, 32-bit pc) -> standard TT pins.
//
// ui_in[1:0] selects which byte of the 32-bit PC appears on uo_out:
//   00 -> pc[7:0]   01 -> pc[15:8]   10 -> pc[23:16]   11 -> pc[31:24]

module tt_um_pranso (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: input path
    output wire [7:0] uio_out,  // IOs: output path
    output wire [7:0] uio_oe,   // IOs: enable path (1 = output)
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // active-low reset
);

    wire [31:0] current_pc;

    top_module core (
        .clk       (clk),
        .rst       (~rst_n),
        .current_pc(current_pc)
    );

    reg [7:0] pc_byte;
    always @(*) begin
        case (ui_in[1:0])
            2'b00:   pc_byte = current_pc[7:0];
            2'b01:   pc_byte = current_pc[15:8];
            2'b10:   pc_byte = current_pc[23:16];
            default: pc_byte = current_pc[31:24];
        endcase
    end

    assign uo_out  = pc_byte;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;      // all bidirectional pins used as inputs (unused)

    // Silence unused-input warnings
    wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

endmodule
