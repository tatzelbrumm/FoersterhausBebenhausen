#include <stdint.h>

void qosc(const int16_t *coeff, int16_t *accu, uint16_t n_1, int16_t **result) {
    // Extract coefficients
    int16_t power = coeff[0];
    int16_t re_coeff = coeff[1];
    int16_t im_coeff = coeff[2];

    // Initialize real and imaginary parts of accumulator
    int16_t accu_re = accu[0];
    int16_t accu_im = accu[1];

    // Loop through the iterations
    for (uint16_t i = 0; i <= n_1; i++) {
        // Store the current accumulator values in the result arrays
        result[0][i] = accu_re;
        result[1][i] = accu_im;

        // Compute the next accumulator values using the coefficients
        int32_t temp_re = (int32_t)accu_re * re_coeff - (int32_t)accu_im * im_coeff;
        int32_t temp_im = (int32_t)accu_re * im_coeff + (int32_t)accu_im * re_coeff;

        int16_t tmph_re = temp_re >> 15;
        int16_t tmph_im = temp_im >> 15;

        // Compute the square and subtract operation
        int32_t ac3 = power << 16; // Load target power into AC3
        ac3 -= tmph_re * tmph_re;  // Subtract the square of the real part
        ac3 -= tmph_im * tmph_im;  // Subtract the square of the imaginary part

        // Extract high part of AC3 and use it to scale results
        int16_t t0 = (int16_t)(ac3 >> 16);
        temp_re += tmph_re * t0;
        temp_im += tmph_im * t0;

        // Update the accumulator with the new values
        accu_re = (int16_t)(temp_re >> 15);
        accu_im = (int16_t)(temp_im >> 15);
    }

    // Update the original accumulator values
    accu[0] = accu_re;
    accu[1] = accu_im;
}

