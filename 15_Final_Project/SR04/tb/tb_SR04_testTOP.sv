module tb_SR04_testTOP();
    logic clk;
    logic reset;
    logic echo;
    logic trigger;
    logic pwm;
    logic led;

    SR04_testTOP dut(
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .trigger(trigger),
        .pwm(pwm),
        .led(led)
    );


    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // initial reset
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
    end
endmodule