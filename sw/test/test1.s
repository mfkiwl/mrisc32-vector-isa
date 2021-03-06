; -*- mode: mr32asm; tab-width: 4; indent-tabs-mode: nil; -*-
; This is a test program.

    .include    "mrisc32-macros.inc"

; -------------------------------------------------------------------------------------------------
; Main program.
; -------------------------------------------------------------------------------------------------

    .text
    .p2align 2

selftest_result_fun:
    ldi     s3, #33
    and     s4, s1, #9
    add     s1, s3, s4      ; s1 = "*" for pass, "!" for fail
    b       _putc


    .globl  main
main:
    push_all_scalar_callee_saved_regs

    ; Start by running the self tests.
    ldea    s1, pc, #selftest_msg@pc
    bl      _puts
    ldea    s1, pc, #selftest_result_fun@pc
    bl      selftest_run

    ldi     s1, #10
    bl      _putc

    ldi     s16, #0         ; s16 is the return code (0 = success, 1 = fail)

    bl      #test_1
    or      s16, s16, s1
    bz      s1, #test1_passed
    bl      #test_failed
test1_passed:

    bl      #test_2
    or      s16, s16, s1
    bz      s1, #test2_passed
    bl      #test_failed
test2_passed:

    bl      #test_3
    or      s16, s16, s1
    bz      s1, #test3_passed
    bl      #test_failed
test3_passed:

    bl      #test_4
    or      s16, s16, s1
    bz      s1, #test4_passed
    bl      #test_failed
test4_passed:

    bl      #test_5
    or      s16, s16, s1
    bz      s1, #test5_passed
    bl      #test_failed
test5_passed:

    bl      #test_6
    or      s16, s16, s1
    bz      s1, #test6_passed
    bl      #test_failed
test6_passed:

    bl      #test_7
    or      s16, s16, s1
    bz      s1, #test7_passed
    bl      #test_failed
test7_passed:

    bl      #test_8
    or      s16, s16, s1
    bz      s1, #test8_passed
    bl      #test_failed
test8_passed:

    bl      #test_9
    or      s16, s16, s1
    bz      s1, #test9_passed
    bl      #test_failed
test9_passed:

    bl      #test_10
    or      s16, s16, s1
    bz      s1, #test10_passed
    bl      #test_failed
test10_passed:

    bl      #test_11

    ; return s16 != 0 ? 1 : 0;
    sne     s1, s16, z
    and     s1, s1, #1

    ; Return from main().
    pop_all_scalar_callee_saved_regs
    ret


test_failed:
    add     s1, pc, #fail_msg@pc
    b       #_puts



selftest_msg:
    .asciz  "Selftest: "

fail_msg:
    .asciz  "*** Failed!"

    .p2align  2

; ----------------------------------------------------------------------------
; A loop with a decrementing conunter.

test_1:
    add     sp, sp, #-4
    stw     lr, sp, #0

    ldi     s9, #0x20
    ldi     s10, #12

1$:
    add     s9, s9, s10
    add     s10, s10, #-1
    bnz     s10, #1$

    add     s9, pc, #2$@pc
    ldw     s1, s9, #0
    ldw     s2, s9, #4
    add.b   s1, s1, s2
    bl      #_printhex
    ldi     s1, #10
    bl      #_putc

    ldi     s1, #0

    ldw     lr, sp, #0
    add     sp, sp, #4
    ret

2$:
    .word   0x12345678, 0xffffffff


; ----------------------------------------------------------------------------
; Sum elements in a data array.

test_2:
    add     sp, sp, #-12
    stw     lr, sp, #0
    stw     s16, sp, #4
    stw     s17, sp, #8

    add     s16, pc, #1$@pc
    ldw     s1, s16, #0     ; s1 = data[0]
    ldw     s17, s16, #4
    add     s1, s1, s17     ; s1 += data[1]
    ldw     s17, s16, #8
    add     s1, s1, s17     ; s1 += data[2]
    mov     s16, s1         ; Save the result for the comparison later
    bl      #_printhex
    ldi     s1, #10
    bl      #_putc

    ldhi    s1, #0xbeef0042@hi
    or      s1, s1, #0xbeef0042@lo
    sne     s1, s16, s1     ; Expected value?

    ldw     lr, sp, #0
    ldw     s16, sp, #4
    ldw     s17, sp, #8
    add     sp, sp, #12

    ret

