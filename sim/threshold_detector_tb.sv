`timescale 1ns / 1ps

module threshold_detector_tb;

    logic [7:0] sample_in;
    logic       sample_valid;
    logic [7:0] threshold;

    logic       detected;
    logic       detected_valid;

    int error_count;

    threshold_detector dut (
        .sample_in(sample_in),
        .sample_valid(sample_valid),
        .threshold(threshold),
        .detected(detected),
        .detected_valid(detected_valid)
    );

    task check_detection(
        input logic [7:0] test_sample,
        input logic       expected_detected
    );
        begin
            sample_in    = test_sample;
            sample_valid = 1'b1;

            #1;

            if (detected_valid !== 1'b1) begin
                $display("FAIL: sample=%0d detected_valid was not high", test_sample);
                error_count++;
            end

            if (detected !== expected_detected) begin
                $display("FAIL: sample=%0d threshold=%0d expected_detected=%0d got=%0d",
                         test_sample, threshold, expected_detected, detected);
                error_count++;
            end else begin
                $display("PASS: sample=%0d threshold=%0d detected=%0d",
                         test_sample, threshold, detected);
            end

            sample_valid = 1'b0;
            #1;
        end
    endtask

    initial begin
        error_count = 0;

        sample_in = 8'd0;
        sample_valid = 1'b0;
        threshold = 8'd40;

        check_detection(8'd25, 1'b0);
        check_detection(8'd35, 1'b0);
        check_detection(8'd39, 1'b0);
        check_detection(8'd40, 1'b1);
        check_detection(8'd45, 1'b1);
        check_detection(8'd65, 1'b1);

        if (error_count == 0) begin
            $display("=================================");
            $display("TEST PASSED: threshold_detector");
            $display("=================================");
        end else begin
            $display("=================================");
            $display("TEST FAILED with %0d errors", error_count);
            $display("=================================");
        end

        $finish;
    end

endmodule