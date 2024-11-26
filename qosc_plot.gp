# qosc_plot.gp - Gnuplot script
set title "Quadrature Oscillator Output"
set xlabel "Iteration"
set ylabel "Amplitude"
set grid
plot "qosc_output.dat" using 1:2 with lines title "Real Part", \
     "qosc_output.dat" using 1:3 with lines title "Imaginary Part"

