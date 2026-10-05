`timescale 1ns / 1ps

module tb_regfile;
    // Eingangssignale
    reg [4:0] ReadReg0;
    reg [4:0] ReadReg1;
    reg [4:0] WriteReg;
    reg [23:0] WriteData;
    reg RegWrite;
    reg Clk;
    
    // Ausgangssignale
    wire [23:0] ReadData0;
    wire [23:0] ReadData1;
    
    // Instanz des Register File
    regfile uut (
        .ReadReg0(ReadReg0),
        .ReadReg1(ReadReg1),
        .WriteReg(WriteReg),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .Clk(Clk),
        .ReadData0(ReadData0),
        .ReadData1(ReadData1)
    );
    
    // Clock-Generator (10ns Periode = 100 MHz)
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end
    
    // Testvariablen
    integer errors = 0;
    integer tests = 0;
    integer i;
    
    // Task zum Schreiben eines Registers
    task write_reg;
        input [4:0] reg_addr;
        input [23:0] data;
        begin
            WriteReg = reg_addr;
            WriteData = data;
            RegWrite = 1;
            #10; // Warte auf steigende Flanke
            RegWrite = 0;
            #1;
        end
    endtask
    
    // Task zum Lesen und Überprüfen
    task check_read;
        input [4:0] reg_addr;
        input [23:0] expected_data;
        input [200*8:1] test_name;
        begin
            tests = tests + 1;
            ReadReg0 = reg_addr;
            #1;
            if (ReadData0 !== expected_data) begin
                $display("FEHLER: %0s", test_name);
                $display("  Register: %0d", reg_addr);
                $display("  Erwartet: %h", expected_data);
                $display("  Erhalten: %h", ReadData0);
                errors = errors + 1;
            end else begin
                $display("OK: %0s - Reg[%0d]=%h", test_name, reg_addr, ReadData0);
            end
        end
    endtask
    
    // Task zum Testen von zwei gleichzeitigen Lesezugriffen
    task check_dual_read;
        input [4:0] reg0;
        input [4:0] reg1;
        input [23:0] expected0;
        input [23:0] expected1;
        input [200*8:1] test_name;
        begin
            tests = tests + 1;
            ReadReg0 = reg0;
            ReadReg1 = reg1;
            #1;
            if (ReadData0 !== expected0 || ReadData1 !== expected1) begin
                $display("FEHLER: %0s", test_name);
                $display("  Reg0=%0d: Erwartet=%h, Erhalten=%h", reg0, expected0, ReadData0);
                $display("  Reg1=%0d: Erwartet=%h, Erhalten=%h", reg1, expected1, ReadData1);
                errors = errors + 1;
            end else begin
                $display("OK: %0s - Reg[%0d]=%h, Reg[%0d]=%h", test_name, reg0, ReadData0, reg1, ReadData1);
            end
        end
    endtask
    
    initial begin
        $display("=== Register File Test Bench Start ===");
        $display("");
        
        // Initialisierung
        ReadReg0 = 0;
        ReadReg1 = 0;
        WriteReg = 0;
        WriteData = 0;
        RegWrite = 0;
        #10;
        
        // Test 1: Schreibe und lese normale Register (0-27)
        $display("--- Test 1: Normale Register (0-27) ---");
        write_reg(5'd0, 24'h0000AA);
        check_read(5'd0, 24'h0000AA, "Schreibe/Lese Register 0");
        
        write_reg(5'd5, 24'h0000FF);
        check_read(5'd5, 24'h0000FF, "Schreibe/Lese Register 5");
        
        write_reg(5'd27, 24'h000055);
        check_read(5'd27, 24'h000055, "Schreibe/Lese Register 27");
        
        // Test 2: Flags Register (Adresse 28, 3-Bit)
        $display("--- Test 2: Flags Register (28) ---");
        write_reg(5'd28, 24'h000007); // Alle 3 Bits setzen
        check_read(5'd28, 24'h000007, "Flags Register: 0b111");
        
        write_reg(5'd28, 24'h000005); // 0b101
        check_read(5'd28, 24'h000005, "Flags Register: 0b101");
        
        write_reg(5'd28, 24'h000000); // Alle löschen
        check_read(5'd28, 24'h000000, "Flags Register: 0b000");
        
        // Test 3: Address Register 0 (Adresse 29, 10-Bit)
        $display("--- Test 3: Address Register 0 (29) ---");
        write_reg(5'd29, 24'h0003FF); // Max 10-Bit
        check_read(5'd29, 24'h0003FF, "AddrReg0: 0x3FF");
        
        write_reg(5'd29, 24'h000100);
        check_read(5'd29, 24'h000100, "AddrReg0: 0x100");
        
        // Test 4: Address Register 1 (Adresse 30, 10-Bit)
        $display("--- Test 4: Address Register 1 (30) ---");
        write_reg(5'd30, 24'h000200);
        check_read(5'd30, 24'h000200, "AddrReg1: 0x200");
        
        // Test 5: Instruction Register (Adresse 31, 24-Bit)
        $display("--- Test 5: Instruction Register (31) ---");
        write_reg(5'd31, 24'hABCDEF);
        check_read(5'd31, 24'hABCDEF, "InstrReg: 0xABCDEF");
        
        write_reg(5'd31, 24'h123456);
        check_read(5'd31, 24'h123456, "InstrReg: 0x123456");
        
        // Test 6: Gleichzeitiges Lesen von zwei Registern
        $display("--- Test 6: Dual Port Read ---");
        write_reg(5'd10, 24'h0000AA);
        write_reg(5'd11, 24'h0000BB);
        check_dual_read(5'd10, 5'd11, 24'h0000AA, 24'h0000BB, "Lese Reg10 und Reg11 gleichzeitig");
        
        // Test 7: Lese Flags und InstrReg gleichzeitig
        write_reg(5'd28, 24'h000003);
        write_reg(5'd31, 24'hFEDCBA);
        check_dual_read(5'd28, 5'd31, 24'h000003, 24'hFEDCBA, "Lese Flags und InstrReg gleichzeitig");
        
        // Test 8: Schreiben ohne RegWrite sollte nichts ändern
        $display("--- Test 8: Schreiben ohne RegWrite ---");
        write_reg(5'd15, 24'h0000DD);
        WriteReg = 5'd15;
        WriteData = 24'h0000EE;
        RegWrite = 0; // Nicht schreiben
        #10;
        check_read(5'd15, 24'h0000DD, "Ohne RegWrite: Reg15 unverändert");
        
        // Test 9: Mehrere Register nacheinander schreiben und lesen
        $display("--- Test 9: Mehrere Register ---");
        for (i = 0; i < 10; i = i + 1) begin
            write_reg(i, 24'h000000 + i);
        end
        
        for (i = 0; i < 10; i = i + 1) begin
            ReadReg0 = i;
            #1;
            tests = tests + 1;
            if (ReadData0[7:0] !== i[7:0]) begin
                $display("FEHLER: Register %0d hat falschen Wert %h (erwartet %h)", i, ReadData0, i);
                errors = errors + 1;
            end else begin
                $display("OK: Register %0d = %h", i, ReadData0[7:0]);
            end
        end
        
        // Test 10: Maskierung der Bitbreiten
        $display("--- Test 10: Bitbreiten-Maskierung ---");
        // Normale Register sollten nur 8 Bit speichern
        write_reg(5'd1, 24'hFFFFFF);
        check_read(5'd1, 24'h0000FF, "Reg1: Nur niedrige 8 Bit gespeichert");
        
        // Flags sollten nur 3 Bit speichern
        write_reg(5'd28, 24'hFFFFFF);
        check_read(5'd28, 24'h000007, "Flags: Nur niedrige 3 Bit gespeichert");
        
        // AddrReg sollten nur 10 Bit speichern
        write_reg(5'd29, 24'hFFFFFF);
        check_read(5'd29, 24'h0003FF, "AddrReg0: Nur niedrige 10 Bit gespeichert");
        
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
