`timescale 1ns/1ps

import as_pack::*;

module tb_rv64i ();
  parameter tclk_2_t = 20; // 10 ns; given by timescale
  parameter clk_2_t = 5;   // 5 ns; given by timescale

  parameter sc01_length_in = 2;
  parameter sc01_length_out = 2;
  parameter im_length_in = im_scan_length;
  parameter im_length_out = im_scan_length;

  logic clk_s;
  logic	rst_s;
  logic	tck_s, trst_s, tms_s, tdi_s, tdo_s;
  logic [nr_gpios-1:0]	      gpio_s; // gpio
  logic [gpio_addr_width-1:0] gpioAddr_s;
  logic	cs_s;
  logic	clk_core1_s, clk_core2_s;
  int	cnt_clk_s;

  // initial load I-Mem
  logic [instr_width-1:0]     iram_s[imemdepth-1:0]; // I-Mem

  int fd;

  as_top_mem DUT (.clk_i(clk_s),
              .rst_i(rst_s),
              .tck_i(tck_s),
              .trst_i(trst_s),
              .tms_i(tms_s),
              .tdi_i(tdi_s),
              .tdo_o(tdo_s),
              .gpio_o(gpio_s),
              .gpioAddr_o(gpioAddr_s),
              .cs_o(cs_s)
             );
  // read instructions
  initial
    $readmemh("riscvtest.mem",iram_s);

  // reset
  initial
  begin
    cnt_clk_s <= 0;    
    rst_s <= 1; #(10*2*clk_2_t); rst_s <= 0;
  end

  initial
  begin
    fd = $fopen("./error.txt", "a");
  end

  // clock
  always
  begin
    clk_s <= 1; #clk_2_t; clk_s <= 0; #clk_2_t; 
  end

  // TCK
  initial
  begin
    tck_s <= 0;
    tms_s <= 0;
    tdi_s <= 0;
    trst_s <= 0;
  end

  always @(posedge clk_s)
  begin
    clk_core2_s = clk_core1_s;
  end

  // check results
  always @(negedge clk_s)
  begin
    // trace internal signals
    clk_core1_s = tb_rv64i.DUT.cpu.clk_i;
    if( (clk_core1_s === 0) && (clk_core2_s === 1) ) // falling edge of clk_core
    begin
      cnt_clk_s++;
      $display(" ");
      $display("----------------------------------------");
      // Show the instructions in all stages
      $display("Instruction in fetch     0x%8h @instr 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s, cnt_clk_s);
      $display("Instruction in decode    0x%8h @instr 0x%0h", tb_rv64i.DUT.cpu.instr_decode_s, cnt_clk_s);
      $display("Instruction in execute   0x%8h @instr 0x%0h", tb_rv64i.DUT.cpu.instr_execute_s, cnt_clk_s);
      $display("Instruction in mem       0x%8h @instr 0x%0h", tb_rv64i.DUT.cpu.instr_mem_s, cnt_clk_s);
      $display("Instruction in writeback 0x%8h @instr 0x%0h", tb_rv64i.DUT.cpu.instr_writeback_s, cnt_clk_s);
      
      // Look for forwarding A
      if( (tb_rv64i.DUT.cpu.ex_mem_reg_wr_s === 1) &&  // write on register file, only ld and r-type
	  (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s !== 0) &&  // ignore write on x0
	  (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs1_s) // register read follows a write immediately
        )
	$display("FORWARD_A = 2 @instruction 0x%0h", cnt_clk_s);
      else if ( (tb_rv64i.DUT.cpu.mem_wb_reg_wr_s === 1) && 
                (tb_rv64i.DUT.cpu.mem_wb_reg_rd_s !== 0) &&
	        ~( (tb_rv64i.DUT.cpu.ex_mem_reg_wr_s === 1) && 
                   (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s !== 0) && 
                   (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs1_s) ) && 
                (tb_rv64i.DUT.cpu.mem_wb_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs1_s)  // register read follows a write; second read
              )
	$display("FORWARD_A = 1 @instruction 0x%0h", cnt_clk_s);
      else
	$display("FORWARD_A = 0 @instruction 0x%0h", cnt_clk_s);
      // Look for forwarding B
      if( (tb_rv64i.DUT.cpu.ex_mem_reg_wr_s === 1) &&  // write on register file, only ld and r-type
	  (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s !== 0) &&  // ignore write on x0
	  (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs2_s) // register read follows a write immediately
        )
	$display("FORWARD_B = 2 @instruction 0x%0h", cnt_clk_s);
      else if ( (tb_rv64i.DUT.cpu.mem_wb_reg_wr_s === 1) && 
                (tb_rv64i.DUT.cpu.mem_wb_reg_rd_s !== 0) &&
	        ~( (tb_rv64i.DUT.cpu.ex_mem_reg_wr_s === 1) && 
                   (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s !== 0) && 
                   (tb_rv64i.DUT.cpu.ex_mem_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs2_s) ) && 
                (tb_rv64i.DUT.cpu.mem_wb_reg_rd_s === tb_rv64i.DUT.cpu.id_ex_reg_rs2_s)  // register read follows a write; second read
              )
	$display("FORWARD_B = 1 @instruction 0x%0h", cnt_clk_s);
      else
	$display("FORWARD_B = 0 @instruction 0x%0h", cnt_clk_s);
      // Display time of falling edge of core clk
      $display("Falling ege of clk_core @%g", $time);
      // Look for forwarding and stall
      if(cnt_clk_s === 1) // addi x2, x0, 0x100
      begin
        $display("Instruction #01: 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s);
      end
      if(cnt_clk_s === 14) // add x7, x4, x5, 11=5+6, first of sequence in fetch
      begin
        $display("Instruction #14: 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s);
      end
      if(cnt_clk_s === 17) // [addi x2, x2, 4], [add x7, x4, x5], 11=5+6, first of sequence in mem
      begin
        $display("Instruction #17: 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s);
	$display("FWA/B - Destination register of instr. before first add (wb stage): 0x%0h", tb_rv64i.DUT.cpu.mem_wb_reg_rd_s);
	$display("FWA/B - Destination register of first add (mem stage):              0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_rd_s);
	$display("FWA - Source register 1 of second add (exe stage):                  0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs1_s);
	$display("FWB - Source register 2 of second add (exe stage):                  0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs2_s);
	$display("FWx - Register write enable (dec stage):                            0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_wr_s);
	$display("FWA - forwardA:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_a_s);
	$display("FWB - forwardB:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_b_s);
	$display("FWA - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_a_mux_out_s);
	$display("FWB - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_b_mux_out_s);
	$display("FWA/B - ALU Result:                                                 0x%0h", tb_rv64i.DUT.cpu.alu_result_execute_s);
	$display("FWA/B - ALU Result (forward from mem):                              0x%0h", tb_rv64i.DUT.cpu.alu_result_mem_s);
	$display("FWA/B - ALU Result (forward from wb):                               0x%0h", tb_rv64i.DUT.cpu.alu_result_writeback_s);
      end // if (cnt_clk_s === 17)
      if(cnt_clk_s === 18) // [add x7, x4, x5], [add x8, x7, x6], 18=11+7, second of sequence in mem
      begin
        $display("Instruction #18: 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s);
	$display("FWA/B - Destination register of first add (wb stage):               0x%0h", tb_rv64i.DUT.cpu.mem_wb_reg_rd_s);
	$display("FWA/B - Destination register of second add (mem stage):             0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_rd_s);
	$display("FWA - Source register 1 of third instr (exe stage):                 0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs1_s);
	$display("FWB - Source register 2 of third instr (exe stage):                 0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs2_s);
	$display("FWx - Register write enable (dec stage):                            0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_wr_s);
	$display("FWA - forwardA:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_a_s);
	$display("FWB - forwardB:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_b_s);
	$display("FWA - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_a_mux_out_s);
	$display("FWB - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_b_mux_out_s);
	$display("FWA/B - ALU Result:                                                 0x%0h", tb_rv64i.DUT.cpu.alu_result_execute_s);
	$display("FWA/B - ALU Result (forward from mem):                              0x%0h", tb_rv64i.DUT.cpu.alu_result_mem_s);
	$display("FWA/B - ALU Result (forward from wb):                               0x%0h", tb_rv64i.DUT.cpu.alu_result_writeback_s);
      end // if (cnt_clk_s === 18)
      if(cnt_clk_s === 19) // [add x7, x4, x5], [add x8, x7, x6], [sub x3, x9, x7], 1=12-11, third of sequence in mem
      begin
        $display("Instruction #19: 0x%0h", tb_rv64i.DUT.cpu.instr_fetch_s);
	$display("FWA/B - Destination register of first add (wb stage):               0x%0h", tb_rv64i.DUT.cpu.mem_wb_reg_rd_s);
	$display("FWA/B - Destination register of second add (mem stage):             0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_rd_s);
	$display("FWA - Source register 1 of third instr (exe stage):                 0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs1_s);
	$display("FWB - Source register 2 of third instr (exe stage):                 0x%0h", tb_rv64i.DUT.cpu.id_ex_reg_rs2_s);
	$display("FWx - Register write enable (dec stage):                            0x%0h", tb_rv64i.DUT.cpu.ex_mem_reg_wr_s);
	$display("FWA - forwardA:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_a_s);
	$display("FWB - forwardB:                                                     0x%0h", tb_rv64i.DUT.cpu.forward_b_s);
	$display("FWA - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_a_mux_out_s);
	$display("FWB - Mux out:                                                      0x%0h", tb_rv64i.DUT.cpu.forward_b_mux_out_s);
	$display("FWA/B - ALU Result:                                                 0x%0h", tb_rv64i.DUT.cpu.alu_result_execute_s);
	$display("FWA/B - ALU Result (forward from mem):                              0x%0h", tb_rv64i.DUT.cpu.alu_result_mem_s);
	$display("FWA/B - ALU Result (forward from wb):                               0x%0h", tb_rv64i.DUT.cpu.alu_result_writeback_s);
      end
    end
    // check the output via GPIO
    if(cs_s === 1)
    begin
      $display("CS detected");
      if((gpioAddr_s === 4)) 
        case(gpio_s)
          2     : begin $display("Forwarding 01 Passed!: 0x%0h", gpio_s);  
                        $display("Simulation succeeded"); #100; #(1*2*clk_2_t); 
                        $fdisplay(fd,"%s - forwarding01: Test ok", get_time());
	                assert (tb_rv64i.DUT.cpu.dMemWr_o == 0) $display("PASS: Gut"); else $error("FAIL: Bloed");
                        $fclose(fd); 
                        $stop; 
                  end
          default : begin $display("Unexpected GPIO: 0x%0h", gpio_s); 
                          $fdisplay(fd,"%s - forwarding01: Test fail", get_time()); 
                          $fclose(fd); 
                          $stop;  
                    end
        endcase
      else // (gpioAddr_s === 4)
      begin
        $display("Simulating: time=%0t addr=0x%0h data=0x%0h cs=0x%0h+++",$time, gpioAddr_s, gpio_s, cs_s);
        $stop;
      end
    end // cs_s
    //end // loading
  end // negedge

//------------------------------------------
// Functions
//------------------------------------------
  function string get_time();
    int    file_pointer;
    
    //Stores time and date to file sys_time
    //void'($system("date +%X--%x > sys_time"));
    void'($system("date +%x > sys_time"));
    //Open the file sys_time with read access
    file_pointer = $fopen("sys_time","r");
    //assin the value from file to variable
    void'($fscanf(file_pointer,"%s",get_time));
    //close the file
    $fclose(file_pointer);
    void'($system("rm sys_time"));
  endfunction

endmodule : tb_rv64i
