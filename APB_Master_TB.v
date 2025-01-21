module tb_apb_master;

    // Testbench signals
    reg clk;
    reg resetn;
    reg start;            // Start signal for initiating the transaction
    reg write;            // Write control signal (1 = write, 0 = read)
    reg [7:0] addr;       // Address for APB transaction (8-bit)
    reg [7:0] wdata;      // Write data (8-bit)
    wire psel;
    wire penable;
    wire pwrite;
    wire [7:0] paddr;
    wire [7:0] pwdata;
    wire [7:0] prdata;
    wire pready;
    wire pslverr;

    // Instantiate the APB Master
    apb_master uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Clock period is 10 time units
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;
        start = 0;
        write = 0;
        addr = 8'h00;   // 8-bit address
        wdata = 8'hFF;  // 8-bit write data

        // Apply reset
        resetn = 0;
        #10 resetn = 1;
        
        // Write operation test
        #10;
        start = 1;
        addr = 8'h10;   // Set address to 0x10
        write = 1;      // Write operation
        #10;
        start = 0;

        // Wait for some cycles
        #20;
        
        // Read operation test
        start = 1;
        write = 0;      // Read operation
        addr = 8'h10;   // Read from the same address 0x10
        #10;
        start = 0;

        // Finish simulation after some time
        #50;
        $stop;
    end

endmodule

