`timescale 1ns / 1ps

module tb_pc;
    // Eingangssignale
    reg Clk;
    reg Reset;
    reg EnableIncr;
    reg EnableJump;
    reg [9:0] JumpAddr;
    
    // Ausgangssignale
    wire [9:0] PCout;
    
    // Instanz des Program Counter
    pc uut (
        .Clk(Clk),
        .Reset(Reset),
        .EnableIncr(EnableIncr),
        .EnableJump(EnableJump),
        .JumpAddr(JumpAddr),
        .PCout(PCout)
    );
    
    // Clock-Generator (10ns Periode = 100 MHz)
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end
    
    // Testvariablen
    integer errors = 0;
    integer tests = 0;
    
    // Task zum Überprüfen der Ergebnisse
    task check_pc;
        input [9:0] expected_pc;
        input [200*8:1] test_name;
        begin
            tests = tests + 1;
            #1; // Warte kurz für Signalstabilisierung
            if (PCout !== expected_pc) begin
                $display("FEHLER: %0s", test_name);
                $display("  Erwartet: PCout=%h (%0d)", expected_pc, expected_pc);
                $display("  Erhalten: PCout=%h (%0d)", PCout, PCout);
                errors = errors + 1;
            end else begin
                $display("OK: %0s - PCout=%h (%0d)", test_name, PCout, PCout);
            end
        end
    endtask
    
    initial begin
        $display("=== Program Counter Test Bench Start ===");
        $display("");
        
        // Initialisierung
        Reset = 0;
        EnableIncr = 0;
        EnableJump = 0;
        JumpAddr = 10'h000;
        
        // Test 1: Reset
        $display("--- Test 1: Reset ---");
        Reset = 1;
        #10;
        check_pc(10'h000, "Reset: PC sollte 0 sein");
        Reset = 0;
        #10;
        
        // Test 2: Increment
        $display("--- Test 2: Increment ---");
        EnableIncr = 1;
        #10; // Warte auf steigende Flanke
        check_pc(10'h001, "Increment: PC = 1");
        #10;
        check_pc(10'h002, "Increment: PC = 2");
        #10;
        check_pc(10'h003, "Increment: PC = 3");
        #10;
        check_pc(10'h004, "Increment: PC = 4");
        
        // Test 3: Increment deaktivieren (PC soll stehen bleiben)
        $display("--- Test 3: Kein Increment ---");
        EnableIncr = 0;
        #10;
        check_pc(10'h004, "Kein Increment: PC bleibt bei 4");
        #10;
        check_pc(10'h004, "Kein Increment: PC bleibt bei 4");
        
        // Test 4: Jump
        $display("--- Test 4: Jump ---");
        EnableJump = 1;
        JumpAddr = 10'h100;
        #10;
        check_pc(10'h100, "Jump: PC = 0x100");
        EnableJump = 0;
        
        // Test 5: Jump zu verschiedenen Adressen
        $display("--- Test 5: Weitere Jumps ---");
        EnableJump = 1;
        JumpAddr = 10'h3FF;
        #10;
        check_pc(10'h3FF, "Jump: PC = 0x3FF");
        
        JumpAddr = 10'h000;
        #10;
        check_pc(10'h000, "Jump: PC = 0x000");
        EnableJump = 0;
        
        // Test 6: Increment nach Jump
        $display("--- Test 6: Increment nach Jump ---");
        EnableIncr = 1;
        #10;
        check_pc(10'h001, "Nach Jump: Increment auf 1");
        #10;
        check_pc(10'h002, "Nach Jump: Increment auf 2");
        
        // Test 7: Jump hat Priorität über Increment
        $display("--- Test 7: Jump Priorität ---");
        EnableIncr = 1;
        EnableJump = 1;
        JumpAddr = 10'h200;
        #10;
        check_pc(10'h200, "Jump + Increment: Jump hat Priorität");
        EnableJump = 0;
        
        #10;
        check_pc(10'h201, "Nach Jump: Increment funktioniert");
        
        // Test 8: Reset während Betrieb
        $display("--- Test 8: Reset während Betrieb ---");
        EnableIncr = 1;
        #10;
        check_pc(10'h202, "Vor Reset: PC = 0x202");
        
        Reset = 1;
        #10;
        check_pc(10'h000, "Nach Reset: PC = 0");
        Reset = 0;
        
        // Test 9: Increment bis zum Überlauf
        $display("--- Test 9: Überlauf Test ---");
        EnableJump = 1;
        JumpAddr = 10'h3FE;
        EnableIncr = 0;
        #10;
        EnableJump = 0;
        EnableIncr = 1;
        check_pc(10'h3FE, "Vor Überlauf: PC = 0x3FE");
        #10;
        check_pc(10'h3FF, "Vor Überlauf: PC = 0x3FF");
        #10;
        check_pc(10'h000, "Überlauf: PC = 0x000 (wraparound)");
        #10;
        check_pc(10'h001, "Nach Überlauf: PC = 0x001");
        
        // Zusammenfassung
        $display("");
        $display("=== Test Zusammenfassung ===");
        $display("Tests durchgeführt: %0d", tests);
        $display("Fehler: %0d", errors);
        if (errors == 0) begin
            $display("ALLE TESTS BESTANDEN!");
        end else begin
            $display("EINIGE TESTS FEHLGESCHLAGEN!");
        end
        $display("");
        
        $finish;
    end
    
endmodule
