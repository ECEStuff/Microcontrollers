#include <P18F4321.h>

unsigned int result; //initialize variable

void main() 
{
	TRISC = 0; //PORTC is output (integer part)
	TRISD = 0; //PORTD is output (fractional part)
	ADCON0 = 0x01; //configure ADC registers
	ADCON1 = 0; //
	ADCON2 = 0x08; //
	ADCON0bits.GO = 1; //start ADC
	while (ADCON0bits.DONE == 1); //wait for conversion
	result = ADRESH;
	PORTC = result/51; //integer
	PORTD = (result % 51)/5; 
	ADCON0bits.GO = 1;
}