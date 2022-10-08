.data
length:
    .word 4
array: 
    .word 7, 7, 7, 7
target:
    .word 7 
answer:
err_msg:
    .string "malloc fail"
assert_fail:
    .string "assert fail"
assert_success:
    .string "assert success"
.text
main:
    jal create_default_list
    mv t1, s1 # store list head to t1
    jal print_list
    mv t1, s1 # store list head to t1
    jal remove_elements
    mv t1, s1 # store list head to t1
    jal print_list
    mv t1, s1 # store list head to t1
    jal assert_list
exit:
    addi a7, x0 10 # exit
    ecall
# ------ create_default_list ------
create_default_list:
    addi sp, sp, 8
    li s0, 0x0fff0000 # address of list head
    sw ra, 0(sp)      # store return address
    sw s0, 4(sp)      # store the address of list head
    li s2, 0          # i = 0
    la t1, array      # load array
    la t0, length     # load length
    lw t0, 0(t0)      
    bne s2, t0, loop
    jr ra
loop:   
    jal ra, malloc    # get memory for the next node
    bne a0, x0, exit_error  
    lw s1, 0(t1)      # load array[i]
    addi t1, t1, 4    # i++
    sw s1, 0(s0)      # node->value = array[i]
    sw t2, 4(s0)      # prev->next = node
    mv t2, s0         # prev = node
    addi s2, s2, 1    
    addi s0, s0, 8    
    bne s2, t0, loop  # check end condition in for loop
ret:
    addi s1, s0, -8
    lw ra, 0(sp)      # load return address
    addi sp, sp, 8
    jr ra
# ------ malloc ------
malloc:     # allocates 8 bytes on the heap, returns pointer to start in a0
    addi a0, s0, 8   # move heap limit to current + 8, 4 byte for integer, 4 byte for pointer 
    addi a7, x0, 214 # brk systemcall
    ecall
    jr  ra
# ------ remove_elements ------
remove_elements:
    la s0, target
    lw s0, 0(s0)
iterate:
    beq t1, x0, end_iterate 
    lw t2, 0(t1) # load value store in node 
    beq t2, s0, remove
    mv t3, t1    # prev = cur
    lw t1, 4(t1) # load address store in node->next
    j iterate
remove:
    beq t1, s1, remove_head # if cur == head
    lw t1, 4(t1) # load cur->next to t0
    sw t1, 4(t3) # prev->next = cur->next
    j iterate
remove_head:
    lw t1, 4(t1) # load address store in cur->next
    mv s1, t1 # head = head->next
    j iterate
end_iterate:
    jr ra 
# ------ print_list ------
print_list:
    beq t1, x0, end
    lw a0, 0(t1)   # load value store in node
    addi a7, x0, 1 # print number
    ecall
    lw t1, 4(t1)   # load address store in node->next
    j print_list
end:      
    addi a0, x0, 10 # '\n' acsii number
    addi a7, x0, 11 # print char
    ecall
    jr ra
exit_error:
    la a0, err_msg 
    addi a7, x0 4  # print error message
    ecall
    addi a7, x0 10 # exit
    ecall   
# ------ assert_list ------
assert_list:
    la t0, answer
assert_loop:    
    beq t1, x0, end_aseert
    lw a0, 0(t1)   # load value store in node
    lw a1, 0(t0)   # load value store in answer[i]
    lw t1, 4(t1)   # load address store in node->next
    addi t0, t0, 4 # i++
    beq a0, a1 assert_loop
    la a0, assert_fail
    addi a7, x0 4  # print message
    ecall
    jr ra
end_aseert:  
    la a0, assert_success
    addi a7, x0 4  # print message
    ecall 
    jr ra