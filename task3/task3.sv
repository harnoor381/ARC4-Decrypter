module task3(
    input logic CLOCK_50,
    input logic [3:0] KEY,
    input logic [9:0] SW,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output logic [9:0] LEDR
);

    // Control and data signals
    logic en_arc4, rdy_arc4;
    logic [7:0] ct_addr, ct_data;
    logic [7:0] pt_addr, pt_data_in, pt_data_out;
    logic pt_wren;
    
    // Instantiate ciphertext memory (ct_mem) - read-only memory
    ct_mem ct(
        .address(ct_addr),
        .clock(CLOCK_50),
        .q(ct_data)    // Connect data output
    );

    // Instantiate plaintext memory (pt_mem) - writable memory for decrypted data
    pt_mem pt(
        .address(pt_addr),
        .clock(CLOCK_50),
        .data(pt_data_in),   // Connect data input for writing
        .wren(pt_wren),      // Enable writing
        .q(pt_data_out)      // Connect data output (optional if you need to read back)
    );

    // Instantiate ARC4 decryption module
    arc4 a4(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(en_arc4),
        .rdy(rdy_arc4),
        .key({14'b0, SW}),   // Assuming 24-bit key is provided via SW
        .ct_addr(ct_addr),
        .ct_rddata(ct_data),
        .pt_addr(pt_addr),
        .pt_rddata(pt_data_out),
        .pt_wrdata(pt_data_in),
        .pt_wren(pt_wren)
    );

    // Enable the ARC4 decryption when KEY[0] is pressed
    assign en_arc4 = KEY[0];

    // Display signals for debugging (optional)
    assign LEDR[0] = rdy_arc4;       // Show when the decryption is complete
    assign HEX0 = 7'b1111111;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;

endmodule : task3
