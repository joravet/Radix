; Radix Project 
; Jackson Oravetz
include Irvine32.inc

.386
;.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
first_string db 'For radices greater than 10, lowercase letters represent 10-35 and uppercase represent 36-61', 10, 13, 0
input_string db 'Please enter an input radix from 2-62 (e.g. 8 = octal, 16 or h = hex, x to exit): ', 0
output_string db 10, 13, 'Please enter an output radix from 2-62 (e.g. 8 = octal, 16 or h = hex, x to exit): ', 0
numA_string db 10, 13, 'Enter the number A: ', 0
numB_string db 10, 13, 'Enter the number B: ', 0
input_radix dd ?
output_radix dd ?
numberA dd ?
numberB dd ?
most_neg_num dd -2147483648, 0
addition_string db 10, 13, 'A + B = ', 0
base_string db ' base ', 0
comma db ', ', 0
decimal_string db ' decimal', 10, 13, 0
subtraction_string db 'A - B = ', 0
multiplication_string db 'A * B = ', 0
division_string db 'A / B = ', 0
quotient db ' quotient, ', 0
remainder db ' remainder', 0
semi_colon db '; ', 0
power_string db 'A ^ B = ', 0
divide_by_zero_string db 'Divide by zero error!', 10, 13, 0
return db 10, 13, 0
invalid_string db 10, 13, 'Please enter a valid radix, bud', 10, 10, 13, 0
binary_string db ' binary', 0
octal_string db ' octal', 0
hex_string db ' hex', 0
invalid_string2 db 10, 13, 'Please enter a valid number, or you are going to go to invalid number jail', 10, 10, 13, 0
print_overflow db 'Answer larger than 32-bit!', 10, 13, 0
arithmatic_num dd 0
run_num dd 0

