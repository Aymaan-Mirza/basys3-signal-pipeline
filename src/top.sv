module top (
    input  logic        clk,
    input  logic        btnC,
    input  logic        btnU,
    input  logic [7:0]  sw,
    output logic [7:0]  led,
    output logic        led15
);

    logic       sample_pulse;
    logic [7:0] filtered_sample;
    logic       filtered_valid;

    logic       signal_detected;
    logic       signal_detected_valid;

    logic       detected_led_latch;

    localparam logic [7:0] THRESHOLD = 8'd40;

    button_one_pulse pulse_inst (
        .clk(clk),
        .reset(btnU),
        .button_in(btnC),
        .pulse_out(sample_pulse)
    );

    moving_average_filter filter_inst (
        .clk(clk),
        .reset(btnU),
        .inp_sample(sw),
        .valid(sample_pulse),
        .sample_out(filtered_sample),
        .outp_valid(filtered_valid)
    );

    threshold_detector detector_inst (
        .sample_in(filtered_sample),
        .sample_valid(filtered_valid),
        .threshold(THRESHOLD),
        .detected(signal_detected),
        .detected_valid(signal_detected_valid)
    );

    always_ff @(posedge clk) begin
        if (btnU) begin
            detected_led_latch <= 1'b0;
        end else begin
            if (signal_detected_valid) begin
                detected_led_latch <= signal_detected;
            end
        end
    end

    assign led   = filtered_sample;
    assign led15 = detected_led_latch;

endmodule