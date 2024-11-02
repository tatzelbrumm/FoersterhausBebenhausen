#!/bin/bash
iverilog -o quadrature_oscillator_test quadrature_oscillator_sync.v quadrature_oscillator_sync_tb.v
./quadrature_oscillator_test | tee quadrature_oscillator_test.csv
