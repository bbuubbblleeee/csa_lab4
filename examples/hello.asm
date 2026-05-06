%define OUTPUT_ADDR_SYMB 2046

.data
message: .pstr "Hello, World!"

len:       .num 0
ptr:       .num 0

.text
_start:
    push_m message
    pop_m len

    push message
    push 1
    add
    pop_m ptr

loop:
    push_m len
    jz end

    push OUTPUT_ADDR_SYMB
    push_m ptr
    push_ind
    pop_ind

    push_m ptr
    push 1
    add
    pop_m ptr

    push_m len
    push 1
    sub
    pop_m len

    jmp loop

end:
    halt