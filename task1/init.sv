module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here
logic [15:0] counter;
enum{s0,s1} ps;

always_ff @(posedge clk) begin 
    if(!rst_n) begin 
        {rdy, counter} <= {1'b1, 16'b0};
        ps <= s0;
    end
    else begin 
        case(ps) 
            s0 : begin
                if(en) begin // When caller has enabled to make a request then rdy must be desserted
                    {rdy, wren, counter} <= {1'b0, 1'b1, 16'b0};
                    ps <= s1;
                end
                else begin 
                    {rdy, wren, counter} <= {1'b1, 1'b0, 16'b0};
                    ps <= s0;
                end
            end
            s1 : begin 
                if(counter < 16'd256) begin 
                    wren <= 1'b1;
                    wrdata <= counter;
                    addr <= counter;
                    counter <= counter + 1'b1;
                    ps <= s1;
                end
                else begin 
                    {rdy, wren, counter} <= {1'b1, 1'b0, 16'b0};
                    ps <= s0;
                end
            end
        endcase
    end
end
endmodule: init