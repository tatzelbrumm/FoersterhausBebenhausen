/* test amplitude stability of quadrature oscillator */

#include "qosc.h55"
#include "sinesat.h55"

#define SAMPLES 64
#define PACKETS 64

qOscCoeff coeff=
{
  0x6000,		// target power
  0, 32767,		// rotation
};

short dphase;	// phase difference

short accu[2];	// oscillator internal states

short waves[2][SAMPLES];
short *waves_v[2]= {waves[0], waves[1]};


main()
{
  unsigned short p;

  while (1)
  {
    asm(" nop");
    cossat(&dphase, &coeff.re, 1);
    sinesat(&dphase, &coeff.im, 1);
    asm(" nop");
    for (p=0; p<PACKETS; p++)
    {
      asm(" nop");
      qosc(&coeff, accu, SAMPLES-1, waves_v);
      asm(" nop");
    }
    asm(" nop");
  }
}

