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

        // Scale the results back to Q15 format
        temp_re = (temp_re >> 15) * power;
        temp_im = (temp_im >> 15) * power;

        // Compute the square and subtract operation
        int32_t ac3 = power; // Load target power into AC3
        ac3 -= (temp_re * temp_re) >> 15; // Subtract the square of the real part, scaled back to Q15
        ac3 -= (temp_im * temp_im) >> 15; // Subtract the square of the imaginary part, scaled back to Q15

        // Extract high part of AC3 and use it to scale results
        int16_t t0 = (int16_t)(ac3 >> 16);
        temp_re += (temp_re * t0) >> 15;
        temp_im += (temp_im * t0) >> 15;

        // Saturate to 16-bit range
        if (temp_re > 32767) temp_re = 32767;
        if (temp_re < -32768) temp_re = -32768;
        if (temp_im > 32767) temp_im = 32767;
        if (temp_im < -32768) temp_im = -32768;

        // Update the accumulator with the new values
        accu_re = (int16_t)temp_re;
        accu_im = (int16_t)temp_im;
    }

    // Update the original accumulator values
    accu[0] = accu_re;
    accu[1] = accu_im;
}

/*
Mathematical Notation:
1. Initialize accumulator values:
   Re_acc = accu[0]
   Im_acc = accu[1]

2. For each iteration (i = 0 to n_1):
   a. Store current values:
      result[0][i] = Re_acc
      result[1][i] = Im_acc

   b. Compute next accumulator values:
      Temp_Re = Re_acc * Re_coeff - Im_acc * Im_coeff
      Temp_Im = Re_acc * Im_coeff + Im_acc * Re_coeff

   c. Scale back to Q15 format:
      Temp_Re = (Temp_Re >> 15) * Power
      Temp_Im = (Temp_Im >> 15) * Power

   d. Square and subtract operation:
      AC3 = Power
      AC3 -= (Temp_Re^2) >> 15
      AC3 -= (Temp_Im^2) >> 15

   e. Extract high part of AC3 and use it to scale results:
      T0 = AC3 >> 16
      Temp_Re += (Temp_Re * T0) >> 15
      Temp_Im += (Temp_Im * T0) >> 15

   f. Saturate results to 16-bit range:
      Temp_Re = max(min(Temp_Re, 32767), -32768)
      Temp_Im = max(min(Temp_Im, 32767), -32768)

   g. Update accumulator:
      Re_acc = Temp_Re
      Im_acc = Temp_Im

3. Update original accumulator values:
   accu[0] = Re_acc
   accu[1] = Im_acc
*/

