`timescale 1ps / 1ps
module tb_syn_init();

// Your testbench goes here.
// Testbench signals
    logic clk;
    logic rst_n;
    logic en;
    logic rdy;
    logic [7:0] addr;
    logic [7:0] wrdata;
    logic wren;

    // Instantiate the DUT (Device Under Test)
    init dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .rdy(rdy),
        .addr(addr),
        .wrdata(wrdata),
        .wren(wren)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Task to reset the DUT
    task reset_dut();
        begin
            rst_n = 0;
            en = 0;
            #20; // Hold reset low for 2 clock cycles
            rst_n = 1;
            #10; // Wait for reset to release
        end
    endtask

    // Task to enable the module
    task enable_module();
        begin
            en = 1;
            #10; // Wait for enable to propagate
            en = 0;
        end
    endtask

    // Initial block for test sequences
    initial begin
        // Apply reset
        reset_dut();
        #270;
        enable_module();
        #100;
        reset_dut();
        #270;
        enable_module();
        #270;
        enable_module();
        #20;
        $stop;
    end
endmodule: tb_syn_init
