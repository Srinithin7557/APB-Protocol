module apb_master(
    input wire        clk,             // Clock signal
    input wire        resetn,          // Active-low reset
    input wire        start,           // Start signal for initiating the transaction
    input wire        write,           // Write control signal (1 = write, 0 = read)
    input wire [7:0]  addr,            // APB Address (8-bit)
    input wire [7:0]  wdata,           // APB Write Data (8-bit)
    output reg        psel,            // APB Select
    output reg        penable,         // APB Enable
    output reg        pwrite,          // APB Write/Read control
    output reg [7:0]  paddr,           // APB Address (8-bit)
    output reg [7:0]  pwdata,          // APB Write Data (8-bit)
    input wire [7:0]  prdata,          // APB Read Data (8-bit)
    input wire        pready,          // APB Ready signal from slave
    output reg        pslverr          // APB Slave Error
);

// State machine states (without typedef)
localparam IDLE        = 2'b00;
localparam ADDR_PHASE  = 2'b01;
localparam DATA_PHASE  = 2'b10;
localparam WAIT_PHASE  = 2'b11;

reg [1:0] state, next_state;

// APB Master State Machine
always @(posedge clk or negedge resetn) begin
    if (~resetn)
        state <= IDLE;
    else
        state <= next_state;
end

// Next state logic
always @(*) begin
    case (state)
        IDLE: begin
            if (start)       // Initiate the transaction when 'start' is high
                next_state = ADDR_PHASE;
            else
                next_state = IDLE;
        end

        ADDR_PHASE: begin
            next_state = DATA_PHASE;
        end

        DATA_PHASE: begin
            if (pready)      // Transition to WAIT_PHASE when slave is ready
                next_state = WAIT_PHASE;
            else
                next_state = DATA_PHASE;
        end

        WAIT_PHASE: begin
            next_state = IDLE;  // After the transaction completes, go back to IDLE
        end

        default: next_state = IDLE;
    endcase
end

// Output logic (controls the APB interface)
always @(state or start or addr or wdata or write or pready) begin
    case (state)
        IDLE: begin
            psel     = 0;
            penable  = 0;
            pwrite   = 0;
            paddr    = 8'b0;
            pwdata   = 8'b0;
            pslverr  = 0;
        end

        ADDR_PHASE: begin
            psel     = 1;           // Select the slave
            penable  = 0;           // Address phase
            pwrite   = write;       // Set the read/write flag
            paddr    = addr;        // Set the address
            pwdata   = wdata;       // Set the write data (if write)
            pslverr  = 0;           // Clear any slave error
        end

        DATA_PHASE: begin
            psel     = 1;           // Select the slave
            penable  = 1;           // Enable the transaction
            pwrite   = write;       // Set the read/write flag
            paddr    = addr;        // Set the address
            pwdata   = wdata;       // Set the write data (if write)
            pslverr  = 0;           // Clear any slave error
        end

        WAIT_PHASE: begin
            if (!pready) begin
                pslverr = 1;      // If the slave is not ready, there is an error
            end else begin
                pslverr = 0;      // No error, transaction successful
            end
            psel     = 0;          // Deselect the slave
            penable  = 0;          // Disable the transaction
            pwrite   = 0;          // No more read/write operations
            paddr    = 8'b0;       // Clear address
            pwdata   = 8'b0;       // Clear write data
        end

        default: begin
            psel     = 0;
            penable  = 0;
            pwrite   = 0;
            paddr    = 8'b0;
            pwdata   = 8'b0;
            pslverr  = 0;
        end
    endcase
end

endmodule