1$:
    .word   0x40, 1, 0xbeef0001
    .align  4


; ----------------------------------------------------------------------------
; Call a subroutine that prints hello world.

test_3:
    add     sp, sp, #-4
    stw     lr, sp, #0

    add     s1, pc, #1$@pc
    bl      #_puts

    ldw     lr, sp, #0
    add     sp, sp, #4
    ldi     s1, #0
    ret


1$:
    .asciz  "Hello world!"
    .p2align 2


; ----------------------------------------------------------------------------
; 64-bit arithmetic.

test_4:
    add     sp, sp, #-8
    stw     lr, sp, #0
    stw     s16, sp, #4

    ; Load two 64-bit numbers into s11:s10 and s13:s12
    add     s9, pc, #1$@pc
    ldw     s10, s9, #0     ; s10 = low bits
    ldw     s11, s9, #4     ; s11 = high bits
    add     s9, pc, #2$@pc
    ldw     s12, s9, #0     ; s12 = low bits
    ldw     s13, s9, #4     ; s13 = high bits

    ; Add the numbers into s1:s16
    add     s16, s10, s12   ; s16 = low bits
    add     s1, s11, s13    ; s1 = high bits
    sltu    s9, s16, s10    ; s9 = "carry" (0 or -1)
    sub     s1, s1, s9      ; Add carry to the high word

    bl      #_printhex      ; Print high word
    mov     s1, s16
    bl      #_printhex      ; Print low word
    ldi     s1, #10
    bl      #_putc

    ldw     lr, sp, #0
    ldw     s16, sp, #4
    add     sp, sp, #8

    ldi     s1, #0
    ret

1$:
    .word   0x89abcdef, 0x01234567
2$:
    .word   0xaaaaaaaa, 0x00010000


; ----------------------------------------------------------------------------
; Floating point arithmetic.

test_5:
    add     sp, sp, #-8
    stw     lr, sp, #0
    stw     s16, sp, #4

    ; Calculate 2 * PI
    ldw     s9, pc, #test_5_pi@pc
    ldw     s10, pc, #test_5_two@pc
    fmul    s16, s9, s10    ; s16 = 2 * PI

    mov     s1, s16
    bl      #_printhex
    ldi     s1, #10
    bl      #_putc

    ; Was the result 2 * PI?
    ldw     s9, pc, #test_5_twopi@pc
    fsub    s9, s16, s9     ; s9 = (2 * PI) - test_5_twopi

    ldw     lr, sp, #0
    ldw     s16, sp, #4
    add     sp, sp, #8

    ; s1 = (result == 2*PI) ? 0 : 1
    ldi     s1, #0
    bz      s9, #1$
    ldi     s1, #1
1$:

    ret


test_5_one:
    .word   0x3f800000
test_5_two:
    .word   0x40000000
test_5_pi:
    .word   0x40490fdb
test_5_twopi:
    .word   0x40c90fdb


; ----------------------------------------------------------------------------
; Vector operations.

test_6:
    add     sp, sp, #-20
    stw     lr, sp, #0
    stw     vl, sp, #4
    stw     s16, sp, #8
    stw     s17, sp, #12
    stw     s18, sp, #16

    ; Print the maximum vector length
    add     s1, pc, #test_6_vector_length_text@pc
    bl      #_puts
    cpuid   s1, z, z
    bl      #_printhex
    ldi     s1, #10
    bl      #_putc

    ; Prepare scalars
    add     s9, pc, #test_6_in@pc
    add     s16, pc, #test_6_result@pc

    ldi     s11, #37        ; We want to process 37 elements

    ; Prepare the vector operation
    cpuid   s10, z, z       ; s10 is the max number of vector elements
    lsl     s12, s10, #2    ; s12 is the memory increment per vector operation

    ; Initialize v10 to a constant value
    add     v10, vz, #0x1234

