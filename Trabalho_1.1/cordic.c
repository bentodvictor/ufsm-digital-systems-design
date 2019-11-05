#include <stdio.h>
#include <math.h>

#define TO_RADIANS(x) (x * (M_PI/180.0))    /* 1 radian = 180/π degrees */
#define TO_DEGREES(x) ((x*180.0)/M_PI)
#define TOTAL_ANGLES    16

/*** Calcutales sin/cos of an angle 
		angle: angle in degrees [0:90]
		it: number of iteractions [0:32]
		sin: calculated sin(angle) scaled by a factor of 2^24
		cos: calculated cos(angle) scaled by a factor of 2^24		
***/
void cordic32(int angle, int it, int *sin, int *cos){

    int anglesTable[32];
    int sumAngle, x_new, y_new, x, y;
    int i;

    /* Fills the angles tables with angles which Tangent is power of 2 */
	for(i=0;i<32;i++) {
        anglesTable[i] = (TO_DEGREES(atan(pow(2, -i)))*(1<<24)); /* The angles are stored scaled by a factor of 2^24 */
        //printf("Stored angle: %f * factor = %X\n", TO_DEGREES(atan(pow(2, -i))),anglesTable[i]);
    }
    
    angle <<= 24; 	// Applies the scale factor
    sumAngle = 0;
    y = 0;   
    x = 0x9B74ED;   // CORDIC gain (0.6072529350088812561694) scaled by the factor of 2^24

    for(i=0; i<it; i++) {
        if (angle > sumAngle) {
            x_new = x - (y>>i);
            y_new = y + (x>>i);
            sumAngle = sumAngle + anglesTable[i];
        }
        else {
            x_new = x + (y>>i);
            y_new = y - (x>>i);
            sumAngle = sumAngle - anglesTable[i]; 
        }    

        x = x_new;
        y = y_new;
    }

    *cos = x;
    *sin = y;
}


int main() {  
    
    int angle;
    int sin, cos;
	int it;

    for(angle=0; angle<=90; angle++) {
        printf("(math.h) sin(%d): %f\t\tcos(%d): %f\n", angle, sinf(TO_RADIANS(angle)), angle, cosf(TO_RADIANS(angle)));       
        
        cordic32(angle, 32, &sin, &cos);
        printf("(cordic) sin(%d): %f (%X)\tcos(%d): %f (%X)\n", angle, sin/(float)(1<<24), sin, angle, cos/(float)(1<<24),cos);

        printf("\n");
    }	

    return 0;
}
