`timescale 1ns / 1ps

module moving_average_filter_tb;

    logic clk;
    logic reset;

    logic [7:0] inp_sample;
    logic       valid;

    logic [7:0] sample_out;
    logic       outp_valid;

    int error_count;

    moving_average_filter dut (
        .clk(clk),
        .reset(reset),
        .inp_sample(inp_sample),
        .valid(valid),
        .sample_out(sample_out),
        .outp_valid(outp_valid)
    );

    // 100 MHz clock: 10 ns period
    always #5 clk = ~clk;

    task send_and_check(
        input logic [7:0] input_value,
        input logic [7:0] expected_output
    );
        begin
            @(posedge clk);
            inp_sample <= input_value;
            valid      <= 1'b1;

            @(posedge clk);
            valid <= 1'b0;

            // Small delay so values settle visually in simulation
            #1;

            if (outp_valid !== 1'b1) begin
                $display("FAIL: output_valid was not high for input=%0d", input_value);
                error_count++;
            end

            if (sample_out !== expected_output) begin
                $display("FAIL: input=%0d expected=%0d got=%0d",
                         input_value, expected_output, sample_out);
                error_count++;
            end else begin
                $display("PASS: input=%0d output=%0d",
                         input_value, sample_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        inp_sample = 8'd0;
        valid = 1'b0;
        error_count = 0;

        repeat (3) @(posedge clk);
        reset = 0;

        send_and_check(8'd10, 8'd2);
        send_and_check(8'd20, 8'd7);
        send_and_check(8'd30, 8'd15);
        send_and_check(8'd40, 8'd25);
        send_and_check(8'd50, 8'd35);
        send_and_check(8'd60, 8'd45);
        send_and_check(8'd70, 8'd55);
        send_and_check(8'd80, 8'd65);

        repeat (5) @(posedge clk);

        if (error_count == 0) begin
            $display("=================================");
            $display("TEST PASSED: moving_average_filter");
            $display("=================================");
        end else begin
            $display("=================================");
            $display("TEST FAILED with %0d errors", error_count);
            $display("=================================");
        end

        $finish;
    end

endmodule