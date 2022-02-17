/*  A standard insertion-sort for an integer array
 */
void isort(int a[], int asize) {
    int j, tmp;
    for (int i = 1; i < asize; i++) {
        j = i;
        tmp = a[i];
        while ((j > 0) && (a[j-1] > tmp)) {
            a[j] = a[j-1];
            j--;
        }
        a[j] = tmp;
    }
}

/*  The same, done with pointers and pointer arithmetic
 */
void isortptr(int *a, int asize) {
    int *p = a;
    int *q;
    int  tmp;
    for (++p;  p < a+asize; p++) {
        q = p;
        tmp = *p;
        while ((q > a) && (*(q-1) > tmp)) {
	    *q = *(q-1);
            q--;
        }
        *q = tmp;
    }
}
