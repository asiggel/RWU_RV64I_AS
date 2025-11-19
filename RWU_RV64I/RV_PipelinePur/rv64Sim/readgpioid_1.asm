# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address, x2=0x00000100
	slli x2, x2, 8         # load GPIO base address,    x2=0x00010000
	ld   x3, 0(x2)         # load GPIO ID to x3,        x3=0x00000001
	#addi x0, x0, 0
	#addi x0, x0, 0
	#addi x0, x0, 0
	sd   x3, 4(x2)         # write LSB of GPIO ID to GPIO, x2=0x00010000(+4), x3=0x00000001
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop
