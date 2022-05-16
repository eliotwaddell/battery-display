.text
.global  set_batt_from_ports

set_batt_from_ports:                        # begin function
  .BEGIN_SET_BATT:                          # first jump point is at beginning
        movw BATT_VOLTAGE_PORT(%rip), %ax   # move the short stored in B_V_P to the %ax register
        testw %ax, %ax                      # test %ax for a sign
        js .BATTERY_ERROR                   # if there is a sign, value is negative, battery has problems, return 1
        movw  %ax,  0(%rdi)                 # %ax is unsigned, meaning we assign B_V_P to batt->volts
        cmpw $3800, 0(%rdi)                 # compares 3800 with batt->volts
        jle .CALC_PERCENT                   # if batt->volts isn't greater than 3800, we must calculate percentage
        movb  $100, 2(%rdi)                 # if batt->volts is greater, set percent to 100
  .PERCENT_SET:                             # jump point that indicates if percent is done and calculated
        cmpb  $0, 2(%rdi)                   # checks if percent is signed
        js .NEGATIVE_PERCENT                # jumps to code that sets a negative percent to zero
  .CORRECT_PERCENT:                         # jump point for when percent is formatted correctly
        movzbl BATT_STATUS_PORT(%rip), %edx # takes value of status port and puts it in %edx
        andl  $1, %edx                      # bitwise &s the value of B_S_P with 1, rendering either a 1 or a zero
        movb  %dl,  3(%rdi)                 # moves either 1 or zero to batt->mode, setting the status
        movl  $0, %eax                      # moves zero to %eax, which is returned to indicate successful initialization
        ret                                 # returns 0
  .NEGATIVE_PERCENT:                        # jump point that sets a negative percent to zero
        movb  $0, 2(%rdi)                   # sets percent to zero
        jmp .CORRECT_PERCENT                # jumps to point where percent is finally absolutely correct
  .CALC_PERCENT:                            # jump point for percentage calculation
        movw  (%rdi), %dx                   # moves batt->volts into %edx for manipulation
        subw  $3000,  %dx                   # subtracts 3000 from batt->volts
        sarw  $3, %dx                       # dividees %dx value by 8, part of formula
        movb  %dl,  2(%rdi)                 # assigns final value in %dl to batt->percent
        jmp   .PERCENT_SET                  # percent is set, goes back to main string of commands
  .BATTERY_ERROR:                           # jump point if B_V_P is negative
        movq  $1, %rax                      # moves 1 into %rax for return
        ret                                 # returns 1
### Data area associated with the next function
.data

  digit_array:                              # array of bit masks for display
        .int 0b0111111                      # 0
        .int 0b0000011                      # 1
        .int 0b1101101                      # 2
        .int 0b1100111                      # 3
        .int 0b1010011                      # 4
        .int 0b1110110                      # 5
        .int 0b1111110                      # 6
        .int 0b0100011                      # 7
        .int 0b1111111                      # 8
        .int 0b1110111                      # 9
  ten:
        .int 10                             # used for division


.text
.global  set_display_from_batt

