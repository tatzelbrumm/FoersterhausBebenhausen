import numpy as np
import math
import matplotlib.pyplot as plt

def qosc_iteration(coeff, accu):
    # Extract coefficients
    power = coeff[0]
    re_coeff = coeff[1]
    im_coeff = coeff[2]

    # Compute the next accumulator values using the coefficients
    temp_re = int(accu[0]) * re_coeff - int(accu[1]) * im_coeff
    temp_im = int(accu[0]) * im_coeff + int(accu[1]) * re_coeff

    tmph_re = temp_re >> 15 & 0xFFFF
    tmph_im = temp_im >> 15 & 0xFFFF

    # Compute the square and subtract operation
    ac3 = power << 16  # Load target power into AC3
    ac3 -= tmph_re * tmph_re  # Subtract the square of the real part
    ac3 -= tmph_im * tmph_im  # Subtract the square of the imaginary part

    # Extract high part of AC3 and use it to scale results
    t0 = (ac3 >> 16) & 0xFFFF
    temp_re += tmph_re * t0
    temp_im += tmph_im * t0

    # Update the accumulator with the new values
    accu[0] = temp_re >> 15
    accu[1] = temp_im >> 15

def qosc(coeff, accu, n_1):
    # Prepare storage for results
    result_re = []
    result_im = []

    # Loop through the iterations
    for i in range(n_1 + 1):
        # Store the current accumulator values in the result arrays
        result_re.append(accu[0])
        result_im.append(accu[1])

        # Perform one iteration
        qosc_iteration(coeff, accu)

    return result_re, result_im

# Test environment
def test_qosc():
    # Set coefficients for a 12-degree rotation
    angle_rad = math.radians(12)
    re_coeff = int(math.cos(angle_rad) * (1 << 15))  # Q15 format
    im_coeff = int(math.sin(angle_rad) * (1 << 15))  # Q15 format
    power = 1024  # Adjusted power to match initial magnitude of accumulator

    # Test coefficients {power, re_coeff, im_coeff}
    coeff = [power, re_coeff, im_coeff]
    # Initial accumulator values {real, imaginary}, matching the target power
    accu = [ 1024, 0]
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