.code
    main proc
    reprompt:
    inc run_num
    mov arithmatic_num, 0
    lea edx, first_string
    call writestring
    lea edx, input_string
    call writestring
	call readint_works
    cmp eax, 7FFFFFFFh
    je repeat_radix
    cmp eax, 7FFFFFFDh
    je done
    cmp eax, 1
    jle invalid_radix
    cmp eax, 62
    jg invalid_radix
    mov input_radix, eax
    skip_input:
    lea edx, output_string
    call writestring
    call readint_works
    cmp eax, 7FFFFFFFh
    je repeat_radix2
    cmp eax, 7FFFFFFDh
    je done
    cmp eax, 1
    jle invalid_radix
    cmp eax, 62
    jg invalid_radix
    mov output_radix, eax
    skip_output:
    lea edx, numA_string
    call writestring
    call readint_all
    cmp eax, 7FFFFFFFh
    je invalid_num
    mov numberA, eax
    lea edx, numB_string
    call writestring
    call readint_all
    mov numberB, eax
    cmp eax, 7FFFFFFFh
    je invalid_num
    
    add eax, numberA
    jo too_large_num
    mov ecx, eax
    lea edx, addition_string
    call writestring
    call writeint_all
    cmp output_radix, 2
    jne next_add
    lea edx, binary_string
    call writestring
    jmp skip_base1
    next_add:
    cmp output_radix, 8
    jne next_add2
    lea edx, octal_string
    call writestring
    jmp skip_base1
    next_add2:
    cmp output_radix, 16
    jne next_add3
    lea edx, hex_string
    call writestring
    jmp skip_base1
    next_add3:
    lea edx, base_string
    call writestring
    mov eax, output_radix
    call writeint_plus
    skip_base1:
    lea edx, comma
    call writestring
    mov eax, ecx
    call writeint_plus
    lea edx, decimal_string
    call writestring
    inc arithmatic_num

    start_sub:
    mov eax, numberA
    sub eax, numberB
    jo too_large_num
    mov ecx, eax
    lea edx, subtraction_string
    call writestring
    call writeint_all
    cmp output_radix, 2
    jne next_sub
    lea edx, binary_string
    call writestring
    jmp skip_base2
    next_sub:
    cmp output_radix, 8
    jne next_sub2
    lea edx, octal_string
    call writestring
    jmp skip_base2
    next_sub2:
    cmp output_radix, 16
    jne next_sub3
    lea edx, hex_string
    call writestring
    jmp skip_base2
    next_sub3:
    lea edx, base_string
    call writestring
    mov eax, output_radix
    call writeint_plus
    skip_base2:
    lea edx, comma
    call writestring
    mov eax, ecx
    call writeint_plus
    lea edx, decimal_string
    call writestring
    inc arithmatic_num

    start_mul:
    xor edx, edx
    mov eax, numberA
    mul numberB
    cmp numberA, 0
    jl no_overflow
    cmp numberB, 0
    jl no_overflow
    jo too_large_num
    no_overflow:
    mov ecx, eax
    lea edx, multiplication_string
    call writestring
    call writeint_all
    cmp output_radix, 2
    jne next_mul
    lea edx, binary_string
    call writestring
    jmp skip_base3
    next_mul:
    cmp output_radix, 8
    jne next_mul2
    lea edx, octal_string
    call writestring
    jmp skip_base3
    next_mul2:
    cmp output_radix, 16
    jne next_mul3
    lea edx, hex_string
    call writestring
    jmp skip_base3
    next_mul3:
    lea edx, base_string
    call writestring
    mov eax, output_radix
    call writeint_plus
    skip_base3:
    lea edx, comma
    call writestring
    mov eax, ecx
    call writeint_plus
    lea edx, decimal_string
    call writestring
    inc arithmatic_num

    start_div:
    xor edx, edx
    mov eax, numberA
    cdq
    mov ebx, numberB
    cmp ebx, 0
    je divide_by_zero
    idiv ebx
    mov ebx, edx
    mov ecx, eax
    lea edx, division_string
    call writestring
    call writeint_all
    lea edx, quotient
    call writestring
    mov eax, ebx
    call writeint_all
    lea edx, remainder
    call writestring
    cmp output_radix, 2
    jne next_div
    lea edx, binary_string
    call writestring
    jmp skip_base4
    next_div:
    cmp output_radix, 8
    jne next_div2
    lea edx, octal_string
    call writestring
    jmp skip_base4
    next_div2:
    cmp output_radix, 16
    jne next_div3
    lea edx, hex_string
    call writestring
    jmp skip_base4
    next_div3:
    lea edx, base_string
    call writestring
    mov eax, output_radix
    call writeint_plus
    skip_base4:
    lea edx, semi_colon
    call writestring
    mov eax, ecx
    call writeint_plus
    lea edx, quotient
    call writestring
    mov eax, ebx
    call writeint_plus
    lea edx, remainder
    call writestring
    lea edx, decimal_string
    call writestring
    inc arithmatic_num
    jmp power_loop

    divide_by_zero:
    lea edx, divide_by_zero_string
    call writestring
    inc arithmatic_num
    jmp power_loop

    power_loop:
    xor edx, edx
    mov eax, numberA
    mov ecx, numberB
    mov ebx, numberA
    cmp ecx, 0
    jl negate
    back_to_loop:
    cmp ecx, 0
    je zero_pow
    cmp ecx, 1
    je cont
    cmp ecx, 1
    jg mult_pow
    zero_pow:
    mov eax, 1
    jmp cont

    negate:
    neg ecx
    jmp back_to_loop
    
    mult_pow:
    cmp eax, 0
    jl neg_A
    mul ebx
    jo too_large_num
    skip_overflow:
    dec ecx
    cmp ecx, 1
    je cont
    jmp mult_pow

    neg_A:
    mul ebx
    dec ecx
    cmp ecx, 1
    je cont
    jmp neg_A
    
    cont:
    mov ecx, eax
    lea edx, power_string
    call writestring
    call writeint_all
    cmp output_radix, 2
    jne next_pow
    lea edx, binary_string
    call writestring
    jmp skip_base5
    next_pow:
    cmp output_radix, 8
    jne next_pow2
    lea edx, octal_string
    call writestring
    jmp skip_base5
    next_pow2:
    cmp output_radix, 16
    jne next_pow3
    lea edx, hex_string
    call writestring
    jmp skip_base5
    next_pow3:
    lea edx, base_string
    call writestring
    mov eax, output_radix
    call writeint_plus
    skip_base5:
    lea edx, comma
    call writestring
    mov eax, ecx
    call writeint_plus
    lea edx, decimal_string
    call writestring
    lea edx, return
    call writestring
    jmp reprompt

    too_large_num:
    mov ecx, arithmatic_num
    cmp ecx, 0
    jg next_large
    lea edx, addition_string
    call writestring
    lea edx, print_overflow
    call writestring
    inc arithmatic_num
    jmp start_sub
    next_large:
    cmp ecx, 1
    jg next_large2
    lea edx, subtraction_string
    call writestring
    lea edx, print_overflow
    call writestring
    inc arithmatic_num
    jmp start_mul
    next_large2:
    cmp ecx, 2
    jg next_large3
    lea edx, multiplication_string
    call writestring
    lea edx, print_overflow
    call writestring
    inc arithmatic_num
    jmp start_div
    next_large3:
    lea edx, power_string
    call writestring
    lea edx, print_overflow
    call writestring
    lea edx, return
    call writestring
    jmp reprompt
    
    invalid_radix:
    lea edx, invalid_string
    call writestring
    jmp reprompt

    invalid_num:
    lea edx, invalid_string2
    call writestring
    jmp reprompt

    repeat_radix:
    cmp run_num, 2
    jl invalid_radix
    jmp skip_input

    repeat_radix2:
    cmp run_num, 2
    jl invalid_radix
    jmp skip_output

    done:
	invoke ExitProcess,0
