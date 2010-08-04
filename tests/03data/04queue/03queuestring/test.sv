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

//Field Macros:
//This test verifies that the basic funcitonality in uvm_field_queue_string
//macro works as expected.
//
//The macros which are tested are:
//  `uvm_field_queue_string

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record and set_config_int must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myobject extends uvm_sequence_item;
    string str1[$];
    string str2[$];

    `uvm_object_utils_begin(myobject)
      `uvm_field_queue_string(str1, UVM_DEFAULT)
      `uvm_field_queue_string(str2, UVM_DEFAULT)
    `uvm_object_utils_end
  endclass

  class test extends uvm_test;
    string cfg_field_set[$];
    string cfg_field_notset[$];

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_queue_string(cfg_field_set, UVM_DEFAULT)
      `uvm_field_queue_string(cfg_field_notset, UVM_DEFAULT)
    `uvm_component_utils_end

    myobject obj = new;
    task run;
      byte unsigned bytes[];
      myobject cp;
      string exp = {
        "----------------------------------------------------------------------\n",
        "Name                     Type                Size                Value\n",
        "----------------------------------------------------------------------\n",
        "obj                      myobject            -                       -\n",
        "  str1                   da(string)          5                       -\n",
        "    [0]                  string              7                 hello_0\n",
        "    [1]                  string              7                 hello_1\n",
        "    [2]                  string              7                 hello_2\n",
        "    [3]                  string              7                 hello_3\n",
        "    [4]                  string              7                 hello_4\n",
        "  str2                   da(string)          5                       -\n",
        "    [0]                  string              7                 howdy_0\n",
        "    [1]                  string              7                 howdy_1\n",
        "    [2]                  string              7                 howdy_2\n",
        "    [3]                  string              7                 goodbye\n",
        "    [4]                  string              7                 howdy_4\n",
        "----------------------------------------------------------------------\n"
      };

      obj.set_name("obj");

      if(cfg_field_set.size() != 3)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field is not set ***", UVM_NONE);
      else begin
        if(cfg_field_set[0] != "zero")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[0] is not set ***", UVM_NONE);
        if(cfg_field_set[1] != "one")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[1] is not set ***", UVM_NONE);
        if(cfg_field_set[2] != "two")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[2] is not set ***", UVM_NONE);
      end
      if(cfg_field_notset.size() != 0)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
 
      for(int i=0; i<5; ++i) begin
        obj.str1.push_back($sformatf("hello_%0d",i));
        obj.str2.push_back($sformatf("howdy_%0d",i));
      end

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.str2[3] = "goodbye";
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      uvm_default_packer.use_metadata = 1;
      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 88)
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, packed incorrectly ***", UVM_NONE);

      void'(obj.unpack_bytes(bytes));
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED unpack failed ***", UVM_NONE);


      uvm_default_printer.knobs.reference=0;
      if(exp != obj.sprint())
        uvm_report_info("FAILED", "*** UVM TEST FAILED print failed ***", UVM_NONE);

      obj.print();
      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

      recording_detail=UVM_LOW;
      begin_tr(obj);
      end_tr(obj);

      global_stop_request();
    endtask
  endclass

  initial begin
    set_config_int("*", "cfg_field_set", 3);
    set_config_string("*", "cfg_field_set[0]", "zero");
    set_config_string("*", "cfg_field_set[1]", "one");
    set_config_string("*", "cfg_field_set[2]", "two");
    run_test();
  end

endmodule
