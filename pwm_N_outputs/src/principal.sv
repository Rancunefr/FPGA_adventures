`timescale 1ns / 1ps

module principal (
    input logic clk,
    input logic rst,
    input logic sw_run,
    input logic valid,
    input logic sw_oe,
    input logic [7:0] sw,
    output logic [15:0] led
);

  logic [$clog2(16)-1:0] output_select = 0;

  pwm #(
      .CLK_SCALER(100000),
      .RESET_OUTPUT_STATE(1'b0),
      .NB_OUTPUTS(16)
  ) mon_pwm (
      .clk(clk),
      .rst(rst),
      .out(led),
      .oe(sw_oe),
      .duty_cycle(sw),
      .duty_valid(valid),
      .duty_output(output_select),
      .run(sw_run)
  );

endmodule
