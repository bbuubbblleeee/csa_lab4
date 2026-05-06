%define OUTPUT_ADDR_SYMB 2046
%define OUTPUT_ADDR_DEC 2047
%define DEBUG_MODE 1
; %define EXCL 1

.data
array:     .num 10
         .num 20
         .num 30
         .num 40
         .num 50
len: .num 5
sum:     .num 0
i:       .num 0

.text
_start:
loop:
    push_m i
    push_m len
    lt
    jz print_sum

%ifdef DEBUG_MODE
    push OUTPUT_ADDR_DEC
    push array
    push_m i
    add
    push_ind
    pop_ind

    ; если i - последний элемент, то выводим "=", иначе "+"
    push_m i
    push_m len
    push 1
    sub
    cmp
    call print_space
    jnz print_equals

    push OUTPUT_ADDR_SYMB
    push 43
    pop_ind
    call print_space

    jmp after_sep

print_space:
    push OUTPUT_ADDR_SYMB
    push 32
    pop_ind
    ret

print_equals:
    push OUTPUT_ADDR_SYMB
    push 61
    pop_ind
    call print_space

after_sep:
%endif

    push_m sum
    push array
    push_m i
    add
    push_ind
    add
    pop_m sum

    push_m i
    push 1
    add
    pop_m i
    jmp loop

print_sum:
    push OUTPUT_ADDR_DEC
    push_m sum
    pop_ind
%ifdef EXCL
    push OUTPUT_ADDR_SYMB
    push 33
    pop_ind
%endif
    halt
