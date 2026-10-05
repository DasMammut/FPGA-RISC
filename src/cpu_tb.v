`timescale 1ns / 1ps

module cpu_tb();
    reg clk;
    reg reset;
    wire hlt;

    // Hilfsvariable für die Schleife
    integer i;

    // Deine CPU einbinden
    cpu_top uut (
        .CLK(clk),
        .Reset(reset),
        .CLK_HLT(hlt)
    );

    // Takt-Generator: Alle 5ns wechselt der Status (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Simulation startet...");
        clk = 0;
        reset = 1;      // Reset aktivieren
        #20 reset = 0;  // Nach 20ns Reset lösen
        
        // Warten bis die CPU den HLT-Befehl erreicht
        wait(hlt); 
        #10; // Kurz warten, damit der letzte Schreibvorgang sicher im Registerfile landet
        
        $display("\n--- REGISTER WERTE (R1 bis R31) ---");
        // Schleife von 1 bis 31
        for (i = 1; i <= 31; i = i + 1) begin
            // Zugriff auf das Register-Array in deiner regfile-Instanz innerhalb von uut
            $display("Register R%0d: %d", i, uut.registerfile.Register[i]);
        end
        $display("-----------------------------------\n");

        $display("HLT-Befehl erkannt. Test beendet.");
        $finish;
    end

    // Diese Zeilen erzeugen eine Datei für den Waveform-Viewer (z.B. GTKWave)
    initial begin
        $dumpfile("cpu_waves.vcd");
        $dumpvars(0, cpu_tb);
    end
endmodule