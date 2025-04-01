module arc4(
    input logic clk,
    input logic rst_n,
    input logic en,
    output logic rdy,
    input logic [23:0] key,
    output logic [7:0] ct_addr,
    input logic [7:0] ct_rddata,
    output logic [7:0] pt_addr,
    input logic [7:0] pt_rddata,
    output logic [7:0] pt_wrdata,
    output logic pt_wren
);

    // Internal control and data signals
    logic en_init, en_ksa, en_prga;
    logic rdy_init, rdy_ksa, rdy_prga;
    logic [7:0] s_addr, s_wrdata;
    logic s_wren;
    logic [7:0] s_rddata;  // Data read from s_mem

    logic [7:0] addr_init, wrdata_init;
    logic [7:0] addr_ksa, wrdata_ksa;
    logic [7:0] addr_prga, wrdata_prga;
    logic wren_init, wren_ksa, wren_prga;

    // Instantiate the s_mem module (for S array storage)
    s_mem s(
        .address(s_addr),
        .clock(clk),
        .data(s_wrdata),
        .wren(s_wren),
        .q(s_rddata)
    );

    // Instantiate init module
    init init_inst(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_init),
        .rdy(rdy_init),
        .addr(addr_init),
        .wrdata(wrdata_init),
        .wren(wren_init),
    );

    // Instantiate ksa module
    ksa ksa_inst(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_ksa),
        .rdy(rdy_ksa),
        .key(key),
        .addr(addr_ksa),
        .wrdata(wrdata_ksa),
        .wren(wren_ksa),
        .rddata(s_rddata)
    );

    // Instantiate prga module
    prga prga_inst(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_prga),
        .rdy(rdy_prga),
        .key(key),
        .s_addr(addr_prga),
        .s_rddata(s_rddata),
        .s_wrdata(wrdata_prga),
        .s_wren(wren_prga),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr),
        .pt_rddata(pt_rddata),
        .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren)
    );

    // State machine to control the sequential execution of init, ksa, and prga
    typedef enum logic [3:0] {
        INIT_IDLE,
        INIT_ACTIVE,
        INIT_DONE,
        KSA_IDLE,
        KSA_ACTIVE,
        KSA_DONE,
        PRGA_IDLE,
        PRGA_ACTIVE,
        PRGA_DONE
    } state_t;

    state_t present_state = INIT_IDLE;

    // Sequential state transitions
    always_ff @(posedge clk) begin
        if (!rst_n) begin
				rdy <= 1;
            present_state <= INIT_IDLE;
            en_init <= 0;
            en_ksa <= 0;
            en_prga <= 0;
        end else begin
            case (present_state)
                INIT_IDLE: begin
                    if (rdy && en) begin
                        en_init <= 1;  // Start init
                        present_state <= INIT_ACTIVE;
                    end
                end
                INIT_ACTIVE: begin
                    en_init <= 0;  // Deassert after one cycle
                    if (!rdy_init)
                        present_state <= INIT_DONE;
                end
                INIT_DONE: begin
                    if (rdy_init)
                        present_state <= KSA_IDLE;
                end
                KSA_IDLE: begin
                    if (rdy_ksa) begin
                        en_ksa <= 1;  // Start ksa
                        present_state <= KSA_ACTIVE;
                    end
                end
                KSA_ACTIVE: begin
                    en_ksa <= 0;  // Deassert after one cycle
                    if (!rdy_ksa)
                        present_state <= KSA_DONE;
                end
                KSA_DONE: begin
                    if (rdy_ksa)
                        present_state <= PRGA_IDLE;
                end
                PRGA_IDLE: begin
                    if (rdy_prga) begin
                        en_prga <= 1;  // Start prga
                        present_state <= PRGA_ACTIVE;
                    end
                end
                PRGA_ACTIVE: begin
                    en_prga <= 0;  // Deassert after one cycle
                    if (!rdy_prga)
                        present_state <= PRGA_DONE;
                end
                PRGA_DONE: begin
                    present_state <= PRGA_DONE;  // Stay in DONE state
                end
            endcase
        end
    end

    // Multiplexer to manage shared RAM access between init, ksa, and prga
    always_comb begin
        case (present_state)
            INIT_IDLE, INIT_ACTIVE, INIT_DONE: begin
                s_addr = addr_init;
                s_wrdata = wrdata_init;
                s_wren = wren_init;
            end
            KSA_IDLE, KSA_ACTIVE, KSA_DONE: begin
                s_addr = addr_ksa;
                s_wrdata = wrdata_ksa;
                s_wren = wren_ksa;
            end
            PRGA_IDLE, PRGA_ACTIVE, PRGA_DONE: begin
                s_addr = addr_prga;
                s_wrdata = wrdata_prga;
                s_wren = wren_prga;
            end
            default: begin
                s_addr = 8'b0;
                s_wrdata = 8'b0;
                s_wren = 1'b0;
            end
        endcase
    end

endmodule : arc4
