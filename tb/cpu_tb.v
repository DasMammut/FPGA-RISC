`timescale 1ns / 1ps

module cpu_tb();
    reg clk;
    reg reset;
    wire hlt;

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
        
        // Simulation beenden, wenn HLT kommt oder nach 500ns
        wait(hlt); 
        #20;
        $display("HLT-Befehl erkannt. Test beendet.");
        $finish;
    end

    // Diese Zeilen erzeugen eine Datei für den Waveform-Viewer (z.B. GTKWave)
    initial begin
        $dumpfile("cpu_waves.vcd");
        $dumpvars(0, cpu_tb);
    end
endmodule