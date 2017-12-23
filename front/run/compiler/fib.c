//int tt(int a) {
//    return a;
//}
//
//int ff(int a) {
//    return a;
//}
//
//int ee(int a, int b) {
//    return a;
//}
//
//int test(int a, int b, int c, int d, int e, int f, int g, int h, int i) {
//    return test(tt(a), tt(b), ee(b + b, ff(c)), d + d, e, f, g, h, i) + test(a, b, c, d, e, f, g, h, i);
//}


int vKeyboard;  // value of keyboard in
int vSwitch;    // vSwitch[0] == 1: keyboard in is ignored,
// i.e., vSwitch[0] == 0 means input, vSwitch[0] == 1 means output
int update;

/* fib seq
 * n: ...
 */

int fib(int n) {
    if (n <= 1) return n == 1;
//    n = n + n + (n + n + (n + n + (n + n + (n + n + (n + n + (n + n + (n + n + (n + n + (n + n)))))))));
//    n = 1;
//    n = (n - n) || (n - n) && (n - n) | (n - n) & (n - n) == (n - n) << (n - n) + (n - n) * (n - n);
    return fib(n - 1) + fib(n - 2);
}


void quickSort(int arr[10], int left, int right) {
    int i;
    int j;
    int tmp;
    int pivot;

    i = left;
    j = right;
    pivot = arr[(left + right) / 2];
    /* partition */
    while (i <= j) {
        while (arr[i] < pivot) i = i + 1;
        while (arr[j] > pivot) j = j - 1;
        if (i <= j) {
            tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
            i = i + 1;
            j = j - 1;
        }
    }
    /* recursion */
    if (left < j)
        quickSort(arr, left, j);
    if (i < right)
        quickSort(arr, i, right);

}


void interruptServer0(void) {
    if (!(vSwitch & 0x2)) {
        vKeyboard = (vKeyboard << 4) + $0xfffffc10;
        update = 1;
    }
}


void interruptServer1(void) {
    int old;
    old = vSwitch;
    vSwitch = $0xfffffc70;
    update = (old ^ vSwitch) & 0x7;
    $0xfffffc60 = vSwitch;
}

void delay(void) {
    int a;
    a = 0xfffff;
    while (a != 0) {
        a = a - 1;
    }
}

int main(void) {
    int arr[5];
    int b;
//    arr[0] = 5;
    arr[1] = 0x20;
    arr[2] = 0x30;
    arr[3] = 0x40;
    arr[4] = 0x10;
//    quickSort(arr, 0, 4);
    update = 1;
    vSwitch = $0xfffffc70;
    vKeyboard = 0;

    while (1) {
        if (update) {
            if (update & 0x4) {
                $0xfffffc00 = 0;
                vKeyboard = 0;
                update = 0;
                continue;
            }
            if (vSwitch & 0x2) {
                if (vSwitch & 0x1) {
                    $0xfffffc00 = fib(vKeyboard);
                } else {
                    arr[0] = vKeyboard;
                    quickSort(arr, 0, 4);
                    b = 0;
                    while (b < 5) {
                        $0xfffffc00 = arr[b];
                        delay();
                        b = b + 1;
                    }
                }
                vKeyboard = 0;
            } else {
                $0xfffffc00 = vKeyboard;
            }
            update = 0;
        }
    }
    return 0;
}