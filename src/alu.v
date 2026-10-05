module alu(
    input wire CLK,
    input wire reset,
    input [15:0] A, 
    input [15:0] B,
    input [3:0] Mode,
    output reg [15:0] Result,
    output reg [1:0] FlagsOut    // Direkt als Reg für das interne Gedächtnis
);

    reg [1:0] next_flags;
    reg update_flags;

    always @(*) begin
        update_flags = 1'b1;     // Standardmäßig Flags aktualisieren
        Result = 16'b0;
        next_flags = FlagsOut;   // Standard: Flags behalten

        case(Mode)
            4'b0001: begin       // ADD // ADI
                {next_flags[1], Result} = A + B;
                next_flags[0] = (Result == 16'b0);
            end
            4'b0010: begin       // ADC
                {next_flags[1], Result} = A + B + FlagsOut[1];
                next_flags[0] = (Result == 16'b0);
            end
            4'b0011: begin       // SUB // SBI
                Result = A - B;
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = (A < B);
            end
            4'b0100: begin       // SHR
                Result = A >> 1; 
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = A[0];
            end
            4'b0101: begin       // AND
                Result = A & B;
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b0110: begin       // IOR
                Result = A | B;
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b0111: begin       // XOR
                Result = A ^ B;
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b1000: begin       // NAND
                Result = ~(A & B);
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b1001: begin       // NOR
                Result = ~(A | B);
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b1010: begin       // XNOR
                Result = ~(A ^ B);
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b1011: begin       // NOT
                Result = ~A;
                next_flags[0] = (Result == 16'b0);
                next_flags[1] = 1'b0;
            end
            4'b1100: begin       // CMP
                Result = 16'b0; 
                next_flags[0] = (A == B);
                next_flags[1] = (A < B);
            end
            default: begin
                Result = 16'b0;
                update_flags = 1'b0;
            end
        endcase
    end

    // --- Synchrones Speichern der Flags ---
    always @(posedge CLK or posedge reset) begin
        if (reset) begin
            FlagsOut <= 2'b0;
        end else if (update_flags) begin
            FlagsOut <= next_flags;
        end
    end

endmodule