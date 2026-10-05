module regfile(
    input wire [4:0] ReadRegAddr0,
    input wire [4:0] ReadRegAddr1,
    input wire [4:0] WriteRegAddr,
    input wire [15:0] WriteData,
    input wire RegWriteEn,
    input wire CLK,
    output reg [15:0] ReadData0,
    output reg [15:0] ReadData1
);

    // Speicher-Definitionen
    reg [15:0] Register [31:1];       // Register 1 bis 31

    // --- LESEN (Kombinatorisch) ---
    always @(*) begin
        // Standardwert für Register 0 (Hardwired Zero)
        ReadData0 = 16'b0;
        if (ReadRegAddr0 >= 1 && ReadRegAddr0 <= 31) ReadData0 = Register[ReadRegAddr0];

        ReadData1 = 16'b0;
        if (ReadRegAddr1 >= 1 && ReadRegAddr1 <= 31) ReadData1 = Register[ReadRegAddr1];  
    end

    // --- SCHREIBEN (Synchron) ---
    always @(posedge CLK) begin
        if (RegWriteEn) begin
            if (WriteRegAddr >= 1 && WriteRegAddr <= 31) Register[WriteRegAddr] <= WriteData;
        end
    end

endmodule