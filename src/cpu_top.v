`include "pc.v"
`include "instruction_memory.v"
`include "decoder.v"
`include "regfile.v"
`include "alu.v"
`include "ram.v"
`include "stack.v"
`include "clk_ctrl.v" // Vergiss nicht die Datei für den Clock-Controller

module cpu_top(
    input wire CLK,      // Dies ist der echte Hardware-Takt von außen
    input wire Reset,
    output wire CLK_HLT  // HLT Signal vom Decoder
);

    // --- Interne Clock ---
    wire internal_clk; 

    // --- Restliche Wires ---
    wire [23:0] instruction;
    wire [5:0] opcode = instruction[23:18];
    wire [9:0] PCout;
    wire [15:0] RegData0, RegData1, AluData, MemData;
    wire [1:0] FlagOut;
    wire [9:0] StackPointer;

    wire RegWriteEn, MemRead, MemWrite, StackPush, StackPop, JmpInstruction, AtoA, BtoB, CtoC, AtoC;
    wire [3:0] AluMode;

    // --- Clock Controller ---
    // Erzeugt aus dem äußeren CLK einen internal_clk, der bei HLT stoppt
    clk_ctrl system_clk (
        .clk_in(CLK),
        .reset(Reset),
        .hlt_signal(CLK_HLT),
        .clk_out(internal_clk)
    );

    // --- Jump Adress Logik ---
    wire [9:0] JmpAddr = (opcode == 6'b011010) ? RegData0[9:0] : 
                        (opcode == 6'b100100) ? MemData[9:0] : 
                        instruction[12:3];

    // --- Program Counter ---
    pc programm_counter (
        .CLK(internal_clk),
        .Reset(Reset),
        .EnableIncrement(~JmpInstruction),
        .EnableJump(JmpInstruction),
        .JumpAddr(JmpAddr),
        .PCout(PCout)
    );

    // --- Instruction Memory ---
    instruction_memory imem (
        .address(PCout),
        .instruction(instruction)
    );

    // --- Decoder ---
    decoder OPdecoder (
        .opcode(opcode),
        .Flags(FlagOut),
        .RegWrite(RegWriteEn),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .StackPush(StackPush),
        .StackPop(StackPop),
        .JmpInstruction(JmpInstruction),
        .CLK_HLT(CLK_HLT),
        .AtoA(AtoA), .BtoB(BtoB), .CtoC(CtoC), .AtoC(AtoC),
        .AluMode(AluMode)
    );

    // --- Register Adress Multiplexer ---
    wire [4:0] ReadReg0 = (AtoA) ? instruction[17:13] : 5'b0;
    wire [4:0] ReadReg1 = (BtoB) ? instruction[12:8]  : 5'b0;
    wire [4:0] WriteReg = (CtoC) ? instruction[4:0]   : 
                          (AtoC) ? instruction[17:13] : 
                          (opcode == 6'b000111) ? 5'b11111 : // LBI
                          (opcode == 6'b010000) ? instruction[4:0] : // SHR
                          5'b0;

    // --- Register File ---
    wire [15:0] RegWriteData = (MemRead) ? MemData : 
                               (opcode == 6'b000110) ? {6'b0, instruction[12:3]} : // LDI
                               (opcode == 6'b000111) ? instruction[17:2] :  // LBI
                               (opcode == 6'b001001) ? {6'b0 , StackPointer} : // LSP
                                (opcode == 6'b001000) ? {6'b0 , PCout} : // LPC
                                opcode == 6'b001010 ? RegData0 : // MOV
                               AluData;

    regfile registerfile (
        .CLK(internal_clk),
        .RegWriteEn(RegWriteEn),
        .ReadRegAddr0(ReadReg0),
        .ReadRegAddr1(ReadReg1),
        .WriteRegAddr(WriteReg),
        .WriteData(RegWriteData),
        .ReadData0(RegData0),
        .ReadData1(RegData1)
    );

    // --- ALU ---
    wire [15:0] AluInB = (opcode == 6'b001101 || opcode == 6'b001111) ? {6'b0, instruction[12:3]} : RegData1;

    alu arithmetic_logic_unit (
        .CLK(internal_clk),
        .reset(Reset),
        .A(RegData0),
        .B(AluInB),
        .Mode(AluMode),
        .Result(AluData),
        .FlagsOut(FlagOut)
    );

    // --- RAM ---
    wire [9:0] MemAddr = (opcode == 6'b000010 || opcode == 6'b000011) ? instruction[12:3] :
                        (opcode == 6'b000100) ? RegData0[9:0] :
                        (opcode == 6'b000101) ? RegData1[9:0] :
                        (opcode == 6'b100001 || opcode == 6'b100010 || opcode == 6'b100011 || opcode == 6'b100100) ? StackPointer :
                        AluData[9:0];

    wire [15:0] MemWriteData = (opcode == 6'b100011) ? {6'b0, PCout + 10'b1} : RegData0;

    ram data_ram (
        .CLK(internal_clk),
        .Addr(MemAddr),
        .WriteData(MemWriteData),
        .WriteEnable(MemWrite),
        .ReadEnable(MemRead),
        .ReadData(MemData)
    );

    // --- Stack ---
    stack ram_stack (
        .CLK(internal_clk),
        .reset(Reset),
        .push(StackPush),
        .pop(StackPop),
        .stack_addr(StackPointer),
        .error() 
    );

endmodule