main endp

writeint_all proc
.data
most_neg dd -2147483648, 0
og_num dd 0
first_run db 0

.code
push si
push cx
push ebx
push edx
push ax
xor si, si
xor cx, cx
mov ebx, output_radix
mov first_run, 0
mov og_num, eax
cmp eax, 080000000h
jnz continue
mov edx, offset most_neg
call writestring
jmp Proc_done

continue:
cmp ebx, 2
je twos_comp_binary
cmp ebx, 16
je twos_comp_hex
cmp eax, 0
jge greater
mov dl, '-'
xor dh, dh
mov si, dx
neg eax

greater:
xor edx, edx
div ebx
cmp dx, 9
jle num_convert
cmp dx, 36
jl letter_convert2
cmp dx, 36
jge letter_convert
num_convert:
push dx
inc cx
cmp ax, 0
je pop_digs
cwd 
jmp greater

letter_convert:
add dx, 29
push dx
inc cx
cmp ax, 0
je pop_digs
cwd
jmp greater

letter_convert2:
cmp dx, 31
jg change_byte
or dx, 060h
sub dx, 09h
jmp move_on
change_byte:
or dx, 060h
add dx, 23
move_on:
push dx
inc cx
cmp ax, 0
je pop_digs
cwd
jmp greater

pop_digs: 
mov ax, si
call writechar
next_digit: pop ax
cmp al, 9
jg alt_pop_digs
or al, 030h
call writechar
dec cx
jz Proc_done
jmp next_digit

alt_pop_digs:
call writechar
dec cx
jz Proc_done
jmp next_digit

twos_comp_binary:
xor si, si
cmp eax, 0
jge greater2
mov dl, 031h
xor dh, dh
mov si, dx
and al, 01h
cmp al, 0h
je revert_num
mov eax, og_num
neg eax
jmp greater_neg

revert_num:
mov eax, og_num
jmp greater_neg

greater2:
mov dl, 030h
xor dh, dh
mov si, dx
greater_neg:
xor edx, edx
div ebx
push dx
inc cx
cmp ax, 0
je check_odd
cwd 
jmp greater_neg

check_odd:
mov eax, og_num
and al, 01h
cmp al, 0h
je pop_digs_binary_even
jmp pop_digs_binary_odd

pop_digs_binary_odd:
xor eax, eax
mov ax, si
call writechar
pop_digs_binary_odd2:
pop ax
or al, 030h
cmp si, 030h
je pencil_char
cmp cx, 1
je pencil_char
cmp al, 030h
je flip_zero_to_one
cmp al, 031h
je flip_one_to_zero
pencil_char:
call writechar
dec cx
jz Proc_done
jmp pop_digs_binary_odd2

flip_one_to_zero:
mov al, 030h
jmp pencil_char
flip_zero_to_one:
mov al, 031h
jmp pencil_char

pop_digs_binary_even:
mov ax, si
call writechar
pop_digs_binary_even2:
pop ax
or al, 030h
call writechar
inc first_run
dec cx
jz Proc_done
jmp pop_digs_binary_even2

twos_comp_hex:
mov esi, eax
cmp eax, 0
jl no_leading_zero
mov al, 030h
call writechar
no_leading_zero:
mov eax, esi
xor esi, esi
jmp greater

Proc_done:
pop ax
pop edx
pop ebx
pop cx
pop si
RET
writeint_all ENDP

writeint_plus proc
.data
most_neg2 dd -2147483648, 0

.code
push si
push cx
push ebx
push edx
push ax
xor si, si
xor cx, cx
mov ebx, 0AH
cmp eax, 080000000h
jnz continue2
mov edx, offset most_neg
call writestring
jmp Proc_done2

continue2: cmp eax, 0
jge greater2
mov dl, '-'
xor dh, dh
mov si, dx
neg eax

greater2:
xor edx, edx
div ebx
push dx
inc cx
cmp ax, 0
je pop_digs2
cwd 
jmp greater2

pop_digs2: mov ax, si
call writechar
next_digit2: pop ax
or al, 030h
call writechar
dec cx
jz Proc_done2
jmp next_digit2

Proc_done2:
pop ax
pop edx
pop ebx
pop cx
pop si
RET
writeint_plus ENDP

readint_works proc
.data
    is_neg db 0
    input_num db 0
    temp db 0

.code
    push edx
    push ecx
    push ebx
    xor ebx, ebx
    xor edx, edx
    mov ecx, 0AH
    mov input_num, 0
    mov temp, 0
    mov is_neg, 0

get_digits:
    call readchar
    cmp al, '-'
    jne continue_with_digits
    mov is_neg, 1
    call writechar

get_next_char:
    call readchar

