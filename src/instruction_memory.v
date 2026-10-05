module instruction_memory(
    input [9:0] address,
    output wire [23:0] instruction
);

    reg [23:0] rom [0:1023];

    initial begin
        $readmemb("instruction_memory.bin", rom);

        // rom[0] = 24'b000110_00001_0000000000_000 ; // LDI R1, 0
        // rom[1] = 24'b000110_00010_0000000001_000 ; // LDI R2, 1
        // rom[2] = 24'b000110_00011_0011111010_000 ; // LDI R3, 250
        // rom[3] = 24'b001011_00001_00010_000_00001 ; // ADD R1, R1, R2
        // rom[4] = 24'b001011_00001_00010_000_00010 ; // ADD R2, R1, R2
        // rom[5] = 24'b011000_00001_00011_00000000 ; // CMP R1, R3
        // rom[6] = 24'b100000_00000_0000000011_000 ; // JEH 7
        // rom[7] = 24'b000001_000000000000000000 ; // HLT
    end

    assign instruction = rom[address];

endmodule