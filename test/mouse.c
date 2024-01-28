extern int get_hid_mouse_state();
#include <stdio.h>

main() {
    int pos;
    while (1) {
        pos = get_hid_mouse_state();
        printf("%d",pos);
    }
}

