// Testbench for TileLink-UL to AXI4 Bridge

module tlul_to_axi4_tb;

    // Parameters
    parameter int DataWidth = 64;
    parameter int AddrWidth = 32;
    parameter int SourceWidth = 8;
    parameter int SinkWidth = 8;
    parameter int MaxSize = 6;
    parameter int IdWidth = 8;

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

    // Instantiate the DUT
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
        .axi_awready(axi_awready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Dump VCD file
    initial begin
        $dumpfile("tlul_to_axi4.vcd");
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

        // Reset
        #10 rst_n = 0;
        #20 rst_n = 1;

        // Test case 1: Simple write transaction (PutFullData)
        #10;
        $display("Test case 1: PutFullData transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h12345678;
        tl_a_data = 64'hAABBCCDDEEFF0011;
        tl_a_source = 8'h01;
        tl_a_size = 6'h3;
        tl_a_opcode = PutFullData;
        tl_a_mask = 8'hFF;
        tl_a_param = '0;
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 2: Read transaction (Get)
        #10;
        $display("Test case 2: Get transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h87654321;
        tl_a_data = '0;
        tl_a_source = 8'h02;
        tl_a_size = 6'h3;
        tl_a_opcode = Get;
        tl_a_mask = 8'hFF;
        tl_a_param = '0;
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 3: Partial write transaction (PutPartialData)
        #10;
        $display("Test case 3: PutPartialData transaction");
        tl_a_valid = 1;
        tl_a_address = 32'hABCDEF01;
        tl_a_data = 64'h1122334455667788;
        tl_a_source = 8'h03;
        tl_a_size = 6'h2;
        tl_a_opcode = PutPartialData;
        tl_a_mask = 8'h0F; // Only write lower 4 bytes
        tl_a_param = '0;
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 4: Arithmetic operation (ArithmeticData)
        #10;
        $display("Test case 4: ArithmeticData transaction");
        tl_a_valid = 1;
        tl_a_address = 32'hFEDCBA98;
        tl_a_data = 64'h1234567890ABCDEF;
        tl_a_source = 8'h04;
        tl_a_size = 6'h3;
        tl_a_opcode = ArithmeticData;
        tl_a_mask = 8'hFF;
        tl_a_param = 3'h1; // Add operation
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 5: Logical operation (LogicalData)
        #10;
        $display("Test case 5: LogicalData transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h98765432;
        tl_a_data = 64'hF0F0F0F0F0F0F0F0;
        tl_a_source = 8'h05;
        tl_a_size = 6'h3;
        tl_a_opcode = LogicalData;
        tl_a_mask = 8'hFF;
        tl_a_param = 3'h2; // XOR operation
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 6: Intent transaction
        #10;
        $display("Test case 6: Intent transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h11223344;
        tl_a_data = '0;
        tl_a_source = 8'h06;
        tl_a_size = '0;
        tl_a_opcode = Intent;
        tl_a_mask = '0;
        tl_a_param = '0;
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 7: Acquire transaction
        #10;
        $display("Test case 7: Acquire transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h55667788;
        tl_a_data = '0;
        tl_a_source = 8'h07;
        tl_a_size = '0;
        tl_a_opcode = Acquire;
        tl_a_mask = '0;
        tl_a_param = 3'h1; // Grow
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // Test case 8: Probe transaction
        #10;
        $display("Test case 8: Probe transaction");
        tl_a_valid = 1;
        tl_a_address = 32'h99AABBCC;
        tl_a_data = '0;
        tl_a_source = 8'h08;
        tl_a_size = '0;
        tl_a_opcode = Probe;
        tl_a_mask = '0;
        tl_a_param = '0;
        tl_a_corrupt = '0;
        #10;
        tl_a_valid = 0;
        #100;

        // End simulation
        #100;
        $display("Simulation completed");
        $finish;
    end

endmodule 