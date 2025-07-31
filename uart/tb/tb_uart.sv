`timescale 1ns / 1ps

module tb_uart;

  parameter int CLOCK_PERIOD = 10;

  logic clk;
  logic rst;
  logic tx;
  logic data_send;

  uart DUT (
      .clk(clk),
      .rst(rst),
      .tx(tx),
      .data_out_ready(data_send)
  );

  initial begin
    clk = 0;
    repeat (1000000) begin
      #(CLOCK_PERIOD / 2) clk = ~clk;
    end
  end

  initial begin
    rst = 0;
    #20;
    rst = 1;
    #20;
    rst = 0;
    #50 data_send = 1;
    #200000 data_send = 0;
  end

endmodule
