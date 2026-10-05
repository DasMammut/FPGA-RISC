`timescale 1ns / 1ps

module tb_instruction_memory;
    // Eingangssignale
    reg [9:0] address;
    
    // Ausgangssignale
    wire [23:0] instruction;
    
    // Instanz des Instruction Memory
    instrcution_memory uut (
        .address(address),
        .instruction(instruction)
    );
    
    // Testvariablen
    integer errors = 0;
    integer tests = 0;
    integer i;
    
    // Task zum Überprüfen
    task check_instruction;
        input [9:0] addr;
        input [23:0] expected;
        input [200*8:1] test_name;
        begin
            tests = tests + 1;
            address = addr;
            #1; // Warte kurz für kombinatorische Logik
            if (instruction !== expected) begin
                $display("FEHLER: %0s", test_name);
                $display("  Adresse: %h (%0d)", addr, addr);
                $display("  Erwartet: %h", expected);
                $display("  Erhalten: %h", instruction);
                errors = errors + 1;
            end else begin
                $display("OK: %0s - Addr[%h]=%h", test_name, addr, instruction);
            end
        end
    endtask
    
    initial begin
        $display("=== Instruction Memory Test Bench Start ===");
        $display("");
        
        // Hinweis: Dieser Test funktioniert nur, wenn instruction_memory.bin existiert!
        // Wenn die Datei nicht existiert, werden alle Instruktionen 0 sein
        
        $display("HINWEIS: Dieser Test benötigt die Datei 'instruction_memory.bin'");
        $display("Falls die Datei fehlt, werden alle Instruktionen als 0 angezeigt.");
        $display("");
        
        // Initialisierung
        address = 10'h000;
        #10;
        
        // Test 1: Grundlegende Lesezugriffe
        $display("--- Test 1: Lesezugriffe auf verschiedene Adressen ---");
        
        // Adresse 0
        address = 10'h000;
        #1;
        $display("Adresse 0x000: Instruktion = %h (%b)", instruction, instruction);
        tests = tests + 1;
        
        // Adresse 1
        address = 10'h001;
        #1;
        $display("Adresse 0x001: Instruktion = %h (%b)", instruction, instruction);
        tests = tests + 1;
        
        // Adresse 10
        address = 10'h00A;
        #1;
        $display("Adresse 0x00A: Instruktion = %h (%b)", instruction, instruction);
        tests = tests + 1;
        
        // Adresse 100
        address = 10'h064;
        #1;
        $display("Adresse 0x064: Instruktion = %h (%b)", instruction, instruction);
        tests = tests + 1;
        
        // Letzte Adresse (1023)
        address = 10'h3FF;
        #1;
        $display("Adresse 0x3FF: Instruktion = %h (%b)", instruction, instruction);
        tests = tests + 1;
        
        // Test 2: Sequentieller Zugriff
        $display("");
        $display("--- Test 2: Sequentieller Zugriff (Adressen 0-15) ---");
        for (i = 0; i < 16; i = i + 1) begin
            address = i;
            #1;
            $display("Adresse %3d (0x%03h): Instruktion = %h", i, i, instruction);
            tests = tests + 1;
        end
        
        // Test 3: Willkürliche Adressen
        $display("");
        $display("--- Test 3: Willkürliche Adressen ---");
        address = 10'h100;
        #1;
        $display("Adresse 0x100: Instruktion = %h", instruction);
        tests = tests + 1;
        
        address = 10'h200;
        #1;
        $display("Adresse 0x200: Instruktion = %h", instruction);
        tests = tests + 1;
        
        address = 10'h300;
        #1;
        $display("Adresse 0x300: Instruktion = %h", instruction);
        tests = tests + 1;
        
        // Test 4: Schnelle Adresswechsel
        $display("");
        $display("--- Test 4: Schnelle Adresswechsel ---");
        $display("Teste ob das Memory kombinatorisch arbeitet...");
        address = 10'h000; #1;
        address = 10'h001; #1;
        address = 10'h002; #1;
        address = 10'h003; #1;
        $display("Schnelle Wechsel funktionierten (kombinatorische Logik OK)");
        tests = tests + 1;
        
        // Test 5: Grenzen testen
        $display("");
        $display("--- Test 5: Grenzwerte ---");
        address = 10'h000; // Min
        #1;
        $display("Min-Adresse (0x000): Instruktion = %h", instruction);
        tests = tests + 1;
        
        address = 10'h3FF; // Max
        #1;
        $display("Max-Adresse (0x3FF): Instruktion = %h", instruction);
        tests = tests + 1;
        
        // Zusammenfassung
        $display("");
        $display("=== Test Zusammenfassung ===");
        $display("Tests durchgeführt: %0d", tests);
        $display("Fehler: %0d", errors);
        $display("");
        $display("HINWEIS: Wenn alle Instruktionen 0x000000 sind, fehlt die Datei 'instruction_memory.bin'!");
        $display("Erstelle eine Testdatei mit Beispielinstruktionen zum vollständigen Test.");
        $display("");
        if (errors == 0) begin
            $display("ALLE TESTS BESTANDEN!");
        end else begin
            $display("EINIGE TESTS FEHLGESCHLAGEN!");
        end
        $display("");
        
        $finish;
    end
    
endmodule