1$:
    min     vl, s10, s11    ; vl = min(s10, s11)

    ldw     v9, s9, #4      ; Load v9 from memory
    add     v9, v9, v10     ; Add vectors v9 and v10
    add     v9, v9, #-8     ; Subtract a scalar from v9
    stw     v9, s16, #4     ; Store the result to memory

    sub     s11, s11, s10   ; Decrement the loop counter
    add     s9, s9, s12     ; Increment the memory pointers
    add     s16, s16, s12
    bgt     s11, #1$

    ; Print the result
    add     s16, pc, #test_6_result@pc
    ldi     s17, #0
2$:
    lsl     s9, s17, #2
    ldw     s1, s16, s9
    bl      #_printhex
    ldi     s1, #0x2c
    add     s18, s17, #-36  ; s17 == 36 ?
    add     s17, s17, #1
    bnz     s18, #3$
    ldi     s1, #10         ; Print comma or newline depending on if this is the last element
3$:
    bl      #_putc
    bnz     s18, #2$

    ldw     lr, sp, #0
    ldw     vl, sp, #4
    ldw     s16, sp, #8
    ldw     s17, sp, #12
    ldw     s18, sp, #16
    add     sp, sp, #20

    ldi     s1, #0
    ret

test_6_in:
    .word   1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    .word   17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
    .word   33, 34, 35, 36, 37

test_6_result:
    .space  148

test_6_vector_length_text:
    .asciz  "Max vector length: "

    .p2align 2

; ----------------------------------------------------------------------------
; Software multiply.

test_7:
    add     sp, sp, #-4
    stw     lr, sp, #0

    ldi     s1, #123
    ldi     s2, #456
    bl      #_mul32
    ; mul     s1, s1, s2
    bl      #_printhex
    ldi     s1, #10
    bl      #_putc

    ldw     lr, sp, #0
    add     sp, sp, #4
    ldi     s1, #0
    ret


; ----------------------------------------------------------------------------
; Software divide.

test_8:
    add     sp, sp, #-8
    stw     lr, sp, #0

    ldi     s1, #5536
    ldi     s2, #13
    bl      #_divu32

    stw     s2, sp, #4
    bl      #_printhex  ; Print the quotient
    ldi     s1, #0x3a   ; ":"
    bl      #_putc
    ldw     s1, sp, #4
    bl      #_printhex  ; Print the remainder
    ldi     s1, #10     ; "\n"
    bl      #_putc

    ldw     lr, sp, #0
    add     sp, sp, #8
    ldi     s1, #0
    ret


; ----------------------------------------------------------------------------
; Floating point operations.

test_9:
    add     sp, sp, #-20
    stw     lr, sp, #0
    stw     s16, sp, #4
    stw     s17, sp, #8
    stw     s18, sp, #12
    stw     s19, sp, #16

    ldhi    s16, #0x3fd98000    ; s16 = 1.6992188F
    ldhio   s17, #0x41c5bfff    ; s17 = 24.718748F
    fmul    s18, s16, s17       ; s18 = 42.002561F (0x4228029f)

    ldw    s9, pc, #1$@pc
    sne    s19, s9, s18         ; Expected value?

    or      s1, s18, z
    bl      #_printhex          ; Print the product
    ldi     s1, #0x2c           ; ","
    bl      #_putc

    ldi     s9, #2
    ftoi    s1, s18, s9         ; s1 = (int)(s18 * 2.0^2) (0x000000a8)

    ldi     s9, #0x00a8
    sne     s9, s9, s1          ; Expected value?
    or      s19, s19, s9

    bl      #_printhex          ; Print the integer representation
    ldi     s1, #10             ; "\n"
    bl      #_putc

    or      s1, s19, z          ; Result in s1

    ldw     lr, sp, #0
    ldw     s16, sp, #4
    ldw     s17, sp, #8
    ldw     s18, sp, #12
    ldw     s19, sp, #16
    add     sp, sp, #20

    ret


1$:
    .word   0x4228029f


; ----------------------------------------------------------------------------
; Vector folding.

