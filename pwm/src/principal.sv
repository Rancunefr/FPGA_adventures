`timescale 1ns / 1ps

module principal (
    input logic clk,
    input logic rst,
    input logic sw_run,
    input logic valid,
    input logic sw_oe,
    input logic [7:0] sw,
    output logic led
);

  pwm #(
      .CLK_SCALER(100000),
      .RESET_OUTPUT_STATE(1'b0)
  ) mon_pwm (
      .clk(clk),
      .rst(rst),
      .out(led),
      .oe(sw_oe),
      .duty_cycle(sw),
      .duty_valid(valid),
      .run(sw_run)
  );

  always_ff @(posedge clk) begin

  end

endmodule
