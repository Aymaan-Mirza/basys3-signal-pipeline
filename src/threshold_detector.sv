module threshold_detector (
    input  logic [7:0] sample_in,
    input  logic       sample_valid,
    input  logic [7:0] threshold,

    output logic       detected,
    output logic       detected_valid
);

    always_comb begin
        if (sample_valid) begin
            detected       = (sample_in >= threshold);
            detected_valid = 1'b1;
        end else begin
            detected       = 1'b0;
            detected_valid = 1'b0;
        end
    end

endmodule