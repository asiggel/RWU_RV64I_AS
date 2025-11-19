# RISC-V Assembly              Description
# A sequence of algorithmic instructions where the first instruction writes to register x7
# and the following instructions needs the value stored in x7 immediately.
.global _start

_start: # prepare GPIO address (0x10004) and set registers for data sequence
	addi x2, x0, 0x100     # GPIO base address: x2=0x00000100
	addi x4, x0, 5         # data sequence: load 5 to x4
	addi x5, x0, 6         # data sequence: load 6 to x5
	addi x6, x0, 7         # data sequence: load 7 to x6
	addi x9, x0, 12        # data sequence: load 12 to x9
	# separate instructions
	addi x0, x0, 0         # NOP: separate addi and slli
	addi x0, x0, 0         # NOP: separate addi and slli
	addi x0, x0, 0         # NOP: separate addi and slli
	# separate instructions
	slli x2, x2, 8         # GPIO base address: x2=0x00010000
	# separate instructions
	addi x0, x0, 0
	addi x0, x0, 0
	addi x0, x0, 0
	# separate instructions
	addi x2, x2, 4         # GPIO base address: +4 for first output (x2=0x10004)
        # Start with a sequence, which needs forwarding
	add x7, x4, x5         # data sequence 1 (5+6=x7=11)
	add x8, x7, x6         # data sequence: x7 needs forwarding from EX/MEM (reg A) (11+7=x8=18)
	sub x3, x9, x7         # data sequence: x7 needs forwarding from MEM/WB (reg B) (12-11=x3=1)
	# separate instructions
	addi x0, x0, 0
	addi x0, x0, 0
	addi x0, x0, 0
	# separate instructions
	sd   x3, 0(x2)         # write LSB of x3 to GPIO, x2=0x00010004, x3=0x00000001
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop
