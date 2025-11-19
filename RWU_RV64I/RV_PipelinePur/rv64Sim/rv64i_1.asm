# RISC-V Assembly              Description
# A load-store-use hazard. A load writes data to a register, a following store reads this register,
# finally this data is needed.
.global _start

_start: # prepare GPIO address (0x10004) and set registers for data sequence
	addi x2, x0, 0x100     # GPIO base address: x2=0x00000100
	# Prepare calculation data in memory and registers for the load-use sequence.
	addi x4, x0, 5         # data sequence: load 5 to x4
	sd x4, 8(x0)           # store 5 to address 8 (2nd double-word)
	addi x5, x0, 6         # data sequence: load 6 to x5
	addi x6, x0, 7         # data sequence: load 7 to x6
	addi x9, x0, 12        # data sequence: load 12 to x9
        # Seperate addi from slli. Only the load-use hazard should be made visible.
	addi x0, x0, 0         # NOP: separate addi and slli
	addi x0, x0, 0         # NOP: separate addi and slli
	addi x0, x0, 0         # NOP: separate addi and slli
	# ... shift address
	slli x2, x2, 8         # GPIO base address: x2=0x00010000
	# Separate ....
	addi x0, x0, 0
	addi x0, x0, 0
	addi x0, x0, 0
	# Finalize GPIO address
	addi x2, x2, 4         # GPIO base address: +4 for first output (x2=0x10004)
        # Start with a sequence, which needs stall/forwarding
	ld x7, 8(x0)           # loads a 5 from mem to x7
	sd x7, 24(x0)          # Store 5 to address 24 (4th double-word)
	ld x11, 24(x0)          # Data sequence: Load 5 from the memory to x11.
	add x10, x11, x5        # Data sequence: 5+6=x10=11 -> stall
	add x8, x6, x11         # Data sequence: x7 needs forwarding (5+7=x8=12)
	sub x3, x9, x11         # data sequence: 12-5=x3=7
	# Separate ...
	addi x0, x0, 0
	addi x0, x0, 0
	addi x0, x0, 0
	# Copy data to GPIO
	sd   x3, 0(x2)         # write LSB of x3 to GPIO, x2=0x00010004, x3=0x00000007
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop
