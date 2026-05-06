%define INPUT_ADDR 2045
%define OUTPUT_ADDR_SYMB 2046
.text
.org 0x000
trap_vector:
    jmp process_trap

.data
question: .pstr "What is your name? "
hello_str:  .pstr "Hello, "
end_str:   .pstr "!"

name_len:   .num 0
input_done: .num 0
current_symb:  .num 0
str_ptr:  .num 0
str_len:  .num 0
name:   .num 0

.text
.org 0x150
process_trap:
    push_m INPUT_ADDR
    pop_m current_symb

    ; завершаем ввод на \n или на \0
    push_m current_symb
    push 10
    sub
    jz trap_end

    push_m current_symb
    push 0
    sub
    jz trap_end

    push name
    push_m name_len
    add
    push_m current_symb
    pop_ind

    push_m name_len
    push 1
    add
    pop_m name_len
    iret

trap_end:
    push 1
    pop_m input_done
    iret


_start:
    push question
    call print_str

wait_input:
    push_m input_done
    jz wait_input

    push hello_str
    call print_str

    push name
    push_m name_len
    call print_raw_str

    push end_str
    call print_str

    halt


print_str:
    pop_m str_ptr

    push_m str_ptr
    push_ind
    pop_m str_len

print_str_loop:
    push_m str_len
    jz print_end

    push_m str_ptr
    push 1
    add
    pop_m str_ptr

    push OUTPUT_ADDR_SYMB
    push_m str_ptr
    push_ind
    pop_ind

    push_m str_len
    push 1
    sub
    pop_m str_len

    jmp print_str_loop


; печатает массив символов без длины в начале строки (принимает ptr и len со стека)
print_raw_str:
    pop_m str_len
    pop_m str_ptr

    push_m str_ptr
    push 1
    sub
    pop_m str_ptr
    jmp print_str_loop

print_end:
    ret