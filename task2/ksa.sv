`timescale 1ps / 1ps

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    logic [7:0] i;
    logic [7:0] s_i;
    logic [7:0] temp_si;
    logic [7:0] j;
    logic [7:0] s_j;
    logic [8:0] counter;

    enum {INITALIZE, READ_i, READ_j, WRITE_i, WRITE_j, ERROR} state;

    always_ff @(posedge clk)begin
    
        if(~rst_n) begin
            state <= INITALIZE;
            counter <= 0;
            i <= 0;
            j <= 0;
            s_i <= 0;
            s_j <= 0;
        end
        
        else begin

            case (state)

                INITALIZE: begin
					 
						  counter <= 0;
                    i <= 0;
                    j <= 0;
                    s_i <= 0;
                    s_j <= 0; 

                    if(en)
                        state <= READ_i;
                    
                    else
                        state <= INITALIZE;
                end

                READ_i: begin 
								state <= READ_j;
					 end


                READ_j: begin
					 
								state <= WRITE_i;
								i <= i;
							   s_i <= rddata;
							   j <= j + rddata + key[23 - (8 * (i % 3)) -: 8]; 
								s_j <= s_j;
					end


                WRITE_i: begin
							state <= WRITE_j;
							i <= i;
							j <= j;
							s_i <= s_i;
							s_j <= rddata;
					 end
					 
                WRITE_j: begin
					 
					     j <= j;
                    s_i <= s_i;
                    i <= i + 1;
                    counter <= counter + 1;
                    s_j <= s_j;
                    
                    if(counter < 255)
                        state <= READ_i;

                    else
                        state <= INITALIZE;
                end

                default: begin
							state <= ERROR;
							i <= i;
							j <= j;
							s_i <= s_i;
							s_j <= s_j;
					 end
            endcase
        end
    end

    /* Outputs

        rdy
        addr
        wrdata
        wren
    */

    always_comb begin

        case (state)

            INITALIZE: begin

                rdy = 1'b1;
                addr = 0;
                wrdata = 0;
                wren = 0;
                temp_si = 'x;
            end

            READ_i: begin

                rdy = 0;
                addr = i;
                wrdata = 0;
                wren = 0;
                temp_si = 'x;
            end

            READ_j: begin
                
                temp_si = rddata;
                addr = j + rddata + key[23 - (8 * (i % 3)) -: 8];

                rdy = 0;
                wrdata = 0;
                wren = 0;
            end

            WRITE_i: begin

                rdy = 0;
                addr = i;
                wrdata = rddata;
                wren = 1;
                temp_si = 'x;
            end

            WRITE_j: begin

                rdy = 0;
                addr = j;
                wrdata = s_i;
                wren = 1;
                temp_si = 'x;
            end

            default: begin
                
                rdy = 0;
                addr = 0;
                wrdata = 0;
                wren = 0;
                temp_si = 'x;
            end
        endcase   
    end
endmodule: ksa