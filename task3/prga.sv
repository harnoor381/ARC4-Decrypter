module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);


    logic [7:0] i, j, k, message_length;
    logic [7:0] temp_si, temp_sj;
	 logic [7:0] pad [0:255];

    typedef enum {INIT,
						FETCH_MSG_LENGTH,
						READ_I,
						READ_J, 
						UPDATE_I, 
						UPDATE_J,
						READ_PAD,
						UPDATE_PAD, 
						WRITE_PT0,
						READ_CT,
						WRITE_PT, 
						DONE} state_t;
						
		state_t state;
						
	// values affected:
	// i, j, k, message_length, temp_si, temp_sj, pad, state

    always_ff @(posedge clk)begin
    
        if(~rst_n) begin
            state <= INIT;
            i <= 0;
            j <= 0;
				k <= 0;
            temp_si <= 0;
				temp_sj <= 0;
				pad <= '{default: 8'd0};
				message_length <= 0;
        end
        
        else begin

            case (state)

                INIT: begin
					 
                    i <= 0;
                    j <= 0;
						  k <= 1;
                    temp_si <= 0;
						  temp_sj <= 0;
						  pad <= '{default: 8'd0};
						  message_length <= 0;

                    if(en)
                        state <= FETCH_MSG_LENGTH;
                    
                    else
                        state <= INIT;
                end
					 
					 FETCH_MSG_LENGTH: begin
					 
						  i <= i;
                    j <= j;
						  k <= 1;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= ct_rddata;
						  state <= READ_I;
							
					 end

                READ_I: begin
						  
						  i <= i + 1;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= READ_J;
								
					 end


                READ_J: begin
					 
						  i <= i;
                    j <= j + s_rddata;
						  k <= k;
                    temp_si <= s_rddata;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= UPDATE_I;
					 
								
					 end


                UPDATE_I: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= s_rddata;
						  pad <= pad;
						  message_length <= message_length;
						  state <= UPDATE_J;
							
					 end
					 
                UPDATE_J: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= READ_PAD;
					 
                    
					 end
					 
					 READ_PAD: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= UPDATE_PAD;
							
					 end
					 
					 UPDATE_PAD: begin
					 
						  i <= i;
                    j <= j;
						  k <= (k > message_length) ? 8'd1: k + 1;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad[k] <= s_rddata;
						  message_length <= message_length;
						  state <= (k > message_length) ? WRITE_PT0 : READ_I;
							
					 end
					 
					 WRITE_PT0: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= READ_CT;
						
					 end
					
					 READ_CT: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= WRITE_PT;
						
					 end
					
					 WRITE_PT: begin
					 
						  i <= i;
                    j <= j;
						  k <= k + 1;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= (k > message_length) ? DONE : READ_CT;
				
					 end
					 
					 DONE: begin
					 
						  i <= i;
                    j <= j;
						  k <= k;
                    temp_si <= temp_si;
						  temp_sj <= temp_sj;
						  pad <= pad;
						  message_length <= message_length;
						  state <= DONE;
				
					 end

                default: begin
					 
							state <= INIT;
							i <= 0;
							j <= 0;
							k <= 0;
							temp_si <= 0;
							temp_sj <= 0;
							pad <= '{default: 8'd0};
							message_length <= 0;
							
					 end
            endcase
        end
    end

	 // values affected:
	 //s_addr, s_wrdata, s_wren,
	 //ct_addr
    //pt_addr pt_wrdata, pt_wren, rdy

    always_comb begin
	 
		 s_addr = 8'd0;
		 s_wrdata = 8'd0;
		 s_wren = 1'b0;
		 ct_addr = 8'd0;
		 pt_addr = 8'd0;
		 pt_wrdata = 8'd0;
		 pt_wren = 1'b0;
		 rdy = 1'b0;

        case (state)

					INIT: begin
					
					s_addr = 8'd0;
					s_wrdata = 8'd0;
					s_wren = 0;
					ct_addr = 8'd0;
					pt_addr = 8'd0;
					pt_wrdata = 8'd0;
					pt_wren = 0;
					rdy = 1;	 
							  
					end
						 
					FETCH_MSG_LENGTH: begin
					
					s_addr = s_addr;
					s_wrdata = s_wrdata;
					s_wren = s_wren;
					ct_addr = 8'd0;
					pt_addr = pt_addr;
					pt_wrdata = pt_wrdata;
					pt_wren = pt_wren;
					rdy = 0;
						 
					end

					READ_I: begin
				
					s_addr = i + 1;
					s_wrdata = s_wrdata;
					s_wren = 0;
					ct_addr = ct_addr;
					pt_addr = pt_addr;
					pt_wrdata = pt_wrdata;
					pt_wren = pt_wren;
					rdy = 0;
									
					end


					READ_J: begin
					
					s_addr = j + s_rddata;
					s_wrdata = s_wrdata;
					s_wren = 0;
					ct_addr = ct_addr;
					pt_addr = pt_addr;
					pt_wrdata = pt_wrdata;
					pt_wren = pt_wren;
					rdy = 0;
						 				
					end


                UPDATE_I: begin
					 
					 s_addr = i;
					 s_wrdata = s_rddata;
					 s_wren = 1;
					 ct_addr = ct_addr;
					 pt_addr = pt_addr;
					 pt_wrdata = pt_wrdata;
					 pt_wren = pt_wren;
					 rdy = 0;
							
					 end
					 
                UPDATE_J: begin
					 
					 s_addr = j;
					 s_wrdata = temp_si;
					 s_wren = 1;
					 ct_addr = ct_addr;
					 pt_addr = pt_addr;
					 pt_wrdata = pt_wrdata;
					 pt_wren = pt_wren;
					 rdy = 0;
					    
					 end
					 
					 READ_PAD: begin
					 
					 s_addr = temp_si + temp_sj;
					 s_wrdata = s_wrdata;
					 s_wren = 0;
					 ct_addr = ct_addr;
					 pt_addr = pt_addr;
					 pt_wrdata = pt_wrdata;
					 pt_wren = pt_wren;
					 rdy = 0;
							
					 end
					 
					 UPDATE_PAD: begin
					 
					 s_addr = s_addr;
					 s_wrdata = s_wrdata;
					 s_wren = s_wren;
					 ct_addr = ct_addr;
					 pt_addr = pt_addr;
					 pt_wrdata = pt_wrdata;
					 pt_wren = pt_wren;
					 rdy = 0;
							
					 end
					 
					 WRITE_PT0: begin
					 
					 s_addr = s_addr;
					 s_wrdata = s_wrdata;
					 s_wren = s_wren;
					 ct_addr = ct_addr;
					 pt_addr = 8'd0;
					 pt_wrdata = message_length;
					 pt_wren = 1;
					 rdy = 0;
						
					 end
					
					 READ_CT: begin
					 
					 s_addr = s_addr;
					 s_wrdata = s_wrdata;
					 s_wren = s_wren;
					 ct_addr = k;
					 pt_addr = pt_addr;
					 pt_wrdata = message_length;
					 pt_wren = 0;
					 rdy = 0;
						
					 end
					
					 WRITE_PT: begin
					 
					 s_addr = s_addr;
					 s_wrdata = s_wrdata;
					 s_wren = s_wren;
					 ct_addr = ct_addr;
					 pt_addr = k;
					 pt_wrdata = pad[k] ^ ct_rddata;
					 pt_wren = 1;
					 rdy = 0;
				
					 end
					 
					 DONE: begin
					 
					 s_addr = s_addr;
					 s_wrdata = s_wrdata;
					 s_wren = s_wren;
					 ct_addr = ct_addr;
					 pt_addr = pt_addr;
					 pt_wrdata = pt_wrdata;
					 pt_wren = 0;
					 rdy = 1;
				
					 end

                default: begin
					 
					   s_addr = 8'd0;
						s_wrdata = 8'd0;
						s_wren = 0;
						ct_addr = 8'd0;
						pt_addr = 8'd0;
						pt_wrdata = 8'd0;
						pt_wren = 0;
						rdy = 1;	
							
					 end
            endcase   
    end

endmodule: prga
