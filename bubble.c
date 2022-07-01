#include <stdio.h>

int main() {
	printf("bubble.c\n\n");
	
	int arr[50], n;
	
	printf("liczby: ");

	int i;
    for(i = 0; i < 5; i++){
    	scanf("%d", &arr[i]);
	}
	
	int j;
	int temp;
	for(i = 0; i < 5; i++) 
		for(j = 0; j < 5; j++) 
			if(arr[j] > arr[j + 1]) {
				temp = *(&arr[j]);
				*(&arr[j]) = *(&arr[j + 1]);
				*(&arr[j + 1]) = temp;
			}		
	
	printf("posortowane: ");
			
	for (i = 0; i < 5; i++)
        printf("%d ", arr[i]);
	
	return 0;
}
