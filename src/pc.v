module pc(
    input wire CLK,
    input wire Reset,
    input wire EnableIncrement,
    input wire EnableJump,
    input wire [9:0] JumpAddr,
    output reg [9:0] PCout    // output reg ist hier perfekt
);

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            PCout <= 10'b0;   // Zurück auf Anfang
        end 
        else if (EnableJump) begin
            PCout <= JumpAddr; // Springe zu einer Adresse
        end
        else if (EnableIncrement) begin
            PCout <= PCout + 1; // Normaler nächster Befehl
        end
    end

endmodule