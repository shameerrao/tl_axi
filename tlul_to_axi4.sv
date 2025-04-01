// TileLink-UL to AXI4 Bridge

module tlul_to_axi4 #(
    parameter int unsigned DataWidth = 64,
    parameter int unsigned AddrWidth = 32,
    parameter int unsigned SourceWidth = 8,
    parameter int unsigned SinkWidth = 8,
    parameter int unsigned MaxSize = 6,
    parameter int unsigned IdWidth = 8
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
    input  logic axi_awready,

    output logic [IdWidth-1:0] axi_wid,
    output logic [DataWidth-1:0] axi_wdata,
    output logic [DataWidth/8-1:0] axi_wstrb,
    output logic axi_wlast,
    output logic axi_wvalid,
    input  logic axi_wready,

    input  logic [IdWidth-1:0] axi_bid,
    input  logic [1:0] axi_bresp,
    input  logic axi_bvalid,
    output logic axi_bready,

    output logic [IdWidth-1:0] axi_arid,
    output logic [AddrWidth-1:0] axi_araddr,
    output logic [7:0] axi_arlen,
    output logic [2:0] axi_arsize,
    output logic [1:0] axi_arburst,
    output logic axi_arlock,
    output logic [3:0] axi_arcache,
    output logic [2:0] axi_arprot,
    output logic [3:0] axi_arqos,
    output logic [3:0] axi_arregion,
    output logic axi_arvalid,
    input  logic axi_arready,

    input  logic [IdWidth-1:0] axi_rid,
    input  logic [DataWidth-1:0] axi_rdata,
    input  logic [1:0] axi_rresp,
    input  logic axi_rlast,
    input  logic axi_rvalid,
    output logic axi_rready
);

    // Internal state
    typedef enum logic [2:0] {
        IDLE,
        WRITE_ADDR,
        WRITE_DATA,
        WRITE_RESP,
        READ_ADDR,
        READ_DATA
    } state_t;

    state_t state_q, state_d;
    logic [IdWidth-1:0] id_q, id_d;
    logic [SourceWidth-1:0] source_q, source_d;
    logic [AddrWidth-1:0] addr_q, addr_d;
    logic [DataWidth-1:0] data_q, data_d;
    logic [DataWidth/8-1:0] mask_q, mask_d;
    logic [MaxSize-1:0] size_q, size_d;
    logic [2:0] opcode_q, opcode_d;

    // State machine
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q <= IDLE;
            id_q <= '0;
            source_q <= '0;
            addr_q <= '0;
            data_q <= '0;
            mask_q <= '0;
            size_q <= '0;
            opcode_q <= '0;
        end else begin
            state_q <= state_d;
            id_q <= id_d;
            source_q <= source_d;
            addr_q <= addr_d;
            data_q <= data_d;
            mask_q <= mask_d;
            size_q <= size_d;
            opcode_q <= opcode_d;
        end
    end

    // Next state logic
    always_comb begin
        state_d = state_q;
        id_d = id_q;
        source_d = source_q;
        addr_d = addr_q;
        data_d = data_q;
        mask_d = mask_q;
        size_d = size_q;
        opcode_d = opcode_q;

        case (state_q)
            IDLE: begin
                if (tl_a_valid) begin
                    case (tl_a_opcode)
                        3'b000: begin // Get
                            state_d = READ_ADDR;
                            id_d = tl_a_source;
                            source_d = tl_a_source;
                            addr_d = tl_a_address;
                            size_d = tl_a_size;
                            opcode_d = tl_a_opcode;
                        end
                        3'b001: begin // PutFullData
                            state_d = WRITE_ADDR;
                            id_d = tl_a_source;
                            source_d = tl_a_source;
                            addr_d = tl_a_address;
                            data_d = tl_a_data;
                            mask_d = tl_a_mask;
                            size_d = tl_a_size;
                            opcode_d = tl_a_opcode;
                        end
                    endcase
                end
            end

            WRITE_ADDR: begin
                if (axi_awready) begin
                    state_d = WRITE_DATA;
                end
            end

            WRITE_DATA: begin
                if (axi_wready) begin
                    state_d = WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                if (axi_bvalid) begin
                    state_d = IDLE;
                end
            end

            READ_ADDR: begin
                if (axi_arready) begin
                    state_d = READ_DATA;
                end
            end

            READ_DATA: begin
                if (axi_rvalid && axi_rlast) begin
                    state_d = IDLE;
                end
            end
        endcase
    end

    // AXI4 Write Address Channel
    assign axi_awid = id_q;
    assign axi_awaddr = addr_q;
    assign axi_awlen = 8'h0; // Single transfer
    assign axi_awsize = size_q;
    assign axi_awburst = 2'b01; // INCR
    assign axi_awlock = 1'b0;
    assign axi_awcache = 4'b0011;
    assign axi_awprot = 3'b000;
    assign axi_awqos = 4'h0;
    assign axi_awregion = 4'h0;
    assign axi_awvalid = (state_q == WRITE_ADDR);

    // AXI4 Write Data Channel
    assign axi_wid = id_q;
    assign axi_wdata = data_q;
    assign axi_wstrb = mask_q;
    assign axi_wlast = 1'b1;
    assign axi_wvalid = (state_q == WRITE_DATA);

    // AXI4 Write Response Channel
    assign axi_bready = (state_q == WRITE_RESP);

    // AXI4 Read Address Channel
    assign axi_arid = id_q;
    assign axi_araddr = addr_q;
    assign axi_arlen = 8'h0; // Single transfer
    assign axi_arsize = size_q;
    assign axi_arburst = 2'b01; // INCR
    assign axi_arlock = 1'b0;
    assign axi_arcache = 4'b0011;
    assign axi_arprot = 3'b000;
    assign axi_arqos = 4'h0;
    assign axi_arregion = 4'h0;
    assign axi_arvalid = (state_q == READ_ADDR);

    // AXI4 Read Data Channel
    assign axi_rready = (state_q == READ_DATA);

    // TileLink-UL Response Channel
    assign tl_d_valid = (state_q == READ_DATA && axi_rvalid && axi_rlast) ||
                       (state_q == WRITE_RESP && axi_bvalid);
    assign tl_d_source = source_q;
    assign tl_d_sink = '0;
    assign tl_d_error = (state_q == READ_DATA) ? axi_rresp : axi_bresp;
    assign tl_d_opcode = (state_q == READ_DATA) ? 3'b010 : 3'b000; // AccessAckData for read, AccessAck for write
    assign tl_d_param = '0;
    assign tl_d_corrupt = '0;
    assign tl_d_address = addr_q;
    assign tl_d_data = (state_q == READ_DATA) ? axi_rdata : '0;

    // TileLink-UL Request Channel
    assign tl_a_ready = (state_q == IDLE);

endmodule 