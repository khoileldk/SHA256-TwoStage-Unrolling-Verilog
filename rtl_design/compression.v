module compression(
    input              clk,
    input              reset,
    input              message_valid,   
    input      [31:0]  w_data_0,
    input      [31:0]  w_data_1,
    output     [255:0] hash_result, 
    output reg         hash_done    
);
    // Thanh ghi lam viec
    reg [31:0] a, b, c, d, e, f, g, h;
    // Thanh ghi tich luy (IV)
    reg [31:0] hash_0, hash_1, hash_2, hash_3, hash_4, hash_5, hash_6, hash_7;
    
    reg [4:0]  count;
    wire [31:0] k_val_0, k_val_1;

    constant_k k_rom_inst (
        .count(count), 
        .k_val_0(k_val_0), 
        .k_val_1(k_val_1)
    );

    // Ham Logic 
    function [31:0] ch(input [31:0] x, y, z);
        ch = (x & y) ^ (~x & z);
    endfunction

    function [31:0] maj(input [31:0] x, y, z);
        maj = (x & y) ^ (x & z) ^ (y & z);
    endfunction

    function [31:0] rotr(input [31:0] x, input [4:0] n);
        rotr = (x >> n) | (x << (32 - n));
    endfunction

    function [31:0] sig0(input [31:0] x);
        sig0 = rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
    endfunction

    function [31:0] sig1(input [31:0] x);
        sig1 = rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
    endfunction

    // round t
    wire [31:0] s1_e   = sig1(e);
    wire [31:0] ch_efg = ch(e, f, g);
    wire [31:0] kw0 = k_val_0 + w_data_0;
    wire [31:0] t1  = (h + s1_e) + (ch_efg + kw0);

    wire [31:0] s0_a   = sig0(a);
    wire [31:0] maj_abc= maj(a, b, c);
    wire [31:0] t2  = s0_a + maj_abc;

    wire [31:0] e_mid  = d + t1;
    wire [31:0] a_mid  = t1 + t2;

    // round t+1
    wire [31:0] s1_e_mid = sig1(e_mid);
    wire [31:0] ch_mid   = ch(e_mid, e, f); 
    wire [31:0] kw1 = k_val_1 + w_data_1;
    
    wire [31:0] t1_next= (g + s1_e_mid) + (ch_mid + kw1);
    
    wire [31:0] s0_a_mid = sig0(a_mid);
    wire [31:0] maj_mid  = maj(a_mid, a, b);
    wire [31:0] t2_next= s0_a_mid + maj_mid;

    wire [31:0] a_next    = t1_next + t2_next;
    wire [31:0] e_next    = c + t1_next; 
    
    assign hash_result = {hash_0, hash_1, hash_2, hash_3, hash_4, hash_5, hash_6, hash_7};

    // IV Constants
    localparam INIT_H0 = 32'h6a09e667, INIT_H1 = 32'hbb67ae85, INIT_H2 = 32'h3c6ef372, INIT_H3 = 32'ha54ff53a;
    localparam INIT_H4 = 32'h510e527f, INIT_H5 = 32'h9b05688c, INIT_H6 = 32'h1f83d9ab, INIT_H7 = 32'h5be0cd19;

    // FSM States
    localparam IDLE    = 2'b00;
    localparam HASHING = 2'b10;
    localparam UPDATE  = 2'b11;

    reg [1:0] current_st, next_st;

    always @(*) begin 
        next_st = current_st;
        case(current_st)
            IDLE:    if(message_valid)  next_st = HASHING;
            HASHING: if(count == 31)    next_st = UPDATE;
            UPDATE:                     next_st = IDLE;                                    
            default:                    next_st = IDLE;
        endcase 
    end

    always @(posedge clk or negedge reset) begin 
        if(!reset) current_st <= IDLE;
        else       current_st <= next_st;
    end
    
    always @(posedge clk or negedge reset) begin 
        if(!reset) begin
            {a, b, c, d, e, f, g, h} <= 256'b0;
            hash_done <= 1'b0;
            hash_0 <= INIT_H0; 
            hash_1 <= INIT_H1; 
            hash_2 <= INIT_H2; 
            hash_3 <= INIT_H3;
            hash_4 <= INIT_H4; 
            hash_5 <= INIT_H5; 
            hash_6 <= INIT_H6; 
            hash_7 <= INIT_H7;
            count <= 0;
        end else case(current_st)
            IDLE: begin 
                hash_done <= 1'b0;
                count <= 0;
                if(message_valid) begin
                    a <= hash_0; 
                    b <= hash_1; 
                    c <= hash_2; 
                    d <= hash_3;
                    e <= hash_4; 
                    f <= hash_5; 
                    g <= hash_6; 
                    h <= hash_7;
                end
            end 
            
            HASHING: begin  
                // Dich thanh ghi nhay 2 bac (Jump Shifting)
                h <= f;
                g <= e;       
                f <= e_mid;   
                e <= e_next;  
                d <= b;       
                c <= a;       
                b <= a_mid;
                a <= a_next;  
                count <= count + 1;
            end 
            
            UPDATE: begin
                hash_done <= 1'b1;
                // Cong don Modulo 2^32
                hash_0 <= a + hash_0;
                hash_1 <= b + hash_1; 
                hash_2 <= c + hash_2;
                hash_3 <= d + hash_3;
                hash_4 <= e + hash_4;
                hash_5 <= f + hash_5; 
                hash_6 <= g + hash_6;
                hash_7 <= h + hash_7;
            end
        endcase 
    end
endmodule