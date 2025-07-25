`timescale 1ns / 1ps

module tb_pwm;

  logic clk;
  logic rst;
  logic out;
  logic start;
  logic oe;
  logic [7:0] duty_cycle;

  parameter int CLOCK_PERIOD = 10;

  pwm #(
      .CLK_SCALER(5)
  ) DUT (
      .clk(clk),
      .rst(rst),
      .start(start),
      .duty_cycle(duty_cycle),
      .oe(oe),
      .out(out)
  );

  initial begin
    clk = 0;
    repeat (10000) begin
      #(CLOCK_PERIOD / 2) clk = ~clk;
    end
  end

  initial begin
    rst = 0;
    start = 0;
    duty_cycle = 50;
    oe = 0;
    #10 rst = 1;
    #20;
    rst = 0;
    #20;
    start = 1;
    #20;
    oe = 1;
    #20000;
    duty_cycle = 10;
    #20000;
    oe = 0;
  end

endmodule
