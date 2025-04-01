module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // Internal control and data signals
    logic en_init, en_ksa, rdy_init, rdy_ksa, wren, wren_init, wren_ksa;
    logic [7:0] addr, addr_init, addr_ksa, wrdata, wrdata_init, wrdata_ksa, rddata;

    // Instantiate init module (initializes S array)
    init init_inst(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(en_init),
        .rdy(rdy_init),
        .addr(addr_init),
        .wrdata(wrdata_init),
        .wren(wren_init)
    );

    // Instantiate ksa module (key-scheduling algorithm for RC4)
    ksa ksa_inst(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(en_ksa),
        .rdy(rdy_ksa),
        .key({14'b0, SW}),  // Assuming 24-bit key input from SW
        .addr(addr_ksa),
        .rddata(rddata),
        .wrdata(wrdata_ksa),
        .wren(wren_ksa)
    );

    // Instantiate single-port RAM (S array)
    s_mem s(
        .address(addr),
        .clock(CLOCK_50),
        .data(wrdata),
        .wren(wren),
        .q(rddata)
    );

    // State machine to control the sequential execution of init and ksa
    typedef enum logic [2:0] {
        INIT_IDLE,
        INIT_ACTIVE,
        INIT_DONE,
        KSA_IDLE,
        KSA_ACTIVE,
        KSA_DONE
    } state_t;
    
    state_t present_state = INIT_IDLE;

    always_ff @(posedge CLOCK_50) begin
        if (!KEY[3]) begin  // Active-low reset
            en_init <= 0;
            en_ksa <= 0;
            present_state <= INIT_IDLE;
        end 
        else begin
            case (present_state)
                
                INIT_IDLE: begin
                    if (rdy_init) begin   // Wait for init to be ready
                        en_init <= 1;     // Assert enable to start init
                        present_state <= INIT_ACTIVE;
                    end
                end

                INIT_ACTIVE: begin
                    en_init <= 0;         // Deassert enable after one cycle
                    if (!rdy_init)        // Wait until rdy_init deasserts and reasserts
                        present_state <= INIT_DONE;
                end

                INIT_DONE: begin
                    if (rdy_init) begin   // Confirm init completed
                        present_state <= KSA_IDLE;
                    end
                end

                KSA_IDLE: begin
                    if (rdy_ksa) begin    // Wait for ksa to be ready
                        en_ksa <= 1;      // Assert enable to start ksa
                        present_state <= KSA_ACTIVE;
                    end
                end

                KSA_ACTIVE: begin
                    en_ksa <= 0;          // Deassert enable after one cycle
                    if (!rdy_ksa)         // Wait until rdy_ksa deasserts and reasserts
                        present_state <= KSA_DONE;
                end

                KSA_DONE: begin
                    if (rdy_ksa) begin    // Confirm ksa completed
                        present_state <= KSA_DONE;  // Hold in DONE state (or add end logic if needed)
                    end
                end

            endcase
        end
    end

    // Multiplexer to manage shared RAM access between init and ksa
    always_comb begin
        case (present_state)
            INIT_IDLE, INIT_ACTIVE, INIT_DONE: begin
                addr = addr_init;
                wrdata = wrdata_init;
                wren = wren_init;
            end
            KSA_IDLE, KSA_ACTIVE, KSA_DONE: begin
                addr = addr_ksa;
                wrdata = wrdata_ksa;
                wren = wren_ksa;
            end
            default: begin
                addr = 8'bz;
                wrdata = 8'bz;
                wren = 1'bz;
            end
        endcase
    end

    // Display signals for debugging (optional)
    assign LEDR[9:0] = {rdy_ksa, rdy_init, present_state};
    assign HEX0 = 7'b1111111;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
	 
endmodule