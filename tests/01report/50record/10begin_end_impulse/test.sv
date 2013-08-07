//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2011 Mentor Graphics Corporation
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

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

uvm_report_object urm0 = new("urm0");
uvm_report_object urm1 = new("urm1");


class my_class extends uvm_object;
  int foo = 3;
  string bar = "hi there";
  `uvm_object_utils_begin(my_class)
    `uvm_field_int(foo, UVM_ALL_ON | UVM_DEC)
    `uvm_field_string(bar, UVM_ALL_ON)
  `uvm_object_utils_end
  function new (string name = "unnamed-my_class");
    super.new(name);
  endfunction
endclass

initial begin

    // User variables  
    uvm_trace_message l_trace_message;
    int l_tr_handle0, l_tr_handle1;
    int my_int;
    string my_string;
    my_class my_obj;

    // tell recorder not to record object reference
    uvm_default_recorder.identifier = 0;

    // Adjust action on urm1
    urm0.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);
    urm1.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);

    $display("START OF GOLD FILE");

    #5;

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");

    // Zero time consuming
    `uvm_info_begin(l_trace_message, "TEST_BEGIN", "Beginning...", UVM_LOW, urm0)
    `uvm_add_trace_tag(l_trace_message, "color", "red")
    `uvm_add_trace_int(l_trace_message, my_int, UVM_DEC)
    `uvm_add_trace_string(l_trace_message, my_string)
    `uvm_add_trace_object(l_trace_message, my_obj)
    `uvm_info_end(l_trace_message, "Ending...", l_tr_handle0)

    #5;

    my_string = "hey buddy";
    my_obj.foo = 7;
    my_obj.bar = "bar";

    // Zero time consuming
    `uvm_info_begin(l_trace_message, "TEST_BEGIN", "Beginning...", UVM_LOW, urm1)
    `uvm_add_trace_tag(l_trace_message, "color", "white")
    `uvm_add_trace_string(l_trace_message, my_string)
    `uvm_add_trace_object(l_trace_message, my_obj)
    `uvm_info_end(l_trace_message, "Ending...", l_tr_handle1)

    $display("END OF GOLD FILE");
end

endmodule