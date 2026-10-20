module button_one_pulse (
    input  logic clk,
    input  logic reset,
    input  logic button_in,
    output logic pulse_out
);

    logic button_prev;

    always_ff @(posedge clk) begin
        if (reset) begin
            button_prev <= 1'b0;
            pulse_out   <= 1'b0;
        end else begin
            button_prev <= button_in;

            // Creates a 1-clock-cycle pulse when button_in rises from 0 to 1
            pulse_out <= button_in & ~button_prev;
        end
    end

endmodule