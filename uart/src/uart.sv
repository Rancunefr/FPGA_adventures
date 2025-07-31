`timescale 1ns / 1ps

import uart_pkg::*;

module uart #(
    parameter integer  CLOCKRATE = 100,   // clockrate (MHz)
    parameter integer  BAUDRATE  = 9600,  // baudrate (bps)
    parameter integer  DATA_BITS = 8,     // nbre de bits de données
    parameter parity_t PARITY    = NONE,
    parameter integer  STOP_BITS = 1      // nbre de bits de stops
) (
    input logic clk,
    input logic rst,

    input  logic [DATA_BITS-1:0] tx_data,  // Données à transmettre
    input  logic                 tx_en,    // Active la transmission série
    output logic                 tx_ready, // Indique que l'uart est prête à transmettre

    // output logic [DATA_BITS-1:0] rx_data,   // Données reçues
    // output logic                 rx_valid,  // Indique que les données sont valides
    // input  logic                 rx_en,     // Active la reception série

    output logic tx  // Ligne de sortie UART
    // input  logic rx   // Ligne d'entrée UART
);

  localparam integer CNTLIMIT = CLOCKRATE * 1000000 / BAUDRATE;
  localparam integer BUFFSIZE = 1 + DATA_BITS + (PARITY != NONE) + STOP_BITS;

  logic [$clog2(CNTLIMIT)-1:0] counter_tx;

  logic [BUFFSIZE-1:0] buffer_tx;
  logic [BUFFSIZE-1:0] buffer_rx;

  typedef enum {
    IDLE,
    BIT_CHANGE,
    WAIT
  } state_t;

  state_t tx_state;
  state_t rx_state;

  always_ff @(posedge clk) begin
    if (rst) begin
      tx_state <= IDLE;
    end else begin
      unique case (tx_state)

        IDLE: begin
          tx <= 1;
          tx_ready <= 1;
          if (tx_en) begin
            buffer_tx <= {{STOP_BITS{1'b1}}, tx_data, 1'b0};  // FIXME AJOUT DE LA PARITY
            tx_state  <= BIT_CHANGE;
          end
        end

        BIT_CHANGE: begin
          tx_ready <= 0;
          if (buffer_tx) begin
            tx <= buffer_tx[0];
            buffer_tx >>= 1;
            counter_tx <= CNTLIMIT;
            tx_state   <= WAIT;
          end else begin
            tx_state <= IDLE;
          end
        end

        WAIT: begin
          if (counter_tx > 0) begin
            counter_tx <= counter_tx - 1;
          end else begin
            tx_state <= BIT_CHANGE;
          end
        end

      endcase
    end
  end
endmodule

