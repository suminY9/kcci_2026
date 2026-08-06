`timescale 1ns / 1ps

module tb_VGA_top();

    // 100MHz Pixel Clock (10ns period)
    logic        i_pixel_clk;
    logic        reset;
    logic [23:0] i_RGB;
    logic [10:0] i_x_pixel;
    logic [10:0] i_y_pixel;
    logic [7:0]  i_pixel_addr;
    logic        i_capture;

    logic [31:0] o_pixel_data;
    logic        o_vga_done;

    // 672 x 168 = 112896 elements image memory array
    logic [23:0] image_mem [0:112895];

    // DUT Instance
    VGA_top U_DUT (
        .i_pixel_clk (i_pixel_clk),
        .reset       (reset),
        .i_RGB       (i_RGB),
        .i_x_pixel   (i_x_pixel),
        .i_y_pixel   (i_y_pixel),
        .i_pixel_addr(i_pixel_addr),
        .o_pixel_data(o_pixel_data),
        .i_capture   (i_capture),
        .o_vga_done  (o_vga_done)
    );

    // Clock Generation
    initial begin
        i_pixel_clk = 1'b0;
        forever #5 i_pixel_clk = ~i_pixel_clk;
    end

    // Test Stimulus
    integer x, y;
    integer img_idx;

    initial begin
        // Initialize memory file
        $readmemh("testImage.mem", image_mem);

        // Reset & Signals Initial Condition
        reset        = 1'b1;
        i_capture    = 1'b0;
        i_RGB        = 24'd0;
        i_x_pixel    = 11'd0;
        i_y_pixel    = 11'd0;
        i_pixel_addr = 8'd0;

        #20;
        reset = 1'b1;
        #30;
        reset = 1'b0;
        #20;

        // Start Capture
        i_capture = 1'b1;
        img_idx   = 0;

        // Frame Crop Range Generation (Y: 456 ~ 623 / X: 624 ~ 1295)
        for (y = 456; y < 624; y = y + 1) begin
            for (x = 624; x < 1296; x = x + 1) begin
                @(posedge i_pixel_clk);
                i_y_pixel = y[10:0];
                i_x_pixel = x[10:0];
                
                if (img_idx < 112896) begin
                    i_RGB = image_mem[img_idx];
                    img_idx = img_idx + 1;
                end else begin
                    i_RGB = 24'd0;
                end
            end
        end

        // Clear Pixel Bus
        @(posedge i_pixel_clk);
        i_x_pixel = 11'd0;
        i_y_pixel = 11'd0;
        i_RGB     = 24'd0;

        // Wait until Frame Processing Completed
        wait(o_vga_done == 1'b1);
        $display("[TB] VGA Frame Write Completed!");

        // Read Memory Test Logic
        #100;
        $display("[TB] Reading Pixel BufferRAM Data...");
        for (integer r = 0; r < 128; r = r + 1) begin
            @(posedge i_pixel_clk);
            i_pixel_addr = r[7:0];
            #1; // Read Latency delay for display
            $display("Addr 0x%02h (%3d) : Data = 0x%08h", r[7:0], r, o_pixel_data);
        end

        #200;
        $finish;
    end

endmodule