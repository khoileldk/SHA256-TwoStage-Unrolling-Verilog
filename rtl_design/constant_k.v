module constant_k (
    input      [4:0] count,     
    output reg [31:0] k_val_0,       
    output reg [31:0] k_val_1 
);
    always @(*) begin
        case (count)
            0:  {k_val_0, k_val_1} = {32'h428a2f98, 32'h71374491}; // 64 hang so K
            1:  {k_val_0, k_val_1} = {32'hb5c0fbcf, 32'he9b5dba5};
            2:  {k_val_0, k_val_1} = {32'h3956c25b, 32'h59f111f1};
            3:  {k_val_0, k_val_1} = {32'h923f82a4, 32'hab1c5ed5}; 
            4:  {k_val_0, k_val_1} = {32'hd807aa98, 32'h12835b01};
            5:  {k_val_0, k_val_1} = {32'h243185be, 32'h550c7dc3}; 
            6:  {k_val_0, k_val_1} = {32'h72be5d74, 32'h80deb1fe}; 
            7:  {k_val_0, k_val_1} = {32'h9bdc06a7, 32'hc19bf174};
            8:  {k_val_0, k_val_1} = {32'he49b69c1, 32'hefbe4786}; 
            9:  {k_val_0, k_val_1} = {32'h0fc19dc6, 32'h240ca1cc}; 
            10: {k_val_0, k_val_1} = {32'h2de92c6f, 32'h4a7484aa};
            11: {k_val_0, k_val_1} = {32'h5cb0a9dc, 32'h76f988da}; 
            12: {k_val_0, k_val_1} = {32'h983e5152, 32'ha831c66d}; 
            13: {k_val_0, k_val_1} = {32'hb00327c8, 32'hbf597fc7};
            14: {k_val_0, k_val_1} = {32'hc6e00bf3, 32'hd5a79147};
            15: {k_val_0, k_val_1} = {32'h06ca6351, 32'h14292967};
            16: {k_val_0, k_val_1} = {32'h27b70a85, 32'h2e1b2138}; 
            17: {k_val_0, k_val_1} = {32'h4d2c6dfc, 32'h53380d13}; 
            18: {k_val_0, k_val_1} = {32'h650a7354, 32'h766a0abb};
            19: {k_val_0, k_val_1} = {32'h81c2c92e, 32'h92722c85}; 
            20: {k_val_0, k_val_1} = {32'ha2bfe8a1, 32'ha81a664b}; 
            21: {k_val_0, k_val_1} = {32'hc24b8b70, 32'hc76c51a3};
            22: {k_val_0, k_val_1} = {32'hd192e819, 32'hd6990624}; 
            23: {k_val_0, k_val_1} = {32'hf40e3585, 32'h106aa070}; 
            24: {k_val_0, k_val_1} = {32'h19a4c116, 32'h1e376c08};
            25: {k_val_0, k_val_1} = {32'h2748774c, 32'h34b0bcb5}; 
            26: {k_val_0, k_val_1} = {32'h391c0cb3, 32'h4ed8aa4a}; 
            27: {k_val_0, k_val_1} = {32'h5b9cca4f, 32'h682e6ff3};
            28: {k_val_0, k_val_1} = {32'h748f82ee, 32'h78a5636f}; 
            29: {k_val_0, k_val_1} = {32'h84c87814, 32'h8cc70208}; 
            30: {k_val_0, k_val_1} = {32'h90befffa, 32'ha4506ceb};
            31: {k_val_0, k_val_1} = {32'hbef9a3f7, 32'hc67178f2}; 
            default: {k_val_0, k_val_1} = 64'b0;
        endcase
    end
endmodule
