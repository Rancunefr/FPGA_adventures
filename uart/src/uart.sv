`timescale 1ns / 1ps

module uart #(
    parameter integer CLOCKRATE = 100,  // clockrate (MHz)
    parameter integer BAUDRATE  = 9600  // baudrate (bps)
) (
    input  logic clk,
    input  logic rst,
    //    input logic [7:0] data_in,
    //    input logic data_in_rdy,
    //    output logic [7:0] data_out,
    input logic data_out_ready,
    output logic tx
    //    input logic rx
);

  localparam integer CNTLIMIT = CLOCKRATE * 1000000 / BAUDRATE;

  typedef enum {
    IDLE,
    START_BIT,
    DATA,
    PARITY,
    STOP_BIT
  } state_t;

  logic   [$clog2(CNTLIMIT):0] counter;
  logic                        bit_start;
  logic   [               7:0] buffer_out = "C";

  state_t                      state;
  state_t                      next_state;
  logic   [               3:0] tx_posbit;

  always_ff @(posedge clk) begin
    if (rst) begin
      counter   <= CNTLIMIT;
      bit_start <= 0;
    end else begin
      if (counter > 0) begin
        counter   <= counter - 1;
        bit_start <= 0;
      end else begin
        counter   <= CNTLIMIT;
        bit_start <= 1;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      if (bit_start) begin
        case (state)

          IDLE: begin
            tx <= 1;
            if (data_out_ready) next_state <= START_BIT;
            else next_state <= IDLE;
          end

          START_BIT: begin
            tx <= 0;
            next_state <= DATA;
            tx_posbit <= 0;
          end

          DATA: begin
            tx <= buffer_out[tx_posbit];
            tx_posbit <= tx_posbit + 1;
            if (tx_posbit == 7) next_state <= STOP_BIT;
          end

          PARITY: begin
          end

          STOP_BIT: begin
            tx <= 1;
            next_state <= IDLE;
          end

          default: begin
            next_state <= IDLE;
          end

        endcase
      end else begin
        state <= next_state;
      end
    end
  end
endmodule

