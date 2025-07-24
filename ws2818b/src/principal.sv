`timescale 1ns / 1ps

module principal (
    input  logic clk,
    input  logic rst,
    output logic data
);

  logic [23:0] led_color = 0;
  logic [31:0] led_number = 0;
  logic        led_write = 0;

  logic [24:0] counter = 0;
  logic [23:0] position_led = 1;

  typedef enum {
    S_WAIT,
    S_LED1,
    S_LED2
  } state_t;
  state_t state = S_WAIT;

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
      position_led <= 1;
      counter <= 0;
      state <= S_WAIT;
    end else begin
      unique case (state)
        S_WAIT: begin
          led_write <= 0;
          if (counter == 24'hFF0000) begin
            counter <= 0;
            state   <= S_LED1;
          end else begin
            counter <= counter + 1;
          end
        end

        S_LED1: begin
          led_number <= position_led;
          led_color <= 24'h00FF00;
          led_write <= 1;
          position_led <= (position_led == 13) ? 1 : position_led + 1;
          state <= S_LED2;
        end

        S_LED2: begin
          led_number <= position_led;
          led_color <= 24'hFFFFFF;
          led_write <= 1;
          state <= S_WAIT;
        end

      endcase
    end
  end

endmodule
