module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic [7:0] addr, wrdata, q;
    logic en, wren, rdy;
	enum {s0} ps;
    
    s_mem s(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata),
            .wren(wren),
            .q(q)
            );

    // your code here
    always_ff @(posedge CLOCK_50) begin 
		if(!KEY[3]) begin 
			en <= 1'b1;
			ps <= s0;
        end
		else begin 
			case(ps) 
			s0 : begin 
				en  <= 1'b0;
				ps <= s0;
			end 
			endcase
		end
    end
    init n(.clk(CLOCK_50),
            .rst_n(KEY[3]),
            .en(en),
            .rdy(rdy),
            .addr(addr),
            .wrdata(wrdata),
            .wren(wren)
            );

endmodule: task1