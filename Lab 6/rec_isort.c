#include <stdio.h>

void recursiveInsert(int *first, int *last)
{

	//base case
	if (first >= last){
		//an empty array is a sorted array!
		// a singleton array is a sorted array!
		return;
	}

	else {
		recursiveInsert(first,last-1);  //sort the shorter list
		int tmp = *last;
		int *cur = last;
		while ((cur > first) && (*(cur-1) > tmp))
		{
			*cur = *(cur - 1);
			cur--;
		}
		*cur = tmp;
		return;
	}
}

int main()
{
	int A[10] = {3,1,4,1,5,9,2,6,5,4};
	recursiveInsert(A,A+9);
	for (int i = 0; i < 10; i++)
	{
		printf("%d ",A[i]);
	}
	printf("\n");
}

