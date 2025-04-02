// TileLink-UL to AXI4 Bridge Implementation

module tlul_to_axi4 #(
    parameter int DataWidth = 64,
    parameter int AddrWidth = 32,
    parameter int SourceWidth = 8,
    parameter int SinkWidth = 8,
    parameter int MaxSize = 6,
    parameter int IdWidth = 8
) (
    // Clock and reset
    input  logic clk_i,
    input  logic rst_ni,

    // TileLink-UL interface
    input  logic [AddrWidth-1:0] tl_a_address,
    input  logic [DataWidth-1:0] tl_a_data,
    input  logic tl_a_valid,
    output logic tl_a_ready,
    input  logic [SourceWidth-1:0] tl_a_source,
    input  logic [MaxSize-1:0] tl_a_size,
    input  logic [2:0] tl_a_opcode,
    input  logic [DataWidth/8-1:0] tl_a_mask,
    input  logic [2:0] tl_a_param,
    input  logic [3:0] tl_a_corrupt,

    output logic [AddrWidth-1:0] tl_d_address,
    output logic [DataWidth-1:0] tl_d_data,
    output logic tl_d_valid,
    input  logic tl_d_ready,
    output logic [SourceWidth-1:0] tl_d_source,
    output logic [SinkWidth-1:0] tl_d_sink,
    output logic [1:0] tl_d_error,
    output logic [2:0] tl_d_opcode,
    output logic [1:0] tl_d_param,
    output logic [3:0] tl_d_corrupt,

    // AXI4 interface
    output logic [IdWidth-1:0] axi_awid,
    output logic [AddrWidth-1:0] axi_awaddr,
    output logic [7:0] axi_awlen,
    output logic [2:0] axi_awsize,
    output logic [1:0] axi_awburst,
    output logic axi_awlock,
    output logic [3:0] axi_awcache,
    output logic [2:0] axi_awprot,
    output logic [3:0] axi_awqos,
    output logic [3:0] axi_awregion,
    output logic axi_awvalid,
    input  logic axi_awready
);

    // Internal state
    typedef enum logic [2:0] {
        IDLE = 3'h0,
        DECODE = 3'h1,
        WRITE = 3'h2,
        READ = 3'h3,
        RESPONSE = 3'h4
    } state_t;

    // Opcode definitions
    typedef enum logic [2:0] {
        PutFullData = 3'h1,
        PutPartialData = 3'h2,
        Acquire = 3'h3,
        Get = 3'h4,
        ArithmeticData = 3'h5,
        LogicalData = 3'h6,
        Intent = 3'h7,
        Probe = 3'h0
    } opcode_t;

    state_t state, next_state;
    logic [SourceWidth-1:0] current_source;
    logic [AddrWidth-1:0] current_address;
    logic [DataWidth-1:0] current_data;
    logic [MaxSize-1:0] current_size;
    logic [2:0] current_opcode;
    logic [DataWidth/8-1:0] current_mask;
    logic [2:0] current_param;
    logic [3:0] current_corrupt;

    // State machine and register updates
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
            current_source <= '0;
            current_address <= '0;
            current_data <= '0;
            current_size <= '0;
            current_opcode <= '0;
            current_mask <= '0;
            current_param <= '0;
            current_corrupt <= '0;
        end else begin
            state <= next_state;
            if (state == IDLE && tl_a_valid) begin
                current_source <= tl_a_source;
                current_address <= tl_a_address;
                current_data <= tl_a_data;
                current_size <= tl_a_size;
                current_opcode <= tl_a_opcode;
                current_mask <= tl_a_mask;
                current_param <= tl_a_param;
                current_corrupt <= tl_a_corrupt;
            end
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: begin
                next_state = tl_a_valid ? DECODE : IDLE;
            end

            DECODE: begin
                case (tl_a_opcode)
                    PutFullData, PutPartialData: next_state = WRITE;
                    Get: next_state = READ;
                    default: next_state = RESPONSE;
                endcase
            end

            WRITE: begin
                next_state = axi_awready ? RESPONSE : WRITE;
            end

            READ: begin
                next_state = RESPONSE;
            end

            RESPONSE: begin
                next_state = tl_d_ready ? IDLE : RESPONSE;
            end

            default: next_state = IDLE;
        endcase
    end

    // AXI4 write address channel
    assign axi_awid = current_source;
    assign axi_awaddr = current_address;
    assign axi_awlen = (current_size == 6'h3) ? 8'h0 : 8'h1; // Single transfer for now
    assign axi_awsize = current_size[2:0];
    assign axi_awburst = 2'b01; // INCR burst type
    assign axi_awlock = 1'b0;
    assign axi_awcache = 4'h0;
    assign axi_awprot = 3'h0;
    assign axi_awqos = 4'h0;
    assign axi_awregion = 4'h0;
    assign axi_awvalid = (state == WRITE);

    // TileLink-UL response channel
    assign tl_d_address = current_address;
    assign tl_d_data = current_data;
    assign tl_d_valid = (state == RESPONSE);
    assign tl_d_source = current_source;
    assign tl_d_sink = '0; // Not used in this implementation
    assign tl_d_error = (current_corrupt != 0) ? 2'b01 : 2'b00;
    assign tl_d_opcode = current_opcode;
    assign tl_d_param = current_param[1:0]; // Truncate to 2 bits
    assign tl_d_corrupt = current_corrupt;

    // TileLink-UL ready signal
    assign tl_a_ready = (state == IDLE);

endmodule 