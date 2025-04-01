`timescale 1ps / 1ps
module tb_rtl_task1();

// Your testbench goes here.
// Testbench signals
    logic CLOCK_50;
    logic [3:0] KEY;


    // Instantiate the DUT (Device Under Test)
    task1 dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .HEX0(),
        .HEX1(),
        .HEX2(),
        .HEX3(),
        .HEX4(),
        .HEX5(),
        .LEDR()
    );

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50; // 20ns period clock
    end

    // Task to reset the DUT
    task reset_dut();
        begin
            KEY[3] = 0; // Active low reset
            #40;        // Hold reset for 4 clock cycles
            KEY[3] = 1;
            #20;        // Wait for reset release
        end
    endtask

    // Task to trigger enable by simulating a button press
    task enable_module();
        begin
            KEY[3] = 0; // Simulate button press to start init module
            #20;        // Hold for one cycle
            KEY[3] = 1; // Release
            #20;        // Wait for enable signal to propagate
        end
    endtask

    // Initial block for test sequences
    initial begin
        #10;
        // Apply reset
        reset_dut();
        #50;
        // Trigger enable to start `init` module operation
        enable_module();
        #20;
        $stop;
    end
endmodule: tb_rtl_task1
