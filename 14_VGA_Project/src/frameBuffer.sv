module frameBuffer_CAM0(
    // wirte side
    input  logic wclk,
    input  logic we,
    input  logic [$clog2(320*240)-1:0] wAddr, //QVGA size
    input  logic [15:0] wData,
    // read side
    input  logic                       rclk,
    input  logic [$clog2(320*240)-1:0] rAddr,
    output logic [15:0] rData
);

    logic [15:0] mem[0:(320*240)-1];

    // write side
    always_ff @(posedge wclk) begin
       if(we) mem[wAddr] <= wData; 
    end

    // read side
    always_ff @(posedge rclk) begin
        rData <= mem[rAddr];
    end
    // assign rData = mem[rAddr];

endmodule


module frameBuffer_CAM1(
    // wirte side - cam
    input  logic wclk,
    input  logic we,
    input  logic [$clog2(320*240)-1:0] wAddr, //QVGA size
    input  logic [15:0] wData,
    // read side - cam
    input  logic                       rclk,
    input  logic [$clog2(320*240)-1:0] rAddr,
    output logic [15:0] rData,
    // write side - cap
    input  logic wclk_cap,
    input  logic we_cap,
    input  logic [$clog2(80*110)-1:0] wAddr_cap,
    input  logic [11:0] wData_cap,
    // read side - uart
    input  logic rclk_cap,
    input  logic [$clog2(80*110)-1:0] rAddr_cap,
    output logic [11:0] rData_cap
);

    logic [15:0] mem[0:(320*240)-1];
    logic [11:0] captureRAM[0:(80*110)-1];

    // write side
    always_ff @(posedge wclk) begin
       if(we) mem[wAddr] <= wData; 
    end
    always_ff @(posedge wclk_cap) begin
        if(we_cap) captureRAM[wAddr_cap] <= wData_cap;
    end

    // read side
    always_ff @(posedge rclk) begin
        rData <= mem[rAddr];
    end
    always_ff @(posedge rclk_cap) begin
        rData_cap <= captureRAM[rAddr_cap];
    end

endmodule
