`timescale 1ns / 1ps

module tb_principal;

  logic clk;
  logic rst;
  logic data;

  parameter int CLOCK_PERIOD = 10;

  principal DUT (
      .clk(clk),
      .rst(rst),
      .data(data)
  );

  initial begin
    clk = 0;
    repeat (100000) begin
      #(CLOCK_PERIOD / 2) clk = ~clk;
    end
  end

  initial begin
    rst = 0;
    #20 rst = 1;
    #20;
    rst = 0;
  end


endmodule
