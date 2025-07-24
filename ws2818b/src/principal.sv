`timescale 1ns / 1ps

module principal (
    input  logic clk,
    input  logic rst,
    output logic data
);

  logic [23:0] led_color = 0;
  logic [31:0] led_number = 0;
  logic        led_write = 0;

  typedef enum {
    S_WAIT1,
    S_WHITE,
    S_WAIT2,
    S_RED
  } state_t;

  state_t        state = S_WAIT1;
  logic   [24:0] counter = 0;

  ws2812b #(
      .NB_LEDS(15)
  ) ruban (
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
      state <= S_WAIT1;
    end else begin
      unique case (state)
        S_WAIT1: begin
          if (counter == 24'hFF0000) begin
            counter <= 0;
            led_write <= 0;
            state <= S_RED;
          end else begin
            counter <= counter + 1;
          end
        end
        S_RED: begin
          led_color <= 24'h00FF00;
          led_number <= 2;
          led_write <= 1;
          state <= S_WAIT2;
        end
        S_WAIT2: begin
          if (counter == 24'hFF0000) begin
            counter <= 0;
            led_write <= 0;
            state <= S_WHITE;
          end else begin
            counter <= counter + 1;
          end
        end
        S_WHITE: begin
          led_color <= 24'hFFFFFF;
          led_number <= 2;
          led_write <= 1;
          state <= S_WAIT1;
        end
      endcase
    end
  end

endmodule
