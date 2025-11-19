`timescale 1ns/1ps

import as_pack::*;

module as_memstage (input  logic zero_i,
                    input  logic branch_s_i,
                    input  logic jump_s_i,
                    output logic pc_src_o
                   );

  assign pc_src_o = (zero_i & branch_s_i) | jump_s_i;

endmodule : as_memstage
