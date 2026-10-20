`timescale 1ns / 1ps

module signal_pipeline_tb;

    logic clk;
    logic reset;

    logic [7:0] inp_sample;
    logic       valid;

    logic [7:0] filtered_sample;
    logic       filtered_valid;

    logic [7:0] threshold;
    logic       detected;
    logic       detected_valid;

    int error_count;

    moving_average_filter filter_inst (
        .clk(clk),
        .reset(reset),
        .inp_sample(inp_sample),
        .valid(valid),
        .sample_out(filtered_sample),
        .outp_valid(filtered_valid)
    );

    threshold_detector detector_inst (
        .sample_in(filtered_sample),
        .sample_valid(filtered_valid),
        .threshold(threshold),
        .detected(detected),
        .detected_valid(detected_valid)
    );

    // 100 MHz clock: 10 ns period
    always #5 clk = ~clk;

    task send_and_check(
        input logic [7:0] input_sample,
        input logic [7:0] expected_filtered,
        input logic       expected_detected
    );
        begin
            @(posedge clk);
            inp_sample <= input_sample;
            valid      <= 1'b1;

            @(posedge clk);
            valid <= 1'b0;

            #1;

            if (filtered_valid !== 1'b1) begin
                $display("FAIL: input=%0d filtered_valid was not high", input_sample);
                error_count++;
            end

            if (filtered_sample !== expected_filtered) begin
                $display("FAIL: input=%0d expected_filtered=%0d got=%0d",
                         input_sample, expected_filtered, filtered_sample);
                error_count++;
            end

            if (detected_valid !== 1'b1) begin
                $display("FAIL: input=%0d detected_valid was not high", input_sample);
                error_count++;
            end

            if (detected !== expected_detected) begin
                $display("FAIL: input=%0d expected_detected=%0d got=%0d",
                         input_sample, expected_detected, detected);
                error_count++;
            end

            if ((filtered_sample === expected_filtered) &&
                (detected === expected_detected) &&
                (filtered_valid === 1'b1) &&
                (detected_valid === 1'b1)) begin
                $display("PASS: input=%0d filtered=%0d detected=%0d",
                         input_sample, filtered_sample, detected);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        inp_sample = 8'd0;
        valid = 1'b0;
        threshold = 8'd40;
        error_count = 0;

        repeat (3) @(posedge clk);
        reset = 0;

        send_and_check(8'd10, 8'd2,  1'b0);
        send_and_check(8'd20, 8'd7,  1'b0);
        send_and_check(8'd30, 8'd15, 1'b0);
        send_and_check(8'd40, 8'd25, 1'b0);
        send_and_check(8'd50, 8'd35, 1'b0);
        send_and_check(8'd60, 8'd45, 1'b1);
        send_and_check(8'd70, 8'd55, 1'b1);
        send_and_check(8'd80, 8'd65, 1'b1);

        repeat (5) @(posedge clk);

        if (error_count == 0) begin
            $display("=================================");
            $display("TEST PASSED: signal_pipeline");
            $display("=================================");
        end else begin
            $display("=================================");
            $display("TEST FAILED with %0d errors", error_count);
            $display("=================================");
        end

        $finish;
    end

endmodule