continue_with_digits:
    cmp input_num, 0
    je first_input
    back:
    inc input_num
    cmp al, 30H
    jl done_with_digit_entry
    cmp al, 48h
    je hex_input
    cmp al, 68h
    je hex_input
    cmp al, 39H
    jg done_with_digit_entry
    call writechar
    and al, 0FH
    cbw
    cwde
    xchg ebx, eax  ;ebx has last input digit, eax has running number
    mul ecx
    add ebx, eax
    jmp get_next_char

    hex_input:
    call writechar
    mov eax, 16
    jmp done_for_good

    first_input:
    mov temp, al
    cmp temp, 13
    je carriage_return
    or temp, 020h
    cmp temp, 078h
    je end_program
    cmp al, 030h
    jl invalid_input
    cmp al, 048h
    je back
    cmp al, 068h
    je back
    cmp al, 039h
    jg invalid_input
    jmp back

    invalid_input:
    call writechar
    mov eax, 0
    jmp done_for_good

    end_program:
    call writechar
    mov eax, 7FFFFFFDh
    jmp done_for_good

    carriage_return:
    mov eax, 7FFFFFFFh
    jmp done_for_good

done_with_digit_entry:
    mov    eax, ebx
    cmp is_neg, 1
    jne  done_for_good
    neg    eax
    done_for_good:
    pop    ebx
    pop    ecx
    pop    edx
    ret
    readint_works    ENDP

    readint_all proc
.data
    is_neg2 db 0
    input_number db 0
    num_pop db 0
    radix_neg dd 0

.code
    push edx
    push ecx
    push ebx
    xor ebx, ebx
    xor edx, edx
    mov is_neg2, 0
    mov input_number, 0
    mov ecx, input_radix
    mov num_pop, 0

get_digits2:
    call readchar
    cmp al, '-'
    jne continue_with_digits_two
    mov is_neg2, 1
    call writechar

get_next_char2:
    call readchar

continue_with_digits_two:
    cmp input_number, 0
    je first_in
    back_here:
    inc input_number
    cmp al, 30H
    jl done_with_digit_entry2
    cmp al, 39H
    jle continue_with_digits3
    cmp al, 041H
    jl done_with_digit_entry2
    cmp al, 05AH
    jle continue_with_letters
    cmp al, 061h
    jl done_with_digit_entry2
    cmp al, 07AH
    jle continue_with_letters2
    cmp al, 07AH
    jg done_with_digit_entry2

    continue_with_digits3:
    call writechar
    and al, 0FH
    cbw
    cwde
    cmp eax, input_radix
    jge go_to_jail
    xchg ebx, eax  ;ebx has last input digit, eax has running number
    mul ecx
    add ebx, eax
    cmp num_pop, 0
    je first_run_num
    jmp get_next_char2

    first_in:
    cmp al, 030h
    jl go_to_jail
    cmp al, 039h
    jle back_here
    cmp al, 041h
    jl go_to_jail
    cmp al, 05Ah
    jle back_here
    cmp al, 061h
    jl go_to_jail
    cmp al, 07Ah
    jle back_here
    jmp go_to_jail

continue_with_letters:
    call writechar
    cmp al, 50h
    jge resets_byte
    and al, 0Fh
    add al, 023h
    jmp convert
    resets_byte:
    and al, 0Fh
    add al, 033h
    convert:
    cbw
    cwde
    cmp eax, input_radix
    jge go_to_jail
    xchg ebx, eax
    mul ecx
    add ebx, eax
    cmp num_pop, 0
    je first_run_letter
    jmp get_next_char2

continue_with_letters2:
    call writechar
    cmp al, 70h
    jge resets_byte2
    and al, 0Fh
    add al, 09h
    jmp convert2
    resets_byte2:
    and al, 0Fh
    add al, 019h
    convert2:
    cbw
    cwde
    cmp eax, input_radix
    jge go_to_jail
    xchg ebx, eax
    mul ecx
    add ebx, eax
    cmp num_pop, 0
    je first_run_letter
    jmp get_next_char2
    
first_run_num:
    inc num_pop
    cmp ecx, 2
    je flip_sign_num_b
    cmp ecx, 16
    je flip_sign_letter
    jmp get_next_char2

first_run_letter:
    inc num_pop
    cmp ecx, 16
    je flip_sign_letter
    jmp get_next_char2

flip_sign_letter:
    cmp ebx, 8
    jl get_next_char2
    sub ebx, 16
    jmp get_next_char2
flip_sign_num_b:
    neg ebx
    jmp get_next_char2

go_to_jail:
    mov eax, 7FFFFFFFh
    jmp done_for_good2

done_with_digit_entry2:
    mov    eax, ebx
    cmp is_neg2, 1
    jne  done_for_good2
    neg    eax
    done_for_good2:
    pop    ebx
    pop    ecx
    pop    edx
    ret
    readint_all    ENDP

end main