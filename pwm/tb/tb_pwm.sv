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
      .CLK_SCALER(100),
      .RESET_DUTY_CYCLE(20),
      .MIN_DUTY(20),
      .MAX_DUTY(80)
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
    oe = 1;
    run = 1;
    duty_cycle = 0;
    duty_valid = 0;
    #10;
    rst = 1;
    #30;
    rst = 0;
    #100;
    duty_cycle = 99;
    duty_valid = 1;
    #10;


  end

endmodule
