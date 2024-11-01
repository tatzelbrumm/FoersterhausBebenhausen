#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <math.h>

#define ITERATIONS 500

void qosc(const int16_t *coeff, int16_t *accu, uint16_t n_1, int16_t **result);

int main() {
    // Set coefficients for a 12-degree rotation in Q15 format
    double angle_rad = 12.0 * M_PI / 180.0;
    int16_t re_coeff = (int16_t)(cos(angle_rad) * (1 << 15));
    int16_t im_coeff = (int16_t)(sin(angle_rad) * (1 << 15));
    int16_t power = 1024; // Adjusted power to match initial magnitude of accumulator

    // Coefficients array {power, re_coeff, im_coeff}
    int16_t coeff[] = { power, re_coeff, im_coeff };

    // Initial accumulator values {real, imaginary}, matching the target power
    int16_t accu[] = { 1024, 0 };

    // Allocate result arrays for real and imaginary parts
    int16_t *result[2];
    result[0] = (int16_t *)malloc((ITERATIONS + 1) * sizeof(int16_t));
    result[1] = (int16_t *)malloc((ITERATIONS + 1) * sizeof(int16_t));

    // Run quadrature oscillator
    qosc(coeff, accu, ITERATIONS, result);

    // Write results to a data file for Gnuplot
    FILE *f = fopen("qosc_output.dat", "w");
    if (!f) {
        perror("Failed to open file");
        return 1;
    }

    for (int i = 0; i <= ITERATIONS; i++) {
        fprintf(f, "%d %d %d\n", i, result[0][i], result[1][i]);
    }
    fclose(f);

    // Free allocated memory
    free(result[0]);
    free(result[1]);

    printf("Data written to qosc_output.dat. You can now plot it using Gnuplot.\n");

    return 0;
}

