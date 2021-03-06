// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    Copyright 2010-2011 Cadence Design Systems, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 


class tb_env extends uvm_component;

   `uvm_component_utils(tb_env)

   dut_regmodel regmodel; 
   apb_agent    apb;
   uvm_reg_sequence seq;
`ifdef EXPLICIT_MON
   uvm_reg_predictor#(apb_rw) apb2reg_predictor;
`endif

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      if (regmodel == null) begin
         regmodel = dut_regmodel::type_id::create("regmodel",,get_full_name());
         regmodel.build();
         regmodel.lock_model();
         
         apb = apb_agent::type_id::create("apb", this);
`ifdef EXPLICIT_MON
         apb2reg_predictor = new("apb2reg_predictor", this);
`endif
      end
      
      begin
        string hdl_root = "tb_top.dut";
        regmodel.set_hdl_path_root(hdl_root);
      end

   endfunction

   virtual function void connect_phase(uvm_phase phase);
      if (apb != null) begin
         reg2apb_adapter reg2apb = new;
         regmodel.default_map.set_sequencer(apb.sqr,reg2apb);
`ifdef EXPLICIT_MON
         apb2reg_predictor.map = regmodel.default_map;
         apb2reg_predictor.adapter = reg2apb;
         regmodel.default_map.set_auto_predict(0);
         apb.mon.ap.connect(apb2reg_predictor.bus_in);
`else
         regmodel.default_map.set_auto_predict(1);
`endif
      end
   endfunction

   virtual task reset_phase(uvm_phase phase);
      phase.raise_objection(this);

      `uvm_info("RESET","Performing reset of 5 cycles", UVM_NONE);
      tb_top.rst <= 1;
      repeat (5) @(posedge tb_top.clk);
      tb_top.rst <= 0;
      repeat (5) @(posedge tb_top.clk);

      regmodel.reset();

      phase.drop_objection(this);
   endtask

endclass