test_10:
    add     sp, sp, #-24

    ldi     vl, #4
    add     s9, pc, #test_10_data1@pc
    add     s10, pc, #test_10_data2@pc
    ldw     v1, s9, #4      ; v1 = [1, 2, 3, 4]
    ldw     v2, s10, #4     ; v2 = [9, 8, 7, 6]

    add     v3, v1, v2      ; v3 = [10, 10, 10, 10]
    add     s10, sp, #0
    stw     v3, s10, #4
    ldi     vl, #2
    add/f   v4, v1, v2      ; v4 = [8, 8]
    add     s10, sp, #16
    stw     v4, s10, #4

    ldi     s1, #-1

    add     s9, pc, #test_10_answer1@pc
    add     s10, sp, #0
    ldw     s2, s10, #0
    ldw     s3, s9, #0
    seq     s2, s2, s3
    and     s1, s1, s2
    ldw     s2, s10, #4
    ldw     s3, s9, #4
    seq     s2, s2, s3
    and     s1, s1, s2
    ldw     s2, s10, #8
    ldw     s3, s9, #8
    seq     s2, s2, s3
    and     s1, s1, s2
    ldw     s2, s10, #12
    ldw     s3, s9, #12
    seq     s2, s2, s3
    and     s1, s1, s2

    add     s9, pc, #test_10_answer2@pc
    add     s10, sp, #16
    ldw     s2, s10, #0
    ldw     s3, s9, #0
    seq     s2, s2, s3
    and     s1, s1, s2
    ldw     s2, s10, #4
    ldw     s3, s9, #4
    seq     s2, s2, s3
    and     s1, s1, s2

    xor     s1, s1, #-1

    add     sp, sp, #24
    ret

test_10_data1:
    .word   1,2,3,4

test_10_data2:
    .word   9,8,7,6

test_10_answer1:
    .word   10, 10, 10, 10

test_10_answer2:
    .word   8, 8


; ----------------------------------------------------------------------------
; Syscalls

    ; Syscall routine addresses
    SYSCALL_EXIT          = 0xffff0000+4*0
    SYSCALL_PUTCHAR       = 0xffff0000+4*1
    SYSCALL_GETCHAR       = 0xffff0000+4*2
    SYSCALL_CLOSE         = 0xffff0000+4*3
    SYSCALL_FSTAT         = 0xffff0000+4*4
    SYSCALL_ISATTY        = 0xffff0000+4*5
    SYSCALL_LINK          = 0xffff0000+4*6
    SYSCALL_LSEEK         = 0xffff0000+4*7
    SYSCALL_MKDIR         = 0xffff0000+4*8
    SYSCALL_OPEN          = 0xffff0000+4*9
    SYSCALL_READ          = 0xffff0000+4*10
    SYSCALL_STAT          = 0xffff0000+4*11
    SYSCALL_UNLINK        = 0xffff0000+4*12
    SYSCALL_WRITE         = 0xffff0000+4*13
    SYSCALL_GETTIMEMICROS = 0xffff0000+4*14

    ; From newlib sys/_default_fcntl.h
    O_RDONLY = 0
    O_WRONLY = 1
    O_RDWR = 2
    O_APPEND = 0x0008
    O_CREAT = 0x0200
    S_IRWXU = 0700

test_11:
    add     sp, sp, #-16
    stw     lr, sp, #0

    ; PUTCHAR
    ldi     s1, #66
    ldi     s9, #SYSCALL_PUTCHAR
    jl      s9

    ; OPEN
    ldi     s1, #test_11_path1@pc   ; path
    ldi     s2, #O_WRONLY+O_CREAT   ; flags
    ldi     s3, #S_IRWXU            ; mode
    ldi     s9, #SYSCALL_OPEN
    jl      s9
    stw     s1, sp, #4              ; sp + 4 = fd

    ; WRITE
    ldw     s1, sp, #4              ; fd
    ldi     s2, #test_11_text@pc    ; buf
    ldi     s3, #test_11_text_size  ; nbytes
    ldi     s9, #SYSCALL_WRITE
    jl      s9

    ; CLOSE
    ldw     s1, sp, #4              ; fd
    ldi     s9, #SYSCALL_CLOSE
    jl      s9

    ldw     lr, sp, #0
    add     sp, sp, #16
    ret


test_11_path1:
    .asciz  "/tmp/test1_out.txt"
    .p2align    2


test_11_text:
    .ascii  "Hello world!\n"
    test_11_text_size = .-test_11_text
    .p2align    2

