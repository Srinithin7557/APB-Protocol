module tb_apb_top;

    // Testbench signals
    reg clk;
    reg resetn;
    reg start;
    reg write;
    reg [7:0] addr;
    reg [7:0] wdata;
    wire [7:0] prdata;
    wire pready;
    wire pslverr;

    // Instantiate the top module
    apb_top uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 10 time unit clock period
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;
        start = 0;
        write = 0;
        addr = 8'h00;   // Address for slave1
        wdata = 8'h55;  // Write data for slave1

        // Apply reset
        resetn = 0;
        #10 resetn = 1;

        // Write operation to slave1 (address < 0x80)
        #10;
        start = 1;
        addr = 8'h10;  // Write to slave1 (address < 0x80)
        write = 1;     // Write operation
        #10;
        start = 0;

        // Wait for some cycles
        #20;

        // Read from slave1
        #10;
        start = 1;
        addr = 8'h10;  // Read from slave1 (address < 0x80)
        write = 0;     // Read operation
        #10;
        start = 0;

        // Write to slave2 (address >= 0x80)
        #10;
        start = 1;
        addr = 8'h80;  // Write to slave2 (address >= 0x80)
        write = 1;     // Write operation
        #10;
        start = 0;

        // Wait for some cycles
        #20;

        // Read from slave2
        #10;
        start = 1;
        addr = 8'h80;  // Read from slave2 (address >= 0x80)
        write = 0;     // Read operation
        #10;
        start = 0;

        // Finish simulation after some time
        #50;
        $stop;
    end

endmodule

