
.ONESHELL:

asFile01 := readgpioid
asFile02 := allinstructions
asFile93 := allinstructions01
asFile03 := filldmem
asFile04 := instr01loadbyte    # 4th test
asFile05 := instr02loadhalf    # 5th test
asFile06 := instr03loadword    # 6th test
asFile07 := instr19add
asFile08 := instr04loadbyteu   # 7th test
asFile09 := instr05loadhalfu   # 8th test
asFile10 := instr06addi        # third test
asFile11 := instr07slli        # second test
asFile29 := instr29lui         # first test
asFile98 := forwarding01       # forwarding test
asFile97 := forwarding02       # stall/forwarding test
asFile96 := forwarding03       # sd/ld/add stall/forwarding test
asFile95 := forwarding04       # forwarding test, needs two at the same time
asFile94 := forwarding05       # ld/sd/add
asFile99 := instr99loadimem    # load the I-Mem via JTAG

#asmFiles := $(asFile29) \
#	$(asFile04)

asmFiles := $(asFile04)

.phony : doit
doit:
	$(foreach var,$(asmFiles), \
	echo $(var); \
	cp rv64Sim/$(var).asm rv64Sim/rv64i.asm; \
	cd rv64Sim && $(MAKE) all; \
	cd ..; \
	cp tb/tb_rv64i_$(var).sv tb/tb_rv64i.sv; \
	$(MAKE) -C sim; \
)

.phony : clean
clean:
	@echo "Make clean"
	rm -f *.o
	rm -f *.s
	rm -f *.lst
	cd rv64Sim && $(MAKE) clean
	$(MAKE) clean -C ../sim
