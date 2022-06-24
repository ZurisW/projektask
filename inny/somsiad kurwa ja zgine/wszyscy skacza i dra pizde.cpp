#include <stdio.h>

int main()
{
	
	printf("limit = ");
    int l; // given limit
   	scanf("%d", &l);
   	
    int a, b, c = 0; 
    int p = 2;
    while (c <= l) {
        for (int q = 1; q < p; ++q) {
            a = p * p - q * q;
            b = 2 * p * q;
            c = p * p + q * q;
            if (c >= l)
                break;
 
            printf("%d %d %d\n", a, b, c);
        }
        p++;
    }
    return 0;
}
