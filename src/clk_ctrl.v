module clk_ctrl(
    input wire clk_in,      // Der schnelle Hardware-Takt
    input wire reset,       // Reset um wieder zu starten
    input wire hlt_signal,  // Kommt vom Decoder (Opcode 000001)
    output wire clk_out     // Der Takt, der an PC, RAM und RegFile geht
);

    reg halted;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            halted <= 1'b0;
        end else if (hlt_signal) begin
            halted <= 1'b1;
        end
    end

    // Clock Gating: Nur wenn nicht 'halted', wird der Takt weitergegeben
    // Wir nutzen hier ein AND-Gatter Prinzip
    assign clk_out = clk_in & (~halted);

endmodule