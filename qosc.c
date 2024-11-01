#include <stdint.h>
#include <stdio.h>

#define AMPLITUDE 10000      // Maximum amplitude
#define FREQUENCY 327        // Frequency control, in range (0 < FREQUENCY < 65536)

int main() {
    // Initializing the sine and cosine components
    int32_t sine = 0;
    int32_t cosine = AMPLITUDE;

    // Temporary variables for the new values of sine and cosine
    int32_t new_sine;
    int32_t new_cosine;

    // Simulating the oscillator
    for (int i = 0; i < 10000; i++) {
        // Calculate the new values using fixed-point arithmetic
        new_sine = sine + ((cosine * FREQUENCY) >> 15);
        new_cosine = cosine - ((sine * FREQUENCY) >> 15);

        // Update sine and cosine values
        sine = new_sine;
        cosine = new_cosine;

        // Print the current values (scaled back to the original range)
        //printf("Step %d: Sine = %d, Cosine = %d\n", i, sine, cosine);
        printf("%d, %d, %d\n", i, sine, cosine);
    }

    return 0;
}
