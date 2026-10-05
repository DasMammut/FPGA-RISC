module decoder(
    input [5:0] opcode,
    input [1:0] Flags,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg StackPush,
    output reg StackPop,
    output reg JmpInstruction,
    output reg CLK_HLT,
    output reg AtoA,
    output reg BtoB,
    output reg CtoC,
    output reg AtoC,
    output reg [3:0] AluMode
);



    always @(*) begin
        // Standardwerte
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        StackPush = 0;
        StackPop = 0;
        JmpInstruction = 0;
        CLK_HLT = 0;
        AtoA = 0;
        BtoB = 0;
        CtoC = 0;
        AtoC = 0;
        AluMode = 4'b0000;
        case (opcode)
            6'b000000: begin // Beispiel: NOP
                // Keine Operation
            end
            6'b000001: begin // Beispiel: HLT
                // Halte den Prozessor
                CLK_HLT = 1;
            end
            6'b000010: begin // Beispiel: LOD
                MemRead = 1;
                RegWrite = 1;
                AtoC = 1;
            end
            6'b000011: begin // Beispiel: STO
                MemWrite = 1;
                AtoA = 1;
            end
            6'b000100: begin // Beispiel: LDR
                MemRead = 1;
                RegWrite = 1;
                AtoA = 1;
                CtoC = 1;
            end
            6'b000101: begin // Beispiel: STR
                MemWrite = 1;
                AtoA = 1;
                BtoB = 1;
            end
            6'b000110: begin // Beispiel: LDI
                RegWrite = 1;
                AtoC = 1;
            end
            6'b000111: begin // Beispiel: LBI
                RegWrite = 1;
            end
            6'b001000: begin // Beispiel: LPC
                RegWrite = 1;
                CtoC = 1;
            end
            6'b001001: begin // Beispiel: LSP
                RegWrite = 1;
                CtoC = 1;
            end
            6'b001010: begin // Beispiel: MOV
                RegWrite = 1;
                AtoA = 1;
                CtoC = 1;
            end
            6'b001011: begin // Beispiel: ADD
                AluMode = 4'b0001;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b001100: begin // Beispiel: ADC
            AluMode = 4'b0010;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b001101: begin // Beispiel: ADI
                AluMode = 4'b0001;
                RegWrite = 1;
                AtoA = 1;
                AtoC = 1;
            end
            6'b001110: begin // Beispiel: SUB
                AluMode = 4'b0011;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b001111: begin // Beispiel: SBI
                AluMode = 4'b0011;
                RegWrite = 1;
                AtoA = 1;
                AtoC = 1;
            end
            6'b010000: begin // Beispiel: SHR
                AluMode = 4'b0100;
                RegWrite = 1;
                CtoC = 1;
            end
            6'b010001: begin // Beispiel: AND
                AluMode = 4'b0101;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010010: begin // Beispiel: IOR
                AluMode = 4'b0110;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010011: begin // Beispiel: XOR
                AluMode = 4'b0111;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010100: begin // Beispiel: NAN
                AluMode = 4'b1000;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010101: begin // Beispiel: NOR
                AluMode = 4'b1001;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010110: begin // Beispiel: XNO
                AluMode = 4'b1010;
                RegWrite = 1;
                AtoA = 1;
                BtoB = 1;
                CtoC = 1;
            end
            6'b010111: begin // Beispiel: NOT
                AluMode = 4'b1011;
                RegWrite = 1;
                AtoA = 1;
                CtoC = 1;
            end
            6'b011000: begin // Beispiel: CMP
                AluMode = 4'b1100;
                AtoA = 1;
                BtoB = 1;
            end
            6'b011001: begin // Beispiel: JMP
                JmpInstruction = 1;
            end
            6'b011010: begin // Beispiel: JMR
                JmpInstruction = 1;
                AtoA = 1;
            end
            6'b011011: begin // Beispiel: JEZ
                JmpInstruction = Flags[0];
            end
            6'b011100: begin // Beispiel: JNZ
                JmpInstruction = ~Flags[0];
            end
            6'b011101: begin // Beispiel: JEC
                JmpInstruction = Flags[1];
            end
            6'b011110: begin // Beispiel: JNC
                JmpInstruction = ~Flags[1];
            end
            6'b011111: begin // Beispiel: JEH
                JmpInstruction = ~(Flags[1] | Flags[0]);
            end
            6'b100000: begin // Beispiel: JNH
                JmpInstruction = (Flags[1] | Flags[0]);
            end
            6'b100001: begin // Beispiel: PSH
                MemWrite = 1;
                StackPush = 1;
                AtoA = 1;
            end
            6'b100010: begin // Beispiel: POP
                MemRead = 1;
                StackPop = 1;
                RegWrite = 1;
                CtoC = 1;
            end
            6'b100011: begin // Beispiel: CAL
                MemWrite = 1;
                StackPush = 1;
                JmpInstruction = 1;
            end
            6'b100100: begin // Beispiel: RET
                MemRead = 1;
                StackPop = 1;
                JmpInstruction = 1;
            end
            default: begin
                // Unbekannter Opcode, keine Aktion
            end
        endcase



    end

endmodule