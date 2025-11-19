# RISC-V Assembly              Description
.global _start


	# GPIO is at address 0x10000 - 0x1001F
	# Our debug output is at 0x10004
_start: addi x2, x0, 0x100     # GPIO ID registers address
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	slli x2, x2, 8         # load GPIO base address (shift it one byte left), GPIO-addr=0x10000
	# prepare an address in data memory for a 64 bit data double word
	addi x4, x0, 8         # 0x08 is base address in D-Mem
        # clear one register for communication with GPIO (data)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	# set x5 to 0x8007060504030201 (many different bytes for load byte from different positions)
	addi x5, x0, 0         # clear x5
	lui x7, 0x80070        # load upper 20 bit of a 32 bit word, 31:12
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	slli x7, x7, 12        # upper 20 bits (shift left 12 bits), 43:24
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	slli x7, x7, 12        # upper 20 bits (shift left 12 bits), 55:36
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	slli x7, x7, 8         # upper 20 bits (shift left 8 bits),  63:44
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	or x5, x5, x7          # ... to x5 (=0x8007_0000_0000_0000)
	addi x7, x0, 0         # clear x7
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	lui x7, 0x60504        # load upper 20 bit of a 32 bit word, 31:12 (x7=0x0000_0000_6050_4000)
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	slli x7, x7, 12        # next 20 bits (x7=0x0000_0605_0400_0000)
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	or x5, x5, x7          # ... to x5 (x5=0x8007_0605_0400_0000)
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x7, x0, 0         # clear x7
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	lui x7, 0x04030        # x7=0x0000_0000_0403_0000
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	or x5, x5, x7          # x5=0x8007_0605_0403_0000
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x5, x5, 0x201     # last 12 bits, x5=0x8007_0605_0403_0201
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	# store all to D-Mem
	sd x5, 16(x4)          # store to address 8+16=24 (64 bit wide)
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	### 1st byte read
	lb x6, 24(x0)          # get 1 from address 24 (8 bits only), 1st byte in double word !!! This is the test !!!
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	addi x0, x0, 0         # NOP
	# print
	sb   x10, 12(x2)        # write LSB of X10 to GPIO
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop
