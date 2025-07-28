`timescale 1ns / 1ps

module ws2812b #(
    parameter logic [31:0] FCLK = 100,  // MHz
    parameter logic [31:0] NB_LEDS = 5,  // Nombre total de leds
    parameter logic [23:0] START_COLOR = 24'h555555,  // Couleur par défaut (GGRRBB)
    parameter logic [31:0] T0H = 400,  // ns
    parameter logic [31:0] T1H = 850,  // ns
    parameter logic [31:0] T0L = 850,  // ns
    parameter logic [31:0] T1L = 400,  // ns
    parameter logic [31:0] TRST = 100000  // ns
) (
    input logic clk,
    input logic rst,
    input logic [23:0] color,  // Réglage de la couleur
    input logic [$clog2(NB_LEDS)-1:0] nb_led,  // Numéro de la led régler
    input logic write,  // Doit être mis à 1 lorsque color et nb_led sont fixés
    output logic data = 0
);

  localparam logic [31:0] TCLK = 1000 / (FCLK);  // ns
  localparam logic [31:0] C0H = T0H / TCLK;  // cycles
  localparam logic [31:0] C1H = T1H / TCLK;  // cycles
  localparam logic [31:0] C0L = T0L / TCLK;  // cycles
  localparam logic [31:0] C1L = T1L / TCLK;  // cycles
  localparam logic [31:0] CRST = TRST / TCLK;  // cycles

  logic [23:0] RGB_color[NB_LEDS] = '{
      0: 24'hFF0000,
      NB_LEDS - 1: 24'hFF0000,
      default: START_COLOR
  };

  logic [31:0] current_led;
  logic [4:0] current_bit;
  logic [$clog2(CRST):0] counter;

  typedef enum {
    IDLE,
    DATAOUT,
    RESET
  } state_t;

  state_t state;

  initial begin
    $display("Fréquence horloge : %d MHz", FCLK);
    $display("T0H  %d ns", T0H);
    $display("T0L  %d ns", T0L);
    $display("T1H  %d ns", T1H);
    $display("T1L  %d ns", T1L);
    $display("TRST %d ns", TRST);
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

        IDLE: begin
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
              if (counter < (RGB_color[current_led][current_bit] ? C1H + C1L - 1 : C0H + C0L - 1))
              begin
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
