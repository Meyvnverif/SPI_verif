class spi_slave_driver extends uvm_driver#(packet);

	`uvm_component_utils(spi_slave_driver)
  virtual spi_interface drv_if;
	//Default Constructor
  function new (string name = "spi_slave_driver", uvm_component parent = null);
	super.new(name,parent);
  endfunction
  packet req;
  //build phase
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	req = packet::type_id::create("req");
	uvm_config_db#(virtual spi_interface)::get(this,"","vif",drv_if);
  endfunction

  task run_phase(uvm_phase phase);
	forever begin
	seq_item_port.get_next_item(req);
	`uvm_info(get_type_name, $sformatf("inside driver run_phase"),UVM_LOW);   
	  drive();    
	seq_item_port.item_done();
	end
  endtask

 task drive();
	 wait(drv_if.PRESETN)
	 if(req.PWRITE==1)begin
	  @(posedge drv_if.spi_cb);
          drv_if.PADDR <= req.PADDR;
          drv_if.PWRITE <= req.PWRITE;
          drv_if.PWDATA <= req.PWDATA;
          drv_if.PSEL   <= req.PSEL;
          @(posedge drv_if.spi_cb);
          drv_if.PENABLE <= req.PENABLE;	
         foreach(req.PWDATA[i])begin	  	 
	 drv_if.MISO_IN <=req.PWDATA[i];	 
         `uvm_info(get_type_name(),$sformatf("The intf data is %0h and pkt data is %0h",drv_if.MISO_IN,req.PWDATA[i]),UVM_NONE)
	 @(posedge drv_if.spi_cb);
         end
	    
        `uvm_info(get_type_name(),$sformatf("The intf data is %0h and pkt data is %0h",drv_if.PWDATA,req.PWDATA),UVM_NONE)
        end
	else if(req.PWRITE==0) begin
	@(posedge drv_if.spi_cb);
	@(posedge drv_if.spi_cb);
	req.PRDATA = drv_if.PRDATA;
       	`uvm_info(get_type_name(),$sformatf("The intf data is %0h and pkt data is %0h",drv_if.PRDATA,req.PRDATA),UVM_NONE)
	end
	
        endtask
endclass
