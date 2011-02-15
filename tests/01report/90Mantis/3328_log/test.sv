//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
//   All Rights Reserved Worldwide 
// 
//   Licensed under the Apache License, Version 2.0 (the 
//   "License"); you may not use this file except in 
//   compliance with the License.  You may obtain a copy of 
//   the License at 
// 
//       http://www.apache.org/licenses/LICENSE-2.0 
// 
//   Unless required by applicable law or agreed to in 
//   writing, software distributed under the License is 
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
//   CONDITIONS OF ANY KIND, either express or implied.  See 
//   the License for the specific language governing 
//   permissions and limitations under the License. 
//----------------------------------------------------------------------

// Test the fix for mantis 3328 to verify that a UVM_LOG action does not
// call multiple outputs to stdout but that the file still gets logged.

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_component;
  UVM_FILE mcd1, mcd2, fp1;

  `uvm_component_utils(test)
  function new(string name, uvm_component parent);
    super.new(name,parent);

    mcd1 = $fopen("mcd1");
    mcd2 = $fopen("mcd2");
    fp1 = $fopen("fp1", "w");

  endfunction
  function void start_of_simulation();
    set_report_id_file("MCD", mcd1|mcd2|1);
    set_report_id_action("MCD", UVM_DISPLAY|UVM_LOG);

    set_report_id_file("STDOUT", 32'h8000_0001);
    set_report_id_action("STDOUT", UVM_DISPLAY|UVM_LOG);

    set_report_id_file("FP", fp1);
    set_report_id_action("FP", UVM_DISPLAY|UVM_LOG);
  endfunction
  task run;
    // Use errors so the post processing can verify we have the correct number
    `uvm_error("MCD", "Message for MCD");
    `uvm_error("STDOUT", "Message for STDOUT");
    `uvm_error("FP", "Message for FP");
    $display("*** UVM TEST EXPECT 3 UVM_ERROR ***");
    #1 global_stop_request();
  endtask
  function void report();
    string s1,s2,s3,s4,s5,s6,s7,s8,s9;
    int eof;

    $fclose(mcd1|mcd2);
    $fclose(fp1);

    fp1 = $fopen("mcd1","r");
    eof = $fscanf(fp1,"%s%s%s%s%s%s%s%s%s",s1,s2,s3,s4,s5,s6,s7,s8,s9);
    if(s9 != "MCD") $display("*** UVM TEST FAILED ***");
    eof = $fscanf(fp1,"%s",s1);
    if(eof != -1) $display("*** UVM TEST FAILED ***");
    
    fp1 = $fopen("mcd2","r");
    eof = $fscanf(fp1,"%s%s%s%s%s%s%s%s%s",s1,s2,s3,s4,s5,s6,s7,s8,s9);
    if(s9 != "MCD") $display("*** UVM TEST FAILED ***");
    eof = $fscanf(fp1,"%s",s1);
    if(eof != -1) $display("*** UVM TEST FAILED ***");
    
    fp1 = $fopen("fp1","r");
    eof = $fscanf(fp1,"%s%s%s%s%s%s%s%s%s",s1,s2,s3,s4,s5,s6,s7,s8,s9);
    if(s9 != "FP") $display("*** UVM TEST FAILED ***");
    eof = $fscanf(fp1,"%s",s1);
    if(eof != -1) $display("*** UVM TEST FAILED ***");
    
    $display("*** UVM TEST PASSED ***");
  endfunction
endclass

initial
  begin
     run_test();
  end

endmodule