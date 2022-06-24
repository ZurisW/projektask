#include <stdio.h>

int main() {
	printf("bubble.c\n\n");
	
	int arr[50], n;
	
	printf("Podaj liczbe elementow w tablicy: ");
	
	scanf("%d", &n); 

	int i;
    for(i = 0; i < n; i++){
    	printf("Podaj wartosc: ");
    	scanf("%d", &arr[i]);
	}
        
	
	for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
        
	printf("\n");
	
	int j;
	int temp;
	for(i = 0; i < n; i++) 
		for(j = 0; j < n; j++) 
			if(arr[j] > arr[j + 1]) {
				temp = *(&arr[j]);
				*(&arr[j]) = *(&arr[j + 1]);
				*(&arr[j + 1]) = temp;
			}		
			
	for (i = 0; i < n; i++)
        printf("%d ", arr[i]);
	
	return 0;
}
