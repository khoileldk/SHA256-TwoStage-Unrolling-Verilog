module message_expand(
    input             clk,
    input             reset,
    input             data_en,    
    input      [31:0] block_in,   
    output reg        message_valid,  
    output     [31:0] debug_w,   
    output reg [31:0] w_data_0,  
    output reg [31:0] w_data_1   
);
    reg [31:0] w[15:0];   // 16 thanh ghi dem vong
    reg [5:0]  word_cnt;          // bien dem word
    reg [3:0]  load_idx;          // bien dem 16 word dau vao dau tien

    // cac ham tinh toan
    function [31:0] rotr (input [31:0] x, input integer n);
        rotr = (x >> n) | (x << (32 - n));
    endfunction

    function [31:0] shr (input [31:0] x, input integer n);
        shr = (x >> n);
    endfunction

    function [31:0] sig0(input [31:0] x);
        sig0 = rotr(x, 7) ^ rotr(x, 18) ^ shr(x, 3);
    endfunction

    function [31:0] sig1(input [31:0] x);
        sig1 = rotr(x, 17) ^ rotr(x, 19) ^ shr(x, 10);
    endfunction

    wire [3:0] idx_w = word_cnt[3:0]; 
    wire [31:0] new_w_0, new_w_1;

    assign new_w_0 = sig1(w[idx_w + 4'd14]) + 
                     w[idx_w + 4'd9] + 
                     sig0(w[idx_w + 4'd1]) + 
                     w[idx_w];

    assign new_w_1 = sig1(w[idx_w + 4'd15]) + 
                     w[idx_w + 4'd10] + 
                     sig0(w[idx_w + 4'd2]) + 
                     w[idx_w + 4'd1];
    assign debug_w = w[load_idx]; 
    localparam IDLE   = 2'b00;
    localparam LOAD   = 2'b01;
    localparam EXPAND = 2'b10; 
    localparam OUT    = 2'b11; 

    reg [1:0] current_st, next_st;

    always @(*) begin
        next_st = current_st;
        case(current_st)
            IDLE:   if(data_en)          next_st = LOAD;
            LOAD:   if(load_idx == 15)   next_st = EXPAND;
            EXPAND: if(word_cnt == 46)   next_st = OUT;
            OUT:    if(word_cnt == 62)   next_st = IDLE;
            default:                     next_st = IDLE;
        endcase
    end

    always @(posedge clk or negedge reset) begin
        if(!reset) current_st <= IDLE;
        else       current_st <= next_st;
    end

    integer i;
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i=0; i<16; i=i+1) w[i] <= 32'b0;
            load_idx      <= 0; 
            word_cnt      <= 0;
            w_data_0      <= 0; 
            w_data_1      <= 0;
            message_valid <= 0;
        end else begin
            case(current_st)
                IDLE: begin
                    load_idx      <= 0;
                    word_cnt      <= 0; 
                    message_valid <= 0;
                end

                LOAD: begin
                    w[load_idx] <= block_in;
                    load_idx    <= load_idx + 1;
                    if(load_idx == 15) message_valid <= 1'b1;
                end

                EXPAND: begin
                    w_data_0        <= w[idx_w];
                    w_data_1        <= w[idx_w + 4'd1];
                    w[idx_w]        <= new_w_0;
                    w[idx_w + 4'd1] <= new_w_1;
                    word_cnt        <= word_cnt + 2; 
                    message_valid   <= 1'b0;
                end

                OUT: begin
                    w_data_0 <= w[idx_w];
                    w_data_1 <= w[idx_w + 4'd1];
                    word_cnt <= word_cnt + 2;
                end
            endcase
        end
    end
endmodule