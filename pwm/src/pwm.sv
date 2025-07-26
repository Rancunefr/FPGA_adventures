`timescale 1ns / 1ps

// TODO:
// Possibilité de mettre un max et un min sur le duty cycle
// Possibilité d'avoir N sorties
// Assert sur le dutycycle pour eviter les 110% ... :)
// Test bench a revoir
// Faire test sur implementation


module pwm #(
    parameter logic [23:0] CLK_SCALER         = 200,   // Prescaler pour la frequence PWM ;
    parameter logic        RESET_OUTPUT_STATE = 1'bz,  // Etat de la ligne out suite à un reset
    parameter logic        RESET_DUTY_CYCLE   = 50     // Valeur du duty cycle suite à un reset
) (
    input  logic       clk,                      // Signal horloge
    input  logic       rst,                      // Reset sur état haut
    input  logic       run,                      // Signal de control. Démarrage/arrêt du PWM
    input  logic       oe,                       // si zéro, la sortie passe en haute impédance
    input  logic [7:0] duty_cycle,               // control du rapport cyclique (%)
    input  logic       duty_valid,               // signal de validation de duty_cycle.
    output logic       out = RESET_OUTPUT_STATE  // sortie pwm
);

  localparam logic [23:0] SCALER = CLK_SCALER / 100;  // Valeur interne du prescaler

  logic [ 7:0] pwm_counter = 99;
  logic [23:0] counter = SCALER - 1;
  logic [ 7:0] reg_duty_cycle = RESET_DUTY_CYCLE;

  initial begin
    assert (CLK_SCALER >= 100)
    else $error("SCALE PARAMETER MUST BE >= 100");
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      pwm_counter <= 99;
      counter <= SCALER - 1;
    end else begin
      if (run) begin
        counter <= (counter == 0) ? SCALER - 1 : counter - 1;
        if (counter == 0) begin
          pwm_counter <= (pwm_counter == 0) ? 99 : pwm_counter - 1;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      out <= RESET_OUTPUT_STATE;
    end else begin
      if (oe) begin
        out <= (pwm_counter < reg_duty_cycle);
      end else begin
        out <= 1'bz;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      reg_duty_cycle <= RESET_DUTY_CYCLE;
    end else begin
      if (duty_valid) begin
        reg_duty_cycle <= duty_cycle;
      end
    end
  end

endmodule

