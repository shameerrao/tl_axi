// Testbench for TileLink-UL to AXI4 Bridge

module tlul_to_axi4_tb;

    // Parameters
    parameter int unsigned DataWidth = 64;
    parameter int unsigned AddrWidth = 32;
    parameter int unsigned SourceWidth = 8;
    parameter int unsigned SinkWidth = 8;
    parameter int unsigned MaxSize = 6;
    parameter int unsigned IdWidth = 8;

    // Clock and reset
    logic clk;
    logic rst_n;

    // TileLink-UL interface
    logic [AddrWidth-1:0] tl_a_address;
    logic [DataWidth-1:0] tl_a_data;
    logic tl_a_valid;
    logic tl_a_ready;
    logic [SourceWidth-1:0] tl_a_source;
    logic [MaxSize-1:0] tl_a_size;
    logic [2:0] tl_a_opcode;
    logic [DataWidth/8-1:0] tl_a_mask;
    logic [2:0] tl_a_param;
    logic [3:0] tl_a_corrupt;

    logic [AddrWidth-1:0] tl_d_address;
    logic [DataWidth-1:0] tl_d_data;
    logic tl_d_valid;
    logic tl_d_ready;
    logic [SourceWidth-1:0] tl_d_source;
    logic [SinkWidth-1:0] tl_d_sink;
    logic [1:0] tl_d_error;
    logic [2:0] tl_d_opcode;
    logic [1:0] tl_d_param;
    logic [3:0] tl_d_corrupt;

    // AXI4 interface
    logic [IdWidth-1:0] axi_awid;
    logic [AddrWidth-1:0] axi_awaddr;
    logic [7:0] axi_awlen;
    logic [2:0] axi_awsize;
    logic [1:0] axi_awburst;
    logic axi_awlock;
    logic [3:0] axi_awcache;
    logic [2:0] axi_awprot;
    logic [3:0] axi_awqos;
    logic [3:0] axi_awregion;
    logic axi_awvalid;
    logic axi_awready;

    logic [IdWidth-1:0] axi_wid;
    logic [DataWidth-1:0] axi_wdata;
    logic [DataWidth/8-1:0] axi_wstrb;
    logic axi_wlast;
    logic axi_wvalid;
    logic axi_wready;

    logic [IdWidth-1:0] axi_bid;
    logic [1:0] axi_bresp;
    logic axi_bvalid;
    logic axi_bready;

    logic [IdWidth-1:0] axi_arid;
    logic [AddrWidth-1:0] axi_araddr;
    logic [7:0] axi_arlen;
    logic [2:0] axi_arsize;
    logic [1:0] axi_arburst;
    logic axi_arlock;
    logic [3:0] axi_arcache;
    logic [2:0] axi_arprot;
    logic [3:0] axi_arqos;
    logic [3:0] axi_arregion;
    logic axi_arvalid;
    logic axi_arready;

    logic [IdWidth-1:0] axi_rid;
    logic [DataWidth-1:0] axi_rdata;
    logic [1:0] axi_rresp;
    logic axi_rlast;
    logic axi_rvalid;
    logic axi_rready;

    // DUT instantiation
    tlul_to_axi4 #(
        .DataWidth(DataWidth),
        .AddrWidth(AddrWidth),
        .SourceWidth(SourceWidth),
        .SinkWidth(SinkWidth),
        .MaxSize(MaxSize),
        .IdWidth(IdWidth)
    ) dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        .tl_a_address(tl_a_address),
        .tl_a_data(tl_a_data),
        .tl_a_valid(tl_a_valid),
        .tl_a_ready(tl_a_ready),
        .tl_a_source(tl_a_source),
        .tl_a_size(tl_a_size),
        .tl_a_opcode(tl_a_opcode),
        .tl_a_mask(tl_a_mask),
        .tl_a_param(tl_a_param),
        .tl_a_corrupt(tl_a_corrupt),
        .tl_d_address(tl_d_address),
        .tl_d_data(tl_d_data),
        .tl_d_valid(tl_d_valid),
        .tl_d_ready(tl_d_ready),
        .tl_d_source(tl_d_source),
        .tl_d_sink(tl_d_sink),
        .tl_d_error(tl_d_error),
        .tl_d_opcode(tl_d_opcode),
        .tl_d_param(tl_d_param),
        .tl_d_corrupt(tl_d_corrupt),
        .axi_awid(axi_awid),
        .axi_awaddr(axi_awaddr),
        .axi_awlen(axi_awlen),
        .axi_awsize(axi_awsize),
        .axi_awburst(axi_awburst),
        .axi_awlock(axi_awlock),
        .axi_awcache(axi_awcache),
        .axi_awprot(axi_awprot),
        .axi_awqos(axi_awqos),
        .axi_awregion(axi_awregion),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_wid(axi_wid),
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wlast(axi_wlast),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),
        .axi_bid(axi_bid),
        .axi_bresp(axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),
        .axi_arid(axi_arid),
        .axi_araddr(axi_araddr),
        .axi_arlen(axi_arlen),
        .axi_arsize(axi_arsize),
        .axi_arburst(axi_arburst),
        .axi_arlock(axi_arlock),
        .axi_arcache(axi_arcache),
        .axi_arprot(axi_arprot),
        .axi_arqos(axi_arqos),
        .axi_arregion(axi_arregion),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),
        .axi_rid(axi_rid),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rlast(axi_rlast),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Waveform dumping
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tlul_to_axi4_tb);
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 1;
        tl_a_address = '0;
        tl_a_data = '0;
        tl_a_valid = 0;
        tl_a_source = '0;
        tl_a_size = '0;
        tl_a_opcode = '0;
        tl_a_mask = '0;
        tl_a_param = '0;
        tl_a_corrupt = '0;
        tl_d_ready = 1;
        axi_awready = 1;
        axi_wready = 1;
        axi_bvalid = 0;
        axi_bid = '0;
        axi_bresp = '0;
        axi_arready = 1;
        axi_rid = '0;
        axi_rdata = '0;
        axi_rresp = '0;
        axi_rlast = 0;
        axi_rvalid = 0;

        // Reset
        #10 rst_n = 0;
        #20 rst_n = 1;
        #10;

        // Test Case 1: Write Operation
        $display("Test Case 1: Write Operation");
        @(posedge clk);
        tl_a_valid = 1;
        tl_a_address = 32'h1000;
        tl_a_data = 64'hA5A5A5A5A5A5A5A5;
        tl_a_source = 8'h01;
        tl_a_size = 6'h3;
        tl_a_opcode = 3'b001; // PutFullData
        tl_a_mask = 8'hFF;
        @(posedge clk);
        while (!tl_a_ready) @(posedge clk);
        tl_a_valid = 0;
        @(posedge clk);

        // Simulate AXI write response
        @(posedge clk);
        axi_bvalid = 1;
        axi_bid = 8'h01;
        axi_bresp = 2'b00;
        @(posedge clk);
        while (!axi_bready) @(posedge clk);
        axi_bvalid = 0;
        @(posedge clk);

        // Test Case 2: Read Operation
        $display("Test Case 2: Read Operation");
        @(posedge clk);
        tl_a_valid = 1;
        tl_a_address = 32'h2000;
        tl_a_source = 8'h02;
        tl_a_size = 6'h3;
        tl_a_opcode = 3'b000; // Get
        @(posedge clk);
        while (!tl_a_ready) @(posedge clk);
        tl_a_valid = 0;
        @(posedge clk);

        // Simulate AXI read response
        @(posedge clk);
        axi_rvalid = 1;
        axi_rid = 8'h02;
        axi_rdata = 64'hB5B5B5B5B5B5B5B5;
        axi_rresp = 2'b00;
        axi_rlast = 1;
        @(posedge clk);
        while (!axi_rready) @(posedge clk);
        axi_rvalid = 0;
        axi_rlast = 0;
        @(posedge clk);

        // Test Case 3: Write with Different Size
        $display("Test Case 3: Write with Different Size");
        @(posedge clk);
        tl_a_valid = 1;
        tl_a_address = 32'h3000;
        tl_a_data = 64'hC5C5C5C5C5C5C5C5;
        tl_a_source = 8'h03;
        tl_a_size = 6'h2;
        tl_a_opcode = 3'b001; // PutFullData
        tl_a_mask = 8'h0F;
        @(posedge clk);
        while (!tl_a_ready) @(posedge clk);
        tl_a_valid = 0;
        @(posedge clk);

        // Simulate AXI write response
        @(posedge clk);
        axi_bvalid = 1;
        axi_bid = 8'h03;
        axi_bresp = 2'b00;
        @(posedge clk);
        while (!axi_bready) @(posedge clk);
        axi_bvalid = 0;
        @(posedge clk);

        // Test Case 4: Read with Error Response
        $display("Test Case 4: Read with Error Response");
        @(posedge clk);
        tl_a_valid = 1;
        tl_a_address = 32'h4000;
        tl_a_source = 8'h04;
        tl_a_size = 6'h3;
        tl_a_opcode = 3'b000; // Get
        @(posedge clk);
        while (!tl_a_ready) @(posedge clk);
        tl_a_valid = 0;
        @(posedge clk);

        // Simulate AXI read error response
        @(posedge clk);
        axi_rvalid = 1;
        axi_rid = 8'h04;
        axi_rdata = 64'hD5D5D5D5D5D5D5D5;
        axi_rresp = 2'b10; // SLVERR
        axi_rlast = 1;
        @(posedge clk);
        while (!axi_rready) @(posedge clk);
        axi_rvalid = 0;
        axi_rlast = 0;
        @(posedge clk);

        // End simulation
        #100;
        $display("Simulation completed");
        $finish;
    end

    // Monitor responses
    always @(posedge clk) begin
        if (tl_d_valid && tl_d_ready) begin
            case (tl_d_opcode)
                3'b000: $display("Received AccessAck: source=%h, error=%b", tl_d_source, tl_d_error);
                3'b010: $display("Received AccessAckData: source=%h, data=%h, error=%b", 
                               tl_d_source, tl_d_data, tl_d_error);
            endcase
        end
    end

endmodule 