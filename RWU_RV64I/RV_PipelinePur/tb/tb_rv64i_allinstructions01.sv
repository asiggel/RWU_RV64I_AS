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
  logic			      cs_s;

  // initial load I-Mem
  logic [instr_width-1:0]     iram_s[imemdepth-1:0]; // I-Mem
  logic	[instr_width-1:0]     instr_s;               // one instruction
  logic	[imem_addr_width-1:0] imaddr_s;              // I-Mem address
  logic			      we_s;
  logic [im_scan_length-1:0]  im_scan_s;             // I-Mem scan chain load
  logic			      loading_s=0;             // active while filling I-Mem

  logic	[imem_addr_width-1:0] imScanAddr_s;
  logic [instr_width-1:0]     imScanData_s;
  logic			      imScanWe_s;
  logic [im_scan_length-1:0]  imScanTdi_s;
  
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

  // check results
  always @(negedge clk_s)
  begin
    //if(loading_s === 0)
    //begin
    if(cs_s === 1)
    begin
      $display("CS detected");
      if((gpioAddr_s === 4)) 
        case(gpio_s)
          17      : begin $display("ADD Passed (ADDI, SD, LD, SW, JAL, JALR)!"); end
           7      : begin $display("SUB Passed!"); end
           5      : begin $display("LB Passed (sign extention; MSB=0)!"); end
         133      : begin $display("LB Passed (sign extention; MSB=1)!"); end
         255      : begin $display("LH Passed (SLLI)!"); end // different byte positions and negatives missing
         254      : begin $display("LW Passed!"); end        // different byte positions and negatives missing
         253      : begin $display("LBU Passed!"); end       // different byte positions and negatives missing
         252      : begin $display("LHU Passed!"); end       // different byte positions and negatives missing
         251      : begin $display("ADDI Passed!"); end
         250      : begin $display("SLLI Passed!"); end
         249      : begin $display("SLTI Passed!"); end
         248      : begin $display("SLTIU Passed!"); end
         247      : begin $display("XORI Passed!"); end
         246      : begin $display("SRLI Passed!"); end
         245      : begin $display("SRAI Passed!"); end
         244      : begin $display("ORI Passed!"); end
         243      : begin $display("ANDI Passed!"); end
          76      : begin $display("AUIPC Passed!"); end // 196
         242      : begin $display("SB Passed! One Byte Offset."); end
         241      : begin $display("SH Passed! One Half-Word Offset."); end
         240      : begin $display("SW Passed! One Word Offset."); end
         238      : begin $display("SLL Passed!"); end
         239      : begin $display("SLT Passed!"); end
         237      : begin $display("SLTU Passed!"); end
         236      : begin $display("XOR Passed!"); end
         235      : begin $display("SRL Passed!"); end
         234      : begin $display("SRA Passed!"); end
         233      : begin $display("LUI Passed!"); end
         232      : begin $display("BEQ Passed!"); end
         231      : begin $display("BNE Passed!"); end
         230      : begin $display("BLT Passed!"); end
         229      : begin $display("BGE Passed!"); end
         228      : begin $display("BLTU Passed!"); end
         227      : begin $display("BGEU Passed!"); end
         226      : begin $display("LWU Passed!"); end
         225      : begin $display("ADDIW Passed!"); end
         224      : begin $display("SLLIW Passed!"); end
         223      : begin $display("SRLIW Passed!"); end
         222      : begin $display("SRAIW Passed!"); end
         221      : begin $display("ADDW Passed!"); end

          14      : begin $display("OR Passed!"); end
           0      : begin $display("Seltsame Null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"); end
           8      : begin $display("AND Passed!"); $display("Simulation succeeded"); #100; #(1*2*clk_2_t); $fdisplay(fd,"%s - allinstructions: Test ok", get_time()); $fclose(fd); $stop; end
          default : begin $display("Unexpected GPIO: 0x%0h", gpio_s); $fdisplay(fd,"%s - allinstructions: Test fail", get_time()); $fclose(fd); $stop;  end
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
