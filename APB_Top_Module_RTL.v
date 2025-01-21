module apb_top (
    input wire        clk,           // Clock signal
    input wire        resetn,        // Active-low reset
    input wire        start,         // Start signal for master
    input wire        write,         // Write/Read control (1 = write, 0 = read)
    input wire [7:0]  addr,          // 8-bit address
    input wire [7:0]  wdata,         // 8-bit write data
    output wire [7:0] prdata,        // 8-bit read data from slave
    output wire       pready,        // APB Ready signal from slave
    output wire       pslverr        // Slave error signal
);

    // Internal signals for slave selection and APB interface
    wire psel_slave1, psel_slave2;
    wire [7:0] prdata_slave1, prdata_slave2;
    wire pready_slave1, pready_slave2;
    wire pslverr_slave1, pslverr_slave2;

    // Instantiate APB Master
    apb_master master_inst (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .prdata(prdata),   // Read data from either slave
        .pready(pready)    // APB Ready from either slave
        // Do not drive pslverr here
    );

    // Instantiate APB Slave 1
    apb_slave1 slave1_inst (
        .clk(clk),
        .resetn(resetn),
        .psel(psel_slave1),
        .penable(1),      // Always enable for simplicity
        .pwrite(write),
        .paddr(addr),
        .pwdata(wdata),
        .prdata(prdata_slave1),
        .pready(pready_slave1),
        .pslverr(pslverr_slave1)  // Slave error signal for slave1
    );

    // Instantiate APB Slave 2
    apb_slave2 slave2_inst (
        .clk(clk),
        .resetn(resetn),
        .psel(psel_slave2),
        .penable(1),      // Always enable for simplicity
        .pwrite(write),
        .paddr(addr),
        .pwdata(wdata),
        .prdata(prdata_slave2),
        .pready(pready_slave2),
        .pslverr(pslverr_slave2)  // Slave error signal for slave2
    );

    // Address decoding logic to select the slave
    assign psel_slave1 = (addr < 8'h80);   // Select slave1 for address < 0x80
    assign psel_slave2 = (addr >= 8'h80);  // Select slave2 for address >= 0x80

    // Output logic: combine the responses from both slaves
    assign prdata = (psel_slave1) ? prdata_slave1 : prdata_slave2;
    assign pready = (psel_slave1) ? pready_slave1 : pready_slave2;
    // Assign pslverr based on the active slave (only one slave should have an error at a time)
    assign pslverr = (psel_slave1) ? pslverr_slave1 : pslverr_slave2;

endmodule

