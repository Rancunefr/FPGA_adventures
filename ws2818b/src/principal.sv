`timescale 1ns / 1ps

module principal (
    input  logic clk,
    input  logic rst,
    output logic data
);

  logic [23:0] led_color;
  logic [31:0] led_number;
  logic        led_write;

  logic [ 1:0] state;
  logic [24:0] counter;

  ws2812b ruban (
      .clk(clk),
      .rst(rst),
      .data(data),
      .color(led_color),
      .nb_led(led_number),
      .write(led_write)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      led_write <= 0;
      led_color <= 0;
      led_number <= 0;
      counter <= 0;
      state <= 0;
    end else begin
      unique case (state)
        2'b00: begin
          if (counter == 24'hFF0000) begin
            counter <= 0;
            led_write <= 0;
            state <= 2'b01;
          end else begin
            counter <= counter + 1;
          end
        end
        2'b01: begin
          led_color <= 24'h00FF00;
          led_number <= 2;
          led_write <= 1;
          state <= 2'b10;
        end
        2'b10: begin
          if (counter == 24'hFF0000) begin
            counter <= 0;
            led_write <= 0;
            state <= 2'b11;
          end else begin
            counter <= counter + 1;
          end
        end
        2'b11: begin
          led_color <= 24'hFFFFFF;
          led_number <= 2;
          led_write <= 1;
          state <= 2'b00;
        end
      endcase
    end
  end

endmodule
