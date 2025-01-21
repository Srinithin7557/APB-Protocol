module apb_slave1(
    input wire        clk,              // Clock signal
    input wire        resetn,           // Active-low reset
    input wire        psel,             // APB Select signal
    input wire        penable,          // APB Enable signal
    input wire        pwrite,           // APB Write/Read control
    input wire [7:0]  paddr,            // APB Address (8-bit)
    input wire [7:0]  pwdata,           // APB Write Data (8-bit)
    output reg [7:0]  prdata,           // APB Read Data (8-bit)
    output reg        pready,           // APB Ready signal
    output reg        pslverr           // APB Slave Error
);

    // Internal registers to hold the slave data
    reg [7:0] mem [0:255];  // 256 x 8-bit memory for the slave

    // Slave State Machine for simple read/write
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            pready <= 0;
            pslverr <= 0;
        end else begin
            if (psel && penable) begin
                if (pwrite) begin  // Write Operation
                    if (paddr < 8'hFF) begin  // Address range check (simple)
                        mem[paddr] <= pwdata; // Write data to memory
                        pready <= 1;
                        pslverr <= 0;
                    end else begin
                        pslverr <= 1;  // Address error
                        pready <= 0;
                    end
                end else begin  // Read Operation
                    if (paddr < 8'hFF) begin
                        prdata <= mem[paddr]; // Read data from memory
                        pready <= 1;
                        pslverr <= 0;
                    end else begin
                        pslverr <= 1;  // Address error
                        pready <= 0;
                    end
                end
            end else begin
                pready <= 0;
                pslverr <= 0;
            end
        end
    end

endmodule

