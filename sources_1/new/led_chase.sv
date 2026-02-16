//------------------------------------------------------------------------------
// Simple sequential LED blink/chase for KC705 (SystemVerilog)
// One LED at a time: 0.5 s ON, 0.5 s OFF, then advance to next LED.
// Assumes a 200 MHz single-ended clock (sys_clk_200).
//------------------------------------------------------------------------------

module led_chase #(
    // 0.5 second at 200 MHz = 100,000,000 cycles
    parameter int unsigned HALF_SEC_TICKS = 100_000_000
) (
    input  logic        sys_clk_200, // 200 MHz clock
    output logic [7:0]  led          // led[0]..led[7]
);

    // -------------------------------------------------------------------------
    // Optional internal power-on reset (POR)
    // Hold reset low for a short interval after configuration.
    // -------------------------------------------------------------------------
    logic        rst_n = 1;
    logic [21:0] por_cnt = '0; // ~20 ms at 200 MHz -> 4,000,000 cycles (fits in 22 bits)

    always_ff @(posedge sys_clk_200) begin
        if (!rst_n) begin
            por_cnt <= (por_cnt == 22'd4_000_000) ? por_cnt : por_cnt + 22'd1;
        end
    end

    // Release reset when counter expires (combinational for immediate effect)
    always_comb begin
        rst_n = (por_cnt == 22'd4_000_000);
    end

    // -------------------------------------------------------------------------
    // State and timing
    // -------------------------------------------------------------------------
    logic [26:0] timer_cnt = '0;   // Enough bits for 100e6 (< 2^27 ~ 134e6)
    logic        phase_on  = 1'b1; // 1 = ON phase, 0 = OFF phase
    logic [2:0]  led_idx   = 3'd0; // Which LED is active (0..7)

    // LED driver: one-hot during ON phase, all off during OFF phase
    always_comb begin
        led = '0;
        if (phase_on) begin
            led[led_idx] = 1'b1;
        end
    end

    // Timer + state progression
    always_ff @(posedge sys_clk_200) begin
        if (!rst_n) begin
            timer_cnt <= '0;
            phase_on  <= 1'b1;
            led_idx   <= 3'd0;
        end else begin
            if (timer_cnt == (HALF_SEC_TICKS - 1)) begin
                timer_cnt <= '0;

                // Toggle ON/OFF phase every 0.5 s
                phase_on <= ~phase_on;

                // After completing the OFF phase, move to the next LED
                if (!phase_on) begin
                    led_idx <= (led_idx == 3'd7) ? 3'd0 : (led_idx + 3'd1);
                end
            end else begin
                timer_cnt <= timer_cnt + 27'd1;
            end
        end
    end

endmodule