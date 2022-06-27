#include <iostream>

int main()
{
    printf("limit = ");
    int limit; // given limit
   	scanf("%d", &limit);
	limit += 1;

    int cnt = 0 ;

    // Use a triple-nested loop that tries all possibilities (brute force).
    // let a, b, c be the three sides such that a<b and a*a + b*b == c*c
    for( int a = 1 ; a < limit ; ++a )
    {
        const int aa = a*a ;

        for( int b = a+1 ; b < limit ; ++b ) // for b > a
        {
            const int bb = b*b ;
            const int sum = aa + bb ; // sum of squares of the two smaller sides

            for( int c = b+1 ; c < limit ; ++c ) // c must be greater than b
            {
                const int cc = c*c ; // square of the largest side

                if( sum == cc ) // found a pythagorean triplet, print it
                {
                    std::cout << ++cnt << ". ( " << a << ", " << b << ", " << c << " )\n" ;
                }

                if( cc >= sum ) break ; // no point in checking for higher values of c
            }
        }
    }
}
