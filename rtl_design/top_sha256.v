module top_sha256 (
    input  wire         clk,
    input  wire         reset,     
    input  wire         data_en,
    input  wire [31:0]  block_in,
    output wire [31:0]  debug_w,     
    output wire [255:0] hash_result, 
    output wire         hash_done        
);
    wire        valid_wire;
    wire [31:0] w_bus_0;
    wire [31:0] w_bus_1;
message_expand u_message (
        .clk(clk),
        .reset(reset),
        .data_en(data_en),
        .block_in(block_in),
        .message_valid(valid_wire),  
        .debug_w(debug_w),
        .w_data_0(w_bus_0),
        .w_data_1(w_bus_1) 
    );
compression u_compression (       
        .clk(clk),
        .reset(reset),
        .message_valid(valid_wire),   
        .w_data_0(w_bus_0),
        .w_data_1(w_bus_1),
        .hash_result(hash_result),
        .hash_done(hash_done)
    );
endmodule