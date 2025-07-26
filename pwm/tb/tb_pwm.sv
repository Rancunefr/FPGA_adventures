`timescale 1ns / 1ps

module tb_pwm;

  logic clk;
  logic rst;
  logic out;
  logic run;
  logic oe;
  logic [7:0] duty_cycle;
  logic duty_valid;

  parameter int CLOCK_PERIOD = 10;

  pwm #(
      .CLK_SCALER(1)
  ) DUT (
      .clk(clk),
      .rst(rst),
      .run(run),
      .duty_cycle(duty_cycle),
      .duty_valid(duty_valid),
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
    #12;
    rst = 1;
    #30;
    rst = 0;
    #50;
    rst = 0;
    run = 0;
    duty_cycle = 42;
    duty_valid = 1;
    oe = 1;
    #20;
    duty_valid = 0;
    #100;
    run = 1;
  end

endmodule
