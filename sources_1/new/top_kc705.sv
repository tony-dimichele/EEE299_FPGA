
// -----------------------------------------------------------------------------
// top_kc705.sv
//
// Correct flash part to store .bin is Micron MT25QL128ABA8ESF-0SIT (128 Mbit = 16 MB Quad-SPI Flash)
// Switch 13 should be set [1:5] = xx001 to program and boot from Quad-SPI flash.
// -----------------------------------------------------------------------------
module top_kc705 (
    input  wire clk200_p,     // KC705 200 MHz LVDS system clock (SiT9102)
    input  wire clk200_n,
//    input  wire rst_n,         // Active-low reset (map to a button or tie high)
    output wire [7:0] led      // Matches your XDC: led[0]..led[7]
);

    wire clk_200;
    IBUFDS #(
        .DIFF_TERM("TRUE"),
        .IBUF_LOW_PWR("FALSE")
    ) i_sysclk_buf (
        .I (clk200_p),
        .IB(clk200_n),
        .O (clk_200)
    );

    // Instantiate the previously provided LED chase module
    led_chase led_chase_1 (
        .sys_clk_200(clk_200),
        .led       (led)
    );

endmodule
