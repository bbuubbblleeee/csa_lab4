%define INPUT_ADDR 2045
%define OUTPUT_ADDR_SYMB 2046
%define END_OF_INPUT 0

.text
.org 0x000
trap_vector:
    jmp process_trap

_start:
useless:
    jmp useless

process_trap:
    push_m INPUT_ADDR
    dup
    push END_OF_INPUT
    cmp
    jz print_char      ; если stack.top == 0 (символ != END_OF_INPUT) -> прыгаем на печать

    halt

print_char:
    pop_m OUTPUT_ADDR_SYMB
    iret