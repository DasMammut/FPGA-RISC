module ram(
    input [9:0] Addr,
    input [15:0] WriteData,
    input WriteEnable,
    input ReadEnable,
    input CLK,
    output reg [15:0] ReadData
);

    reg [15:0] memory [0:1023];

    always @(*) begin
        if (ReadEnable) begin
            ReadData = memory[Addr];
        end
    end

    always @(posedge CLK) begin
        if (WriteEnable) begin
            memory[Addr] <= WriteData;
        end
    end

endmodule