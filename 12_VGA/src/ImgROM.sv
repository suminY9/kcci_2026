`timescale 1ns / 1ps

module ImgROM(
    input  logic [$clog2(320*240)-1:0] addr,
    output logic [15:0]                data
    );

    logic [15:0] mem[0:320*240-1];

    initial begin
        $readmemh("Lenna_320x240.mem", mem); // Lenna.mem이라는 파일을 16진수로 읽어서 mem이라는 메모리 공간에 넣음.
    end

    assign data = mem[addr];
endmodule
