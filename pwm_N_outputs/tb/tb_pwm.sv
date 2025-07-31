`timescale 1ns / 1ps

module tb_pwm;

  logic clk;
  logic rst;
  logic [254:0] toto;
  logic run;
  logic oe;
  logic [7:0] duty_cycle;
  logic [$clog2(255)-1:0] duty_output;
  logic duty_valid;

  parameter int CLOCK_PERIOD = 10;

  pwm #(
      .CLK_SCALER(100),
      .RESET_DUTY_CYCLE(20),
      .MIN_DUTY(20),
      .MAX_DUTY(80),
      .NB_OUTPUTS(255)
  ) DUT (
      .clk(clk),
      .rst(rst),
      .run(run),
      .duty_output(duty_output),
      .duty_cycle(duty_cycle),
      .duty_valid(duty_valid),
      .oe(oe),
      .out(toto)
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
    duty_output = 0;
    duty_cycle = 0;
    duty_valid = 0;
    #10;
    rst = 1;
    #30;
    rst = 0;
    #100;
    duty_output = 0;
    duty_cycle  = 60;
    duty_valid  = 1;
    #10;
    duty_valid = 0;
    #30;
    duty_output = 3;
    duty_cycle  = 40;
    duty_valid  = 1;
    #10;
    duty_valid = 0;
  end

endmodule
