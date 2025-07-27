`timescale 1ns / 1ps

// TODO:
// Possibilité d'avoir N sorties
// Test bench a revoir
// Faire test sur implementation


module pwm #(
    parameter logic [23:0] CLK_SCALER         = 200,   // Prescaler pour la frequence PWM ;
    parameter logic        RESET_OUTPUT_STATE = 1'bz,  // Etat de la ligne out suite à un reset
    parameter logic [ 7:0] RESET_DUTY_CYCLE   = 50,    // Valeur du duty cycle suite à un reset
    parameter logic [ 7:0] MIN_DUTY           = 0,     // Duty Cycle minimum
    parameter logic [ 7:0] MAX_DUTY           = 100    // Duty Cycle maximum
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

  logic [ 7:0] pwm_counter = 0;
  logic [23:0] counter = SCALER - 1;
  logic [ 7:0] reg_duty_cycle = RESET_DUTY_CYCLE;

  initial begin
    assert (CLK_SCALER >= 100)
    else $error("SCALE PARAMETER MUST BE >= 100");

    assert (MIN_DUTY <= 99)
    else $error("MIN_DUTY MUST BE <= 99");

    assert (MAX_DUTY <= 100)
    else $error("MAX_DUTY MUST BE <= 100");

    assert (RESET_DUTY_CYCLE >= MIN_DUTY)
    else $error("RESET_DUTY_CYCLE MUST BE >= MIN_DUTY");

    assert (RESET_DUTY_CYCLE <= MAX_DUTY)
    else $error("RESET_DUTY_CYCLE MUST BE <= MAX_DUTY");
  end

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
		pwm_counter <= 99 ;
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
        if (duty_cycle > MAX_DUTY) begin
          reg_duty_cycle <= MAX_DUTY;
        end else if (duty_cycle < MIN_DUTY) begin
          reg_duty_cycle <= MIN_DUTY;
        end else begin
          reg_duty_cycle <= duty_cycle;
        end
      end
    end
  end

endmodule

