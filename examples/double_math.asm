%define OUTPUT_ADDR_SYMB 2046
%define OUTPUT_ADDR_DEC 2047

.data
.org 0x020
message_add: .pstr "4294967295 + 2 = "
message_sub: .pstr "4294967297 - 2 = "
message_mul: .pstr "100000 * 100000 = "
sep:     .pstr " "

; a = 4294967295 = 0xFFFFFFFF -> a_hi = 0, a_lo = -1
; b = 2 = 0x2 -> b_hi = 0, b_lo = 2
; expected = 4294967297 = 0x100000001 -> hi = 1, lo = 1
a_hi: .num 0
a_lo: .num -1
b_hi: .num 0
b_lo: .num 2

; c = 4294967297 = 0x100000001 -> c_hi = 1, c_lo = 1
; d = 2 = 0x2 -> d_hi = 0, d_lo = 2
; expected = 4294967295 = 0xFFFFFFFF -> hi = 0, lo = -1
c_hi: .num 1
c_lo: .num 1
d_hi: .num 0
d_lo: .num 2

; e = f = 100000
; expected = 10000000000 -> hi = 2, lo = 1410065408
e: .num 100000
f: .num 100000

res_hi:    .num 0
res_lo:    .num 0
print_ptr: .num 0
pstr_len:  .num 0

.text
.org 150
_start:
    ; сложение
    push message_add
    call print_pstr

    push_m a_lo
    push_m b_lo
    add
    pop_m res_lo

    push_m a_hi
    push_m b_hi
    adc
    pop_m res_hi

    call print_result

    ; вычитание
    push message_sub
    call print_pstr

    push_m c_lo
    push_m d_lo
    sub
    pop_m res_lo

    push_m c_hi
    push_m d_hi
    sbc
    pop_m res_hi

    call print_result

    ; умножение
    push message_mul
    call print_pstr

    push_m e
    push_m f
    mul
    pop_m res_lo

    push_m e
    push_m f
    mulh
    pop_m res_hi

    call print_result

    halt


print_result:
    push OUTPUT_ADDR_DEC
    push_m res_hi
    pop_ind

    push sep
    call print_pstr

    push OUTPUT_ADDR_DEC
    push_m res_lo
    pop_ind

    push sep
    call print_pstr
    ret

print_pstr:
    pop_m print_ptr

    push_m print_ptr
    push_ind
    pop_m pstr_len

print_pstr_loop:
    push_m pstr_len
    jz print_pstr_end

    push_m print_ptr
    push 1
    add
    pop_m print_ptr

    push OUTPUT_ADDR_SYMB
    push_m print_ptr
    push_ind
    pop_ind

    push_m pstr_len
    push 1
    sub
    pop_m pstr_len
    jmp print_pstr_loop

print_pstr_end:
    ret
