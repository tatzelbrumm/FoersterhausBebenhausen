module quadrature_oscillator_sync_tb;

    // Parameters
    reg clk;
    reg load;
    reg signed [15:0] re_coeff;
    reg signed [15:0] im_coeff;
    reg signed [15:0] power;
    reg signed [15:0] accu_re_init;
    reg signed [15:0] accu_im_init;
    wire signed [15:0] accu_re;
    wire signed [15:0] accu_im;

    // Number of iterations
    integer num_iterations = 1000;  // Specify the number of iterations here
    integer i;

    // Instantiate the quadrature oscillator module
    quadrature_oscillator_sync uut (
        .clk(clk),
        .load(load),
        .re_coeff(re_coeff),
        .im_coeff(im_coeff),
        .power(power),
        .accu_re_init(accu_re_init),
        .accu_im_init(accu_im_init),
        .accu_re(accu_re),
        .accu_im(accu_im)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 time units clock period
    end

    // Test procedure
    initial begin
        // Initialize parameters
        re_coeff = 16'h4000;  // Example real coefficient
        im_coeff = 16'h2000;  // Example imaginary coefficient
        power = 16'h1000;     // Target power level
        accu_re_init = 16'h3000;  // Initial accumulator real part
        accu_im_init = 16'h1000;  // Initial accumulator imaginary part

        // Preload the oscillator with initial values
        load = 1;
        #10; // Wait for 1 clock cycle to load initial values
        load = 0;

        // Run for the specified number of iterations
        for (i = 0; i < num_iterations; i = i + 1) begin
            #10;  // Wait for 1 clock cycle per iteration
            $display("%0d, %d, %d", i, accu_re, accu_im);
        end

        // End simulation
        $finish;
    end

endmodule