set_display_from_batt:
  .BEGIN_SET_DISPLAY:                       # rdi = batt, rsi = *display, %rcx = left, %r8 = middle, %r9 = right, %r10 = disp_value
        leaq  digit_array(%rip),  %r11      # sets %r11 to hold the address to beginning of array (pointer)
        movl  $0, (%rsi)                    # initializes display to 0 (empty)
        movq  %rdi, %rax                    # copies struct into %rax for manipulation
        sarq  $24,  %rax                    # shifts struct bits to align with mode for bitwise and
        andq  $1, %rax                      # checks if the mode is voltage or percent
        cmpb $0,  %al                       # checks if %al is zero or not
        jne .SET_DISP_VALUE                 # jumps to point where disp_value is assigned
        movzwl  %di, %eax                   # copies struct for disp_value assignment
        addl  $5, %eax                      # 5 is added for rounding after integer division
        cqto                                # extends sign
        idivl ten(%rip)                     # divides %eax by 10, to determine disp_value
        movl  %eax, %r10d                   # disp_value set to quotient
  .DISP_VALUE_DONE:                         # disp_value is set to either percent or formatted volts
        movl  %r10d,  %eax                  # sets disp_value to be divided
        cqto                                # sign extend
        idivl ten(%rip)                     # divides disp_value by 10
        movl  %edx, %r9d                    # moves remainder from previous division into variable right
        cqto                                # sign exten
        idivl ten(%rip)                     # divides once more
        movl  %edx, %r8d                    # sets remainder to middle (%r8)
        cqto                                # sign extend
        idivl ten(%rip)                     # last division
        movl  %edx, %ecx                    # sets remainder to left.
        cmpb  $0,  %cl                      # is left == 0?
        je .NO_LEFT                         # skips assigning left
        movl (%r11,%rcx,4), %edx            # moves bitmask into %rdx
        orl   %edx, (%rsi)                  # bitwise | to set bits of left digit
        sall  $7, (%rsi)                    # left shifts display bits to make room for next digit
  .MIDDLE:                                  # jump point to set middle digit
        movl  (%r11,%r8,4), %ecx            # moves bitmask into %rcx
        orl   %ecx, (%rsi)                  # sets middle digit using bitwise |
        sall  $7, (%rsi)                    # shifts bits left once more to make room for right
  .RIGHT:                                   # jump point for right digit
        movl (%r11,%r9,4), %ecx             # moves bitmask into %rcx
        orl   %ecx, (%rsi)                  # sets right digit
        jmp .SET_MODE                       # jumps to point where mode bits are set
  .NO_LEFT:                                 # skip here if left = 0
        cmpb $0,  %r8b                      # now checks if middle exists
        je .RIGHT                           # no left and no middle
        jmp .MIDDLE                         # if it doesnt jump at jz, the middle exists
  .SET_MODE:                                # either sets bits for % or decimal and V
        movq  %rdi, %rax                    # copies struct into %rax for manipulation
        sarq  $24,  %rax                    # shifts struct bits to align with mode for bitwise and
        andq  $1, %rax                      # sets up %rax to check if the mode is voltage or percent
        testb %al,  %al                     # checks if %rax is 0 or not
        jz  .SET_VOLTAGE_BITS               # jumps to set bits for decimal and "V"
        movl  $1, %eax                      # prepares bit for % sign
        sall  $23,  %eax                    # left shift %eax to 23rd position
        orl   %eax, (%rsi)                  # sets 23rd bit to 1 using bitwise |
        jmp .BATTERY_LEVEL_BITS             # dont want to set voltage bits too, so we jump
  .SET_VOLTAGE_BITS:                        # point to light up decimal and "V"
        movl  $1, %eax                      # prepares bit for V
        sall  $22,  %eax                    # left shift %eax to 22nd position
        orl   %eax, (%rsi)                  # sets 22nd bit to 1 using bitwise |
        movl  $1, %eax                      # prepares bit for decimal place
        sall  $21,  %eax                    # left shift %eax to 21st position
        orl   %eax, (%rsi)                  # sets 21st bit to 1 using bitwise |
  .BATTERY_LEVEL_BITS:                      # last part of program is to set the battery level bits
        movq  %rdi, %rax                    # this time struct is used to access percent
        sarq  $16,  %rax                    # right shift of 16 to access batt.percent
        cmpb  $5, %al                       # used to check if % is greater than 5
        jl .RETURN                          # if percent is less than 5, battery is displayed as empty
        movl  $1, %ecx                      # %ecx is used because left variable isn't necessary anymore
        sall  $28,  %ecx                    # shifts bit to 28th slot in prep for |
        orl   %ecx, (%rsi)                  # bitwise |'s the bit for bottom battery bar
        cmpb  $30,  %al                     # checks if % is greater than 30
        jl .RETURN                          # %<30 returns
        sarl  $1, %ecx                      # shifts bit to 27th position
        orl %ecx, (%rsi)                    # bitwise | to set 2nd battery bar
        cmpb  $50,  %al                     # checks if % is greater than 50
        jl .RETURN                          # %<50 returns
        sarl  $1, %ecx                      # shifts bit to 26th position
        orl %ecx, (%rsi)                    # bitwise | to set 3rd battery bar
        cmpb  $70,  %al                     # checks if % is greater than 70
        jl .RETURN                          # %<70 returns
        sarl  $1, %ecx                      # shifts bit to 25th position
        orl %ecx, (%rsi)                    # bitwise | to set 4th battery bar
        cmpb  $90,  %al                     # checks if % is greater than 90
        jl .RETURN                          # %<90 returns
        sarl  $1, %ecx                      # shifts bit to 24th position
        orl %ecx, (%rsi)                    # bitwise | to set top battery bar
  .RETURN:                                  # returns
        movq  $0, %rax                      # move 0 to %rax for return
        ret                                 # returns
  .SET_DISP_VALUE:                          # sets the display value
        movq  %rdi, %rax                    # copies struct for shift
        sarq  $16,  %rax                    # right shift to access batt.percent
        movzbl  %al,  %r10d                 # disp_value set to batt.percent
        jmp .DISP_VALUE_DONE                # back into main program

.text
.global batt_update

batt_update:                                # function to update battery display
  .BEGIN_BATT_UPDATE:                       # beginning
        pushq $0                            # puts an empty batt struct on stack, aligns too
        movq  %rsp, %rdi                    # moves address of batt struct into first arg
        call  set_batt_from_ports           # calls function, returns to %eax
        cmpb $1,  %al                       # checks to see if s_b_f_p returned 1
        je .CALIB_ERROR                     # jump to error
        popq %rdx                           # sets %rdx to the new struct
        subq  $8, %rsp                      # align stack for next call
        movq  %rdx, %rdi                    # moves batt struct into first arg
        leaq  BATT_DISPLAY_PORT(%rip), %rsi # moves display port into to 2nd arg
        call set_display_from_batt          # executes function
        addq  $8, %rsp                      # restores stack
        ret                                 # returns 0, already in %eax
  .CALIB_ERROR:                             # if set batt from ports returned 1
        popq %rdx                           # pops stack just to restore
        movq $1,  %rax                      # ready to return error
        ret                                 # returns
