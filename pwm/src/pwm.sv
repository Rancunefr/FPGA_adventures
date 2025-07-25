`timescale 1ns / 1ps

module pwm (
    input  logic       clk,         // Signal horloge
    input  logic       rst,         // Reset sur état haut
    input  logic       start,       // Signal de control. Démarrage/arrêt du PWM
    input  logic [7:0] duty_cycle,  // control du rapport cyclique pwm
    input  logic       oe,          // si zéro, la sortie passe en haute impédance
    output logic       out          // sortie pwm
);

  parameter logic [23:0] CLK_SCALER = 10000;  // Divise la frequence de l'horloge ;

  logic [23:0] counter = 100;
  logic [ 7:0] pwm_counter = CLK_SCALER;

  always_ff @(posedge clk) begin
    if (start) begin
      counter <= (counter == 0) ? CLK_SCALER : counter - 1;
      if (counter == 0) begin
        pwm_counter <= (pwm_counter == 0) ? 100 : pwm_counter - 1;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (oe) begin
      out <= (pwm_counter < duty_cycle);
    end else begin
      out <= 1'bz;
    end
  end

endmodule

