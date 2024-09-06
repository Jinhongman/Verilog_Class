`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);

    logic [31:0] rom[0:1023];

    initial begin
    $readmemh("inst.mem", rom); // instruction hexa code instruction
    end
    assign data = rom[addr[31:2]];

endmodule
