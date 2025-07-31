`timescale 1ns / 1ps

module tb_uart;

  parameter int CLOCK_PERIOD = 10;

  logic clk;
  logic rst;
  logic tx;
  logic [7:0] tx_data;
  logic tx_en;
  logic tx_ready;

  uart DUT (
      .clk(clk),
      .rst(rst),
      .tx(tx),
      .tx_data(tx_data),
      .tx_en(tx_en),
      .tx_ready(tx_ready)
  );

  initial begin
    clk = 0;
    repeat (1000000) begin
      #(CLOCK_PERIOD / 2) clk = ~clk;
    end
  end

  initial begin
    rst = 0;
    tx_data = "H";
    tx_en = 0;
    #20;
    rst = 1;
    #20;
    rst = 0;
    #500000;
    tx_data = "R";
    tx_en   = 1;
    #10;
    tx_en = 0;
  end

endmodule
