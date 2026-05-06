%define OUTPUT_ADDR_SYMB 2046
%define OUTPUT_ADDR_DEC 2047

.data
len: .num 6
array:     .num 42
         .num 15
         .num 8
         .num 100
         .num 4
         .num 23

i: .num 0
j:    .num 0
a:    .num 0   ; array[j]
b:    .num 0   ; array[j+1]

.text
_start:
    push_m len
    pop_m i

outer:
    push_m i
    jz print_loop

    push 0
    pop_m j

inner:
    push_m j
    push_m i
    push 1
    sub
    lt
    jz end_inner

    push array
    push_m j
    add
    push_ind
    pop_m a

    push array
    push_m j
    push 1
    add
    add
    push_ind
    pop_m b

    ; если a <= b, свап не нужен
    push_m a
    push_m b
    gt
    jz no_swap

    ; свап: array[j] = b
    push array
    push_m j
    add
    push_m b
    pop_ind

    ; свап: array[j+1] = a
    push array
    push_m j
    push 1
    add
    add
    push_m a
    pop_ind

no_swap:
    push_m j
    push 1
    add
    pop_m j
    jmp inner

end_inner:
    push_m i
    push 1
    sub
    pop_m i
    jmp outer


print_loop:
    push_m i
    push_m len
    lt
    jz end

    push OUTPUT_ADDR_DEC
    push array
    push_m i
    add
    push_ind
    pop_ind             ; выводим array[i]

    push OUTPUT_ADDR_SYMB
    push 32
    pop_ind

    push_m i
    push 1
    add
    pop_m i
    jmp print_loop

end:
    halt
