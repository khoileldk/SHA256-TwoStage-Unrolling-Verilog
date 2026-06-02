`timescale 1ns / 1ps

module tb_top_sha256;
    localparam CLK_PERIOD = 20;
    
    reg         clk;
    reg         reset;
    reg         data_en;
    reg  [31:0] block_in;
    wire        hash_done;
    wire [255:0] hash_result; 
    wire [31:0] debug_w;     
    
    reg  [511:0] test_block_512;
    reg  [255:0] expected_hash;
    
    integer test_count; 
    integer pass_count;

    top_sha256 dut (
        .clk(clk),
        .reset(reset),
        .data_en(data_en),
        .block_in(block_in),
        .debug_w(debug_w),
        .hash_result(hash_result),
        .hash_done(hash_done)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    task sys_reset;
    begin
        reset = 1'b0; 
        data_en = 1'b0;
        block_in = 32'b0;
        #(CLK_PERIOD * 2); 
        reset = 1'b1; 
        #(CLK_PERIOD);
    end
    endtask
    
    task inject_512b_block;
        input [511:0] block;      
        input [255:0] expected;
        input is_final_block;
        input [1023:0] test_name;
        
        integer i;
        begin
            @(negedge clk);
            data_en = 1'b1;
            @(negedge clk);
            
            // Nap 16 tu 32 bit
            for (i = 0; i < 16; i = i + 1) begin    
                block_in = block[511 - (i * 32) -: 32];
                @(posedge clk);
            end
            
            @(posedge clk);
            data_en = 1'b0;
            block_in = 32'b0;

            // Cho co hoan tat
            while (!hash_done) begin
                @(posedge clk);
            end

            // So sanh ket qua
            if (is_final_block) begin
                test_count = test_count + 1;
                if (hash_result === expected) begin
                    pass_count = pass_count + 1;
                    $display("Test %0d Thanh Cong: %0s", test_count, test_name);
                end else begin
                    $display("Test %0d That Bai: %0s", test_count, test_name);
                    $display("Mong doi: %h", expected);
                    $display("Thuc te:   %h", hash_result);
                end
            end
            @(posedge clk);
        end
         endtask

          initial begin
           test_count = 0;
            pass_count = 0;
        
        $display("================ CHAY MO PHONG ================");
        
        // chuoi rong ""
        sys_reset();
        expected_hash = 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855; 
        test_block_512 = {32'h80000000, {14{32'h0}}, 32'h00000000};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Emty String");

        // a
        sys_reset();
        expected_hash = 256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb; 
        test_block_512 = {32'h61800000, {14{32'h0}}, 32'h00000008};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "a");

        //UIT
        sys_reset();
        expected_hash = 256'h3d97c75313dda33e8c25ab2395bc6aef19b4c43d7d1a0dc881f20d5598b93d5c; 
        test_block_512 = {32'h55495480, {14{32'h0}}, 32'h00000018};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "UIT");

        // 55 chu A
        sys_reset();
        expected_hash = 256'h8963cc0afd622cc7574ac2011f93a3059b3d65548a77542a1559e3d202e6ab00; 
        test_block_512 = {{13{32'h41414141}}, 32'h41414180, 32'h00000000, 32'h000001b8};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "55 chu A");

        //56 chu B
        sys_reset();
        expected_hash = 256'h821c30ffb748ac6d776ad4972a6cbc7ca32e6aaf63b68808e7fe92321dfbb6b8; 
        test_block_512 = {{14{32'h42424242}}, 32'h80000000, 32'h00000000};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "56 chu B");
        test_block_512 = {{15{32'h0}}, 32'h000001c0};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "56 chu B");

        // Khoi
        sys_reset();
        expected_hash = 256'hf503c345fac9f94a562302625e7082390b7796b57f5e1559ab2dabfa4a3bf13d; 
        test_block_512 = {32'h4b686f69, 32'h80000000, {13{32'h0}}, 32'h00000020};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Khoi");

        // Do an 1
        sys_reset();
        expected_hash = 256'h1763bdc10a961a4fed6b13a39212cdc2e35031ec66715a084a470e0f5531d784; 
        test_block_512 = {32'h446f2061, 32'h6e203180, {13{32'h0}}, 32'h00000038};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Do an 1");

        // IC Design"
        sys_reset();
        expected_hash = 256'h1690091835cc268e15fa4d05d6545f83a749814373e582fda067c388f1e9e129; 
        test_block_512 = {32'h49432044, 32'h65736967, 32'h6e800000, {12{32'h0}}, 32'h00000048};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "IC_Design");

        // FPGA
        sys_reset();
        expected_hash = 256'hdcbfca4bced0a7f278db6959ad82411b2d20a9ea31e25f1d389e41ce23a89050; 
        test_block_512 = {32'h46504741, 32'h80000000, {13{32'h0}}, 32'h00000020};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "FPGA");

        // Verilog
        sys_reset();
        expected_hash = 256'h25d9678d5751122ddd45aa87a465cab682e00ffa6a6ddf821fbd7a43fe8d200c; 
        test_block_512 = {32'h56657269, 32'h6c6f6780, {13{32'h0}}, 32'h00000038};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Verilog");

        // Quartus
        sys_reset();
        expected_hash = 256'hc96c90f8413c2d760da28fd8790f20700fe34fcbed241af74090fe7ee302f7b5; 
        test_block_512 = {32'h51756172, 32'h74757380, {13{32'h0}}, 32'h00000038};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Quartus");

        // ModelSim
        sys_reset();
        expected_hash = 256'h5a9d3c17e96ab64494ae2ef23467becb29d083406103b40273ce64fb349585af; 
        test_block_512 = {32'h4d6f6465, 32'h6c53696d, 32'h80000000, {12{32'h0}}, 32'h00000040};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "ModelSim");

        //  CE UIT
        sys_reset();
        expected_hash = 256'ha45ecafd0e1bbb25e393858f85c3594d8beb4ace67aca1e84c7864b122599d65; 
        test_block_512 = {32'h43452055, 32'h49548000, {13{32'h0}}, 32'h00000030};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "CE UIT");

        // KTM
        sys_reset();
        expected_hash = 256'h78cb76057c9f77b071ee711db2f142330345cc86d790440296749043488df0b8; 
        test_block_512 = {32'h4b544d80, {14{32'h0}}, 32'h00000018};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "KTM");

        // 4 chu A
        sys_reset();
        expected_hash = 256'h63c1dd951ffedf6f7fd968ad4efa39b8ed584f162f46e715114ee184f8de9201; 
        test_block_512 = {32'h41414141, 32'h80000000, {13{32'h0}}, 32'h00000020};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "4 chu A");

        // 8 chu A
        sys_reset();
        expected_hash = 256'hc34ab6abb7b2bb595bc25c3b388c872fd1d575819a8f55cc689510285e212385; 
        test_block_512 = {{2{32'h41414141}}, 32'h80000000, {12{32'h0}}, 32'h00000040};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "8 chu A");

        // 12 chu A
        sys_reset();
        expected_hash = 256'h0592cedeabbf836d8d1c7456417c7653ac208f71e904d3d0ab37faf711021aff; 
        test_block_512 = {{3{32'h41414141}}, 32'h80000000, {11{32'h0}}, 32'h00000060};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "12 chu A");
        // Hanta virus
        sys_reset();
        expected_hash = 256'h4a1bdaa240477c4d96f27b555ba5faa053d160b16c6c9c9a47e748d2f839af2b; 
        test_block_512 = {32'h48616e74, 32'h61207669, 32'h72757380, {12{32'h0}}, 32'h00000058};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Hanta virus");
        //Cybersecurity Zero Trust
        sys_reset();
        expected_hash = 256'hea3e2b8bbb1d048945957ab69d0a3d07629ddc568ac54c919fa3fab4db2330ee;
        test_block_512 = {32'h43796265, 32'h72736563, 32'h75726974, 32'h79205a65, 32'h726f2054, 32'h72757374, 32'h80000000, {8{32'h0}}, 32'h000000c0};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Cybersecurity Zero Trust");
        //Nam quoc son ha Nam de cu. Tiet nhien dinh phan tai thien thu.
        sys_reset();
        expected_hash = 256'h1328b140f1f5752fb9cab8dfbec298888298bd1ded6f02805493f0d85d51325c; 
        test_block_512 = {32'h4e616d20, 32'h71756f63, 32'h20736f6e, 32'h20686120, 32'h4e616d20, 32'h64652063, 32'h752e2054, 32'h69657420, 32'h6e686965, 32'h6e206469, 32'h6e682070, 32'h68616e20, 32'h74616920, 32'h74686965, 32'h6e207468, 32'h752e8000};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Nam quoc son ha Nam de cu. Tiet nhien dinh phan tai thien thu.");
        test_block_512 = {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h000001f0}; // ?ã s?a 0x1e8 thành 0x1f0
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Nam quoc son ha Nam de cu. Tiet nhien dinh phan tai thien thu.");
        
        //Buoc toi Deo Ngang bong xe ta. Co cay chen da la chen hoa.
        sys_reset();
        expected_hash = 256'hee73feaef7378c777e36cfc68801c7ac2bc98b4788a1ba749bd0a334e616671c; 
        test_block_512 = {32'h42756f63, 32'h20746f69, 32'h2044656f, 32'h204e6761, 32'h6e672062, 32'h6f6e6720, 32'h78652074, 32'h612e2043, 32'h6f206361, 32'h79206368, 32'h656e2064, 32'h61206c61, 32'h20636865, 32'h6e20686f, 32'h612e8000, 32'h00000000};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Buoc toi Deo Ngang bong xe ta. Co cay chen da la chen hoa.");
        test_block_512 = {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h000001d0};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Buoc toi Deo Ngang bong xe ta. Co cay chen da la chen hoa.");
        
        // Do an duoc thuc hien duoi su huong dan cua giang vien Ngo Hieu Truong
        sys_reset();
        expected_hash = 256'hbcfed59a5d3224c15dadad5dbff681c015e0db971c50e10df9647b7543818265; 
        test_block_512 = {32'h446f2061, 32'h6e206475, 32'h6f632074, 32'h68756320, 32'h6869656e, 32'h2064756f, 32'h69207375, 32'h2068756f, 32'h6e672064, 32'h616e2063, 32'h75612067, 32'h69616e67, 32'h20766965, 32'h6e204e67, 32'h6f204869, 32'h65752054};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Do an duoc thuc hien duoi su huong dan cua giang vien Ngo Hieu Truong");
        test_block_512 = {32'h72756f6e, 32'h67800000, {13{32'h0}}, 32'h00000228}; 
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Do an duoc thuc hien duoi su huong dan cua giang vien Ngo Hieu Truong");
        //Bao cao do an HDL vao ngay 29 thang 5
        sys_reset();
        expected_hash = 256'hb67520c7ea7a6f1f75d5d2e5ccaa45d3e8b44e6fd901a31d83d305f280b64764; 
        test_block_512 = {32'h42616f20, 32'h63616f20, 32'h646f2061, 32'h6e204844, 32'h4c207661, 32'h6f206e67, 32'h61792032, 32'h39207468, 32'h616e6720, 32'h35800000, {5{32'h0}}, 32'h00000128};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Bao cao do an HDL vao ngay 29 thang 5");
        //  Báo cáo ?? án HDL 
        sys_reset();
        expected_hash = 256'hf5fab00ff5a4f62024472864d6c79a9f62c85db6ed2d9657d298a12317bde0e3; 
        test_block_512 = {32'h42c3a16f, 32'h2063c3a1, 32'h6f20c491, 32'he1bb9320, 32'hc3a16e20, 32'h48444c80, {9{32'h0}}, 32'h000000b8};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Báo cáo ?? án HDL ");
        //  ??i h?c CNTT 
        sys_reset();
        expected_hash = 256'h2346dd071e2edfd3277da5415d76d59612219932254957f3e21ea5a7b281aca2; 
        test_block_512 = {32'hc490e1ba, 32'ha1692068, 32'he1bb8d63, 32'h20434e54, 32'h54800000, {10{32'h0}}, 32'h00000088};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "??i h?c CNTT ");
        // Sinh viên Lê ??ng Khôi 
        sys_reset();
        expected_hash = 256'h96a526cd716626d303958e1e2d668ab9e2036f044f154dc97738227a9fd6a1c8; 
        test_block_512 = {32'h53696e68, 32'h207669c3, 32'haa6e204c, 32'hc3aa20c4, 32'h90c4836e, 32'h67204b68, 32'hc3b46980, {8{32'h0}}, 32'h000000d8};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Sinh viên Lê ??ng Khôi");
        // Sinh viên Võ Nguy?n Anh Khôi 
        sys_reset();
        expected_hash = 256'h9ee035a7f54f12419a54c6b41a8635f93af54e7e635d46137489dc58b998f3e5; 
        test_block_512 = {32'h53696e68, 32'h207669c3, 32'haa6e2056, 32'hc3b5204e, 32'h677579e1, 32'hbb856e20, 32'h416e6820, 32'h4b68c3b4, 32'h69800000, {6{32'h0}}, 32'h00000108};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Sinh viên Võ Nguy?n Anh Khôi");
        // Cong nghe blockchain va tien dien tu Bitcoin dua vao thuat toan bum SHA-256 de dam bao tinh toan ven cua du lieu. Viec thu nghiem thuat toan nay tren FPGA giup chung minh tinh hieu qua cua kien truc phan cung.
        sys_reset();
        expected_hash = 256'hf28d79d08c503e343538ad9ba2f603f3f0fd9ad02d27fa5ed2ec28e18d8d6d7d; 
        test_block_512 = {32'h436f6e67, 32'h206e6768, 32'h6520626c, 32'h6f636b63, 32'h6861696e, 32'h20766120, 32'h7469656e, 32'h20646965, 32'h6e207475, 32'h20426974, 32'h636f696e, 32'h20647561, 32'h2076616f, 32'h20746875, 32'h61742074, 32'h6f616e20};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Cong nghe blockchain va tien dien tu Bitcoin dua vao thuat toan bum SHA-256 de dam bao tinh toan ven cua du lieu. Viec thu nghiem thuat toan nay tren FPGA giup chung minh tinh hieu qua cua kien truc phan cung.");
        
        test_block_512 = {32'h62756d20, 32'h5348412d, 32'h32353620, 32'h64652064, 32'h616d2062, 32'h616f2074, 32'h696e6820, 32'h746f616e, 32'h2076656e, 32'h20637561, 32'h20647520, 32'h6c696575, 32'h2e205669, 32'h65632074, 32'h6875206e, 32'h67686965};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Cong nghe blockchain va tien dien tu Bitcoin dua vao thuat toan bum SHA-256 de dam bao tinh toan ven cua du lieu. Viec thu nghiem thuat toan nay tren FPGA giup chung minh tinh hieu qua cua kien truc phan cung.");
        
        test_block_512 = {32'h6d207468, 32'h75617420, 32'h746f616e, 32'h206e6179, 32'h20747265, 32'h6e204650, 32'h47412067, 32'h69757020, 32'h6368756e, 32'h67206d69, 32'h6e682074, 32'h696e6820, 32'h68696575, 32'h20717561, 32'h20637561, 32'h206b6965};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Cong nghe blockchain va tien dien tu Bitcoin dua vao thuat toan bum SHA-256 de dam bao tinh toan ven cua du lieu. Viec thu nghiem thuat toan nay tren FPGA giup chung minh tinh hieu qua cua kien truc phan cung.");
        
        test_block_512 = {32'h6e207472, 32'h75632070, 32'h68616e20, 32'h63756e67, 32'h2e800000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000688};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Tech_Blockchain_blk4");
        // Viet Nam la mot quoc gia nam o ban dao Dong Duong, thuoc khu vuc Dong Nam A. Voi duong bo bien dai hon 3260 km, Viet Nam co tiem nang lon ve phat trien kinh te bien va du lich. Thu do cua Viet Nam la Ha Noi, thanh pho lon nhat la Ho Chi Minh.
        sys_reset();
        expected_hash = 256'h2e42af125599c90d922a5d2bf9be09c892a5896035f1288a40af98e3630ef6f9;         
        test_block_512 = {32'h56696574, 32'h204e616d, 32'h206c6120, 32'h6d6f7420, 32'h71756f63, 32'h20676961, 32'h206e616d, 32'h206f2062, 32'h616e2064, 32'h616f2044, 32'h6f6e6720, 32'h44756f6e, 32'h672c2074, 32'h68756f63, 32'h206b6875, 32'h20767563};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Viet Nam la mot quoc gia...");
        
        test_block_512 = {32'h20446f6e, 32'h67204e61, 32'h6d20412e, 32'h20566f69, 32'h2064756f, 32'h6e672062, 32'h6f206269, 32'h656e2064, 32'h61692068, 32'h6f6e2033, 32'h32363020, 32'h6b6d2c20, 32'h56696574, 32'h204e616d, 32'h20636f20, 32'h7469656d};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Viet Nam la mot quoc gia...");
        
        test_block_512 = {32'h206e616e, 32'h67206c6f, 32'h6e207665, 32'h20706861, 32'h74207472, 32'h69656e20, 32'h6b696e68, 32'h20746520, 32'h6269656e, 32'h20766120, 32'h6475206c, 32'h6963682e, 32'h20546875, 32'h20646f20, 32'h63756120, 32'h56696574};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Viet Nam la mot quoc gia...");
        
        test_block_512 = {32'h204e616d, 32'h206c6120, 32'h4861204e, 32'h6f692c20, 32'h7468616e, 32'h68207068, 32'h6f206c6f, 32'h6e206e68, 32'h6174206c, 32'h6120486f, 32'h20436869, 32'h204d696e, 32'h682e8000, 32'h00000000, 32'h00000000, 32'h00000790};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Viet Nam la mot quoc gia...");
        //Troi hom nay trong xanh va co ve rat mat me. Toi ngoi trong quan ca phe quen thuoc tren con duong nho vang lang. Tieng nhac du duong vang len tu chiec loa cu, hoa cung tieng chim hot liu lo ngoai cua so. Mot ngay cuoi tuan that binh yen biet bao, khien tam hon tro nen nhe nhang hon.
        sys_reset();
        expected_hash = 256'hec5aa86b0a22084cfe1cdab7fbadef4a7e7534bdf7323b6ccdf08520c0d7f1d5; // TODO: Tra mã hash cho chu?i trên
        test_block_512 = {32'h54726f69, 32'h20686f6d, 32'h206e6179, 32'h2074726f, 32'h6e672078, 32'h616e6820, 32'h76612063, 32'h6f207665, 32'h20726174, 32'h206d6174, 32'h206d652e, 32'h20546f69, 32'h206e676f, 32'h69207472, 32'h6f6e6720, 32'h7175616e};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Troi hom nay...");
        
        test_block_512 = {32'h20636120, 32'h70686520, 32'h7175656e, 32'h20746875, 32'h6f632074, 32'h72656e20, 32'h636f6e20, 32'h64756f6e, 32'h67206e68, 32'h6f207661, 32'h6e67206c, 32'h616e672e, 32'h20546965, 32'h6e67206e, 32'h68616320, 32'h64752064};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Troi hom nay...");
        
        test_block_512 = {32'h756f6e67, 32'h2076616e, 32'h67206c65, 32'h6e207475, 32'h20636869, 32'h6563206c, 32'h6f612063, 32'h752c2068, 32'h6f612063, 32'h756e6720, 32'h7469656e, 32'h67206368, 32'h696d2068, 32'h6f74206c, 32'h6975206c, 32'h6f206e67};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Troi hom nay...");
        
        test_block_512 = {32'h6f616920, 32'h63756120, 32'h736f2e20, 32'h4d6f7420, 32'h6e676179, 32'h2063756f, 32'h69207475, 32'h616e2074, 32'h68617420, 32'h62696e68, 32'h2079656e, 32'h20626965, 32'h74206261, 32'h6f2c206b, 32'h6869656e, 32'h2074616d};
        inject_512b_block(test_block_512, expected_hash, 1'b0, "Troi hom nay...");
        
        test_block_512 = {32'h20686f6e, 32'h2074726f, 32'h206e656e, 32'h206e6865, 32'h206e6861, 32'h6e672068, 32'h6f6e2e80, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h000008d8};
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Troi hom nay...");
        sys_reset();
        
        // ?? tr?ng (ho?c gán 0) ?? ch?y mô ph?ng l?y k?t qu?
        expected_hash = 256'h021eb99ac75d746bceabb73d16dd9ee729a6a8191500c4680c639bfcad239c50; 
        
        // C?u trúc block 512-bit cho chu?i "Thiet ke he thong so"
        test_block_512 = {
            32'h54686965, // W0: "Thie"
            32'h74206B65, // W1: "t ke"
            32'h20686520, // W2: " he "
            32'h74686F6E, // W3: "thon"
            32'h6720736F, // W4: "g so"
            32'h80000000, // W5: Padding bit 1 (0x80 chèn ngay sau d? li?u)
            {9{32'h0}},   // W6 - W14: 9 t? ch?a toàn s? 0 (Zero padding)
            32'h000000A0  // W15: Chi?u dài chu?i = 20 byte = 160 bit (Hexa là 0xA0)
        };
        
        inject_512b_block(test_block_512, expected_hash, 1'b1, "Thiet ke he thong so");
        $stop;
    end
endmodule
