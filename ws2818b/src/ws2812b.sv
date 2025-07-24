`timescale 1ns / 1ps

module ws2812b (
    input logic clk,
    input logic rst,
    input logic [23:0] color,
    input logic [31:0] nb_led,
    input logic write,
    output logic data
);

  parameter int FCLK = 100;  // MHz
  parameter int NB_LEDS = 5;  // Total number of leds

  parameter int T0H = 400;  // nanoseconds
  parameter int T1H = 850;  // nanoseconds
  parameter int T0L = 850;  // nanoseconds
  parameter int T1L = 400;  // nanoseconds
  parameter int TRST = 100000;  // nanoseconds

  localparam int TCLK = 1000 / (FCLK);  // nanoseconds
  localparam int C0H = T0H / TCLK;  // clock periods
  localparam int C1H = T1H / TCLK;  // clock periods
  localparam int C0L = T0L / TCLK;  // clock periods
  localparam int C1L = T1L / TCLK;  // clock periods
  localparam int CRST = TRST / TCLK;  // clock periods

  logic [23:0] RGB_color[NB_LEDS] = '{0: 24'hFF0000, 2: 24'hFFFFFF, default: 24'h00FF00};

  int current_led;
  logic [4:0] current_bit;
  logic [$clog2(CRST):0] counter;

  typedef enum {
    IDLE,
    DATAOUT,
    RESET
  } state_t;

  state_t state;

  initial begin
    $display("COH  %d", C0H);
    $display("COL  %d", C0L);
    $display("C1H  %d", C1H);
    $display("C1L  %d", C1L);
    $display("CRST %d", CRST);
  end

  always_ff @(posedge clk) begin
    if (write) begin
      RGB_color[nb_led] <= color;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= RESET;
    end else begin
      unique case (state)

        IDLE: begin  // FIXME Necessaire ?
          data <= 0;
          current_led <= 0;
          current_bit <= 23;
          counter <= 0;
          state <= DATAOUT;
        end

        DATAOUT: begin
          if (current_led == NB_LEDS) begin
            state   <= RESET;
            counter <= 0;
          end else begin
            if (counter < (RGB_color[current_led][current_bit] ? C1H : C0H)) begin
              data <= 1;
              counter <= counter + 1;
            end else begin
              if (counter < (RGB_color[current_led][current_bit] ? C1H + C1L - 1 : C0H + C0L - 1)) begin
                data <= 0;
                counter <= counter + 1;
              end else begin
                if (current_bit > 0) begin
                  current_bit <= current_bit - 1;
                end else begin
                  current_bit <= 23;
                  current_led <= current_led + 1;
                end
                counter <= 0;
              end
            end
          end
        end

        RESET: begin
          data <= 0;
          if (counter == CRST) begin
            current_led <= 0;
            current_bit <= 23;
            counter <= 0;
            state <= DATAOUT;
          end else begin
            counter <= counter + 1;
          end
        end

      endcase

    end
  end
endmodule
