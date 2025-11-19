# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address (shift it one byte left) - x2 = 0x010000
        # add 2 positives without overflow
	addi x4, x0, 0x80      # normal addition - source 1, 128
	addi x5, x0, 9         # normal addition - source 2, 9
	add  x6, x5, x4        # normal addition - result, x6 = 137 = 128+9
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	# add 2 negatives without overflow
	addi x4, x0, 128       # normal addition - source 1  x4 =  128 = 000...0010000000
	xori x4, x4, -1        # ... invert all bits         x4 =        111...1101111111
	addi x4, x4, 1         # 2comp - source 1, -128      x4 = -128 = 111...1110000000
	addi x5, x0, 9         # normal addition - source 2  x5 =    9 = 000...0000001001
	xori x5, x5, -1        # ... invert all bits         x5 =        111...1111110110
	addi x5, x5, 1         # 2comp - source 2, -9        x5 =   -9 = 111...1111110111
	add  x6, x5, x4        # normal addition - result, x6 = -137 (ff..ff77) = -9 - 128 (77h = 119d = GPIO)
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	# add 2 positive with overflow
	addi x4, x0, 128       # normal addition - source 1       x4 =  128      = 000...0010000000
	addi x5, x0, -1        # fill all 64 bit with one         x5 = -  1      = 111...1111111111
	srli x5, x5, 1         # shift one position to the right  x5 = max. pos. = 011...1111111111
	#nop #!!!!!!!!!!!!!!
	addi x7, x0, 0x7e      #                                  x7 = 0x7e      = 000...0001111110
	#nop #!!!!!!!!!!!!!!
	sub  x5, x5, x7        # normal addition - source 2 (0x7fffffffffffff81)   x5 = max. pos - 0x7e = 011...1110000001
	add  x6, x5, x4        # normal addition - result, x6 = 0x8000000000000001 x6 =                   100...0000000001
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	# add 2 negatives with overflow
	addi x4, x0, 128       # normal addition - source 1
	xori x4, x4, -1
	addi x4, x4, 1         # 2comp - source 1, -128
	addi x5, x0, -1        # fill all 64 bit with one
	srli x5, x5, 1         # shift one position to the right
	addi x7, x0, 0x7d
	#nop #!!!!!!!!!!!!!!
	sub  x5, x5, x7        # normal addition - source 2 (0x7fffffffffffff82)
	xori x5, x5, -1
	addi x5, x5, 1         # 2comp = 800000000000007e
	add  x6, x5, x4        # normal addition - result, x6 = 0x0000000000000002
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop
