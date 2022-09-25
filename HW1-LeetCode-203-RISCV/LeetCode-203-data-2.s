.data
length:
    .word 5
array: 
    .word 2, 1, 2, 1, 2
target:
    .word 2 
err_msg:
    .string "malloc fail"
.text
main:
    jal create_default_list
    mv t1, s1 # t1 store list head
    jal print_list
    lw a0, 0(s1) # cur = head
    mv t1, s1 # t1 store list head
    jal remove_elements
    mv t1, s1 # t1 store list head
    jal print_list
exit:
    addi a7, x0 10 # exit
    ecall
create_default_list:
    addi sp, sp, 8
    li s0, 0x0fff0000 # start address of linked list
    sw ra, 0(sp) # return address
    sw s0, 4(sp)
    li s2, 0
    la t1, array   # load address to array
    la t0, length
    lw t2, 0(t0) 
loop:   # -4(s0) need to modify
    jal ra, malloc  # get memory for the next node
    bne a0, x0, exit_error  
    lw s1, 0(t1)
    addi t1, t1, 4
    sw s1, 0(s0)   # node->value = i
    sw x0, 4(s0)   # node->next = NULL
    sw s0, -4(s0)  # cur->next = node
    addi s2, s2, 1   # i++
    addi s0, s0, 8
    bne s2, t2, loop    # check end condition in while loop
ret:
    lw ra, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    jr ra
malloc:     # allocates a1 bytes on the heap, returns pointer to start in a0
    addi a0, s0, 8 # move heap limit to current + 8, 4 byte for integer, 4 byte for pointer 
    addi a7, x0, 214 # brk systemcall
    ecall
    jr  ra
print_list:
    beq t1, x0, end
    lw a0, 0(t1) # load value store in node
    addi a7, x0, 1 # print number
    ecall
    lw t1, 4(t1) # load address store in cur->next
    j print_list
end:      
    addi a0, x0, 10
    addi a7, x0, 11 # print char
    ecall
    jr ra
exit_error:
    la a0, err_msg 
    addi a7, x0 4  # print error message
    ecall
    addi a7, x0 10 # exit
    ecall   
remove_elements:
    la s0, target
    lw s0, 0(s0)
iterate:
    beq a0, s0, remove
    mv t2, t1 # prev = cur
    lw t1, 4(t1) # load address store in cur->next
    lw a0, 0(t1) # load value store in node
    bne t1, x0, iterate
    jr ra
remove:
    beq t1, s1, remove_head # if cur == head
    lw t1, 4(t1) # load cur->next to t0
    sw t1, 4(t2) # prev->next = cur->next
    lw a0, 0(t1) # load value store in node
    bne t1, x0, iterate
    jr ra
remove_head:
    lw t1, 4(t1) # load address store in cur->next
    lw a0, 0(t1) # load value store in node
    mv s1, t1
    bne t1, x0, iterate
    jr ra