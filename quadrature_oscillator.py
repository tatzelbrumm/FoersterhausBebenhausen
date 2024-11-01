import numpy as np
import math
import matplotlib.pyplot as plt

def qosc(coeff, accu, n_1):
    # Extract coefficients
    power = coeff[0]
    re_coeff = coeff[1]
    im_coeff = coeff[2]

    # Initialize real and imaginary parts of accumulator
    accu_re = accu[0]
    accu_im = accu[1]

    # Prepare storage for results
    result_re = []
    result_im = []

    # Loop through the iterations
    for i in range(n_1 + 1):
        # Store the current accumulator values in the result arrays
        result_re.append(accu_re)
        result_im.append(accu_im)

        # Compute the next accumulator values using the coefficients
        temp_re = int(accu_re) * re_coeff - int(accu_im) * im_coeff
        temp_im = int(accu_re) * im_coeff + int(accu_im) * re_coeff

        # Scale the results back to Q15 format
        temp_re = (temp_re >> 15) * power
        temp_im = (temp_im >> 15) * power

        # Compute the square and subtract operation
        ac3 = power  # Load target power into AC3
        ac3 -= (temp_re * temp_re) >> 15  # Subtract the square of the real part, scaled back to Q15
        ac3 -= (temp_im * temp_im) >> 15  # Subtract the square of the imaginary part, scaled back to Q15

        # Extract high part of AC3 and use it to scale results
        t0 = (ac3 >> 16) & 0xFFFF
        temp_re += (temp_re * t0) >> 15
        temp_im += (temp_im * t0) >> 15

        # Saturate to 16-bit range
        temp_re = max(min(temp_re, 32767), -32768)
        temp_im = max(min(temp_im, 32767), -32768)

        # Update the accumulator with the new values
        accu_re = temp_re
        accu_im = temp_im

    # Update the original accumulator values
    accu[0] = accu_re
    accu[1] = accu_im

    return result_re, result_im

# Test environment
def test_qosc():
    # Set coefficients for a 12-degree rotation
    angle_rad = math.radians(12)
    re_coeff = int(math.cos(angle_rad) * (1 << 15))  # Q15 format
    im_coeff = int(math.sin(angle_rad) * (1 << 15))  # Q15 format
    power = 14142  # Adjusted power to match initial magnitude of accumulator

    # Test coefficients {power, re_coeff, im_coeff}
    coeff = [power, re_coeff, im_coeff]
    # Initial accumulator values {real, imaginary}, matching the target power
    accu = [int(power / math.sqrt(2)), int(power / math.sqrt(2))]
    # Number of iterations - 1
    n_1 = 1000

    # Run quadrature oscillator
    result_re, result_im = qosc(coeff, accu, n_1)

    # Plot results
    plt.figure(figsize=(10, 5))
    plt.plot(result_re, label='Real Part')
    plt.plot(result_im, label='Imaginary Part')
    plt.xlabel('Iteration')
    plt.ylabel('Amplitude')
    plt.title('Quadrature Oscillator Output')
    plt.legend()
    plt.grid(True)
    plt.show()

# Run the test
test_qosc()

