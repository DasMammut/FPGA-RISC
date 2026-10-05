module stack(
    input wire CLK,
    input wire reset,
    input wire push,
    input wire pop,
    output wire [9:0] stack_addr,
    output wire error 
);
    // Start bei BASE (0x07F), wächst Richtung 0
    localparam BASE = 10'h07F;
    reg [9:0] sp; 

    // LOGIK FÜR DIE RAM-ADRESSE:
    // Beim PUSH: Nutze aktuellen SP (da er auf das freie Feld zeigt).
    // Beim POP:  Nutze SP + 1 (da dort der letzte gültige Wert liegt).
    assign stack_addr = (pop) ? (sp + 10'd1) : sp;

    // Fehlerlogik:
    // Underflow: Wenn wir bei BASE sind und POP versuchen.
    // Overflow:  Wenn wir bei 0 sind und PUSH versuchen.
    assign error = (pop && sp == BASE) || (push && sp == 10'd0);

    always @(posedge CLK or posedge reset) begin
        if (reset) begin
            sp <= BASE; 
        end 
        else if (push && !error) begin
            // Erst wird der Wert an [sp] geschrieben (im RAM),
            // dann dekrementiert dieser Block den SP für den nächsten Befehl.
            sp <= sp - 10'd1;
        end 
        else if (pop && !error) begin
            // Der Wert wird von [sp+1] gelesen (siehe assign oben),
            // danach wird der SP hier wieder erhöht.
            sp <= sp + 10'd1;
        end
    end
endmodule