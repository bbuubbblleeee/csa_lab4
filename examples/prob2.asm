%define OUTPUT_ADDR_DEC 2047
%define N 100

.data
cur:    .num 1
sum:    .num 0
sum_sq: .num 0

.text
_start:
loop:
    push_m cur
    push N
    gt
    jnz done

    push_m sum
    push_m cur
    add
    pop_m sum

    push_m cur
    dup
    mul
    push_m sum_sq
    add
    pop_m sum_sq

    push_m cur
    push 1
    add
    pop_m cur
    jmp loop

done:
    push_m sum
    dup
    mul

    push_m sum_sq
    sub

    pop_m OUTPUT_ADDR_DEC

    halt
