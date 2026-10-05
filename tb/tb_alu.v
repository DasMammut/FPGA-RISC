`timescale 1ns / 1ps

module tb_alu;
    // Eingangssignale
    reg [7:0] A;
    reg [7:0] B;
    reg [5:0] Op;
    reg [1:0] FlagsIn;
    
    // Ausgangssignale
    wire [7:0] Result;
    wire [1:0] FlagsOut;
    
    // Instanz der ALU
    alu uut (
        .A(A),
        .B(B),
        .Op(Op),
        .Result(Result),
        .FlagsIn(FlagsIn),
        .FlagsOut(FlagsOut)
    );
    
    // Testvariablen
    integer errors = 0;
    integer tests = 0;
    
    // Task zum Überprüfen der Ergebnisse
    task check_result;
        input [7:0] expected_result;
        input [1:0] expected_flags;
        input [200*8:1] test_name;
        begin
            tests = tests + 1;
            #1; // Warte kurz für Signalstabilisierung
            if (Result !== expected_result || FlagsOut !== expected_flags) begin
                $display("FEHLER: %0s", test_name);
                $display("  A=%h, B=%h, Op=%b, FlagsIn=%b", A, B, Op, FlagsIn);
                $display("  Erwartet: Result=%h, Flags=%b", expected_result, expected_flags);
                $display("  Erhalten: Result=%h, Flags=%b", Result, FlagsOut);
                errors = errors + 1;
            end else begin
                $display("OK: %0s", test_name);
            end
        end
    endtask
    
    initial begin
        $display("=== ALU Test Bench Start ===");
        $display("");
        
        // Initialisierung
        A = 0;
        B = 0;
        Op = 0;
        FlagsIn = 0;
        #10;
        
        // Test 1: ADD (Op = 001001)
        $display("--- Test ADD Operation ---");
        A = 8'h0F; B = 8'h10; Op = 6'b001001; FlagsIn = 2'b00;
        check_result(8'h1F, 2'b00, "ADD: 0x0F + 0x10 = 0x1F (keine Flags)");
        
        A = 8'h00; B = 8'h00; Op = 6'b001001; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "ADD: 0x00 + 0x00 = 0x00 (Zero Flag)");
        
        A = 8'hFF; B = 8'h01; Op = 6'b001001; FlagsIn = 2'b00;
        check_result(8'h00, 2'b11, "ADD: 0xFF + 0x01 = 0x00 (Zero + Carry)");
        
        A = 8'h80; B = 8'h80; Op = 6'b001001; FlagsIn = 2'b00;
        check_result(8'h00, 2'b11, "ADD: 0x80 + 0x80 = 0x00 (Overflow)");
        
        // Test 2: ADI (Op = 001011)
        $display("--- Test ADI Operation ---");
        A = 8'h05; B = 8'h03; Op = 6'b001011; FlagsIn = 2'b00;
        check_result(8'h08, 2'b00, "ADI: 0x05 + 0x03 = 0x08");
        
        // Test 3: ADC (Op = 001010) - Add with Carry
        $display("--- Test ADC Operation ---");
        A = 8'h0F; B = 8'h10; Op = 6'b001010; FlagsIn = 2'b00;
        check_result(8'h1F, 2'b00, "ADC: 0x0F + 0x10 + 0 = 0x1F");
        
        A = 8'h0F; B = 8'h10; Op = 6'b001010; FlagsIn = 2'b10;
        check_result(8'h20, 2'b00, "ADC: 0x0F + 0x10 + 1 = 0x20");
        
        A = 8'hFF; B = 8'h00; Op = 6'b001010; FlagsIn = 2'b10;
        check_result(8'h00, 2'b11, "ADC: 0xFF + 0x00 + 1 = 0x00 (Overflow)");
        
        // Test 4: SUB (Op = 001100)
        $display("--- Test SUB Operation ---");
        A = 8'h20; B = 8'h10; Op = 6'b001100; FlagsIn = 2'b00;
        check_result(8'h10, 2'b00, "SUB: 0x20 - 0x10 = 0x10");
        
        A = 8'h10; B = 8'h10; Op = 6'b001100; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "SUB: 0x10 - 0x10 = 0x00 (Zero Flag)");
        
        A = 8'h10; B = 8'h20; Op = 6'b001100; FlagsIn = 2'b00;
        check_result(8'hF0, 2'b10, "SUB: 0x10 - 0x20 = 0xF0 (Carry/Borrow)");
        
        // Test 5: SBI (Op = 001101)
        $display("--- Test SBI Operation ---");
        A = 8'h50; B = 8'h30; Op = 6'b001101; FlagsIn = 2'b00;
        check_result(8'h20, 2'b00, "SBI: 0x50 - 0x30 = 0x20");
        
        // Test 6: SHR (Op = 001110)
        $display("--- Test SHR Operation ---");
        A = 8'b10101010; B = 8'h00; Op = 6'b001110; FlagsIn = 2'b00;
        check_result(8'b01010101, 2'b00, "SHR: 0xAA >> 1 = 0x55 (LSB=0)");
        
        A = 8'b10101011; B = 8'h00; Op = 6'b001110; FlagsIn = 2'b00;
        check_result(8'b01010101, 2'b10, "SHR: 0xAB >> 1 = 0x55 (LSB=1, Carry)");
        
        A = 8'b00000001; B = 8'h00; Op = 6'b001110; FlagsIn = 2'b00;
        check_result(8'b00000000, 2'b11, "SHR: 0x01 >> 1 = 0x00 (Zero + Carry)");
        
        // Test 7: AND (Op = 001111)
        $display("--- Test AND Operation ---");
        A = 8'hFF; B = 8'h0F; Op = 6'b001111; FlagsIn = 2'b00;
        check_result(8'h0F, 2'b00, "AND: 0xFF & 0x0F = 0x0F");
        
        A = 8'hF0; B = 8'h0F; Op = 6'b001111; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "AND: 0xF0 & 0x0F = 0x00 (Zero Flag)");
        
        // Test 8: IOR (Op = 010000)
        $display("--- Test IOR Operation ---");
        A = 8'hF0; B = 8'h0F; Op = 6'b010000; FlagsIn = 2'b00;
        check_result(8'hFF, 2'b00, "IOR: 0xF0 | 0x0F = 0xFF");
        
        A = 8'h00; B = 8'h00; Op = 6'b010000; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "IOR: 0x00 | 0x00 = 0x00 (Zero Flag)");
        
        // Test 9: XOR (Op = 010001)
        $display("--- Test XOR Operation ---");
        A = 8'hFF; B = 8'hFF; Op = 6'b010001; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "XOR: 0xFF ^ 0xFF = 0x00 (Zero Flag)");
        
        A = 8'hAA; B = 8'h55; Op = 6'b010001; FlagsIn = 2'b00;
        check_result(8'hFF, 2'b00, "XOR: 0xAA ^ 0x55 = 0xFF");
        
        // Test 10: NAND (Op = 010010)
        $display("--- Test NAND Operation ---");
        A = 8'hFF; B = 8'hFF; Op = 6'b010010; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "NAND: ~(0xFF & 0xFF) = 0x00");
        
        A = 8'h00; B = 8'h00; Op = 6'b010010; FlagsIn = 2'b00;
        check_result(8'hFF, 2'b00, "NAND: ~(0x00 & 0x00) = 0xFF");
        
        // Test 11: NOR (Op = 010011)
        $display("--- Test NOR Operation ---");
        A = 8'h00; B = 8'h00; Op = 6'b010011; FlagsIn = 2'b00;
        check_result(8'hFF, 2'b00, "NOR: ~(0x00 | 0x00) = 0xFF");
        
        A = 8'hFF; B = 8'hFF; Op = 6'b010011; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "NOR: ~(0xFF | 0xFF) = 0x00");
        
        // Test 12: XNOR (Op = 010100)
        $display("--- Test XNOR Operation ---");
        A = 8'hAA; B = 8'hAA; Op = 6'b010100; FlagsIn = 2'b00;
        check_result(8'hFF, 2'b00, "XNOR: ~(0xAA ^ 0xAA) = 0xFF");
        
        A = 8'hAA; B = 8'h55; Op = 6'b010100; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "XNOR: ~(0xAA ^ 0x55) = 0x00");
        
        // Test 13: NOT (Op = 010101)
        $display("--- Test NOT Operation ---");
        A = 8'hAA; B = 8'h00; Op = 6'b010101; FlagsIn = 2'b00;
        check_result(8'h55, 2'b00, "NOT: ~0xAA = 0x55");
        
        A = 8'hFF; B = 8'h00; Op = 6'b010101; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "NOT: ~0xFF = 0x00 (Zero Flag)");
        
        // Test 14: CMP (Op = 010110)
        $display("--- Test CMP Operation ---");
        A = 8'h20; B = 8'h10; Op = 6'b010110; FlagsIn = 2'b00;
        check_result(8'h00, 2'b00, "CMP: 0x20 - 0x10 (Result=0, A>B)");
        
        A = 8'h10; B = 8'h10; Op = 6'b010110; FlagsIn = 2'b00;
        check_result(8'h00, 2'b01, "CMP: 0x10 - 0x10 (Zero Flag, A=B)");
        
        A = 8'h10; B = 8'h20; Op = 6'b010110; FlagsIn = 2'b00;
        check_result(8'h00, 2'b10, "CMP: 0x10 - 0x20 (Carry Flag, A<B)");
        
        // Test 15: Default/Ungültige Operation
        $display("--- Test Default/Unknown Operation ---");
        A = 8'h12; B = 8'h34; Op = 6'b000000; FlagsIn = 2'b11;
        check_result(8'h00, 2'b11, "Default: Ungültige Op, Result=0, Flags=FlagsIn");
        
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
