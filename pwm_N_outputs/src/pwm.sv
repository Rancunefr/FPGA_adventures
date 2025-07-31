`timescale 1ns / 1ps

// TODO:
// Possibilité d'avoir N sorties
// Test bench a revoir
// Faire test sur implementation


module pwm #(
    parameter logic [23:0] CLK_SCALER         = 200,   // Prescaler pour la frequence PWM ;
    parameter logic [ 7:0] NB_OUTPUTS         = 2,     // Prescaler pour la frequence PWM ;
    parameter logic        RESET_OUTPUT_STATE = 1'bz,  // Etat de la ligne out suite à un reset
    parameter logic [ 7:0] RESET_DUTY_CYCLE   = 50,    // Valeur du duty cycle suite à un reset
    parameter logic [ 7:0] MIN_DUTY           = 0,     // Duty Cycle minimum
    parameter logic [ 7:0] MAX_DUTY           = 100    // Duty Cycle maximum
) (
    input logic clk,  // Signal horloge
    input logic rst,  // Reset sur état haut
    input logic run,  // Signal de control. Démarrage/arrêt du PWM
    input logic oe,  // si zéro, la sortie passe en haute impédance
    input logic [$clog2(
NB_OUTPUTS
)-1:0] duty_output,  // sortie dont on veut controler le duty_cycle
    input logic [7:0] duty_cycle,  // control du rapport cyclique (%)
    input logic duty_valid,  // signal de validation de duty_cycle.
    output logic [NB_OUTPUTS-1:0] out = '{NB_OUTPUTS{RESET_OUTPUT_STATE}}
);

  localparam logic [23:0] SCALER = CLK_SCALER / 100;  // Valeur interne du prescaler

  logic [7:0] pwm_counter = 0;
  logic [23:0] counter = SCALER - 1;
  logic [7:0] reg_duty_cycle[NB_OUTPUTS] = '{default: RESET_DUTY_CYCLE};

  generate
    begin
      if (CLK_SCALER <= 10000) $fatal("SCALE PARAMETER MUST BE >= 100");
      if (MIN_DUTY > 99) $error("MIN_DUTY MUST BE <= 99");
      if (MAX_DUTY > 100) $error("MAX_DUTY MUST BE <= 100");
      if (RESET_DUTY_CYCLE < MIN_DUTY) $error("RESET_DUTY_CYCLE MUST BE >= MIN_DUTY");
      if (RESET_DUTY_CYCLE > MAX_DUTY) $error("RESET_DUTY_CYCLE MUST BE <= MAX_DUTY");
    end
  endgenerate



  always_ff @(posedge clk) begin
    if (rst) begin
      pwm_counter <= 0;
      counter <= SCALER - 1;
    end else begin
      if (run) begin
        counter <= (counter == 0) ? SCALER - 1 : counter - 1;
        if (counter == 0) begin
          pwm_counter <= (pwm_counter == 99) ? 0 : pwm_counter + 1;
        end
      end else begin
        pwm_counter <= 99;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      out <= '{NB_OUTPUTS{RESET_OUTPUT_STATE}};
    end else begin
      for (int i = 0; i < NB_OUTPUTS; i++) begin
        if (oe) begin
          out[i] <= (pwm_counter < reg_duty_cycle[i]);
        end else begin
          out[i] <= 1'bz;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < NB_OUTPUTS; i++) begin
        reg_duty_cycle[i] <= RESET_DUTY_CYCLE;
      end
    end else begin
      if (duty_valid) begin
        if (duty_cycle > MAX_DUTY) begin
          reg_duty_cycle[duty_output] <= MAX_DUTY;
        end else if (duty_cycle < MIN_DUTY) begin
          reg_duty_cycle[duty_output] <= MIN_DUTY;
        end else begin
          reg_duty_cycle[duty_output] <= duty_cycle;
        end
      end
    end
  end

endmodule

