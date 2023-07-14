class apb_monitor extends uvm_monitor;

`uvm_component_utils(apb_monitor)
uvm_analysis_port#(packet)ap_mon;
virtual spi_interface mon_if;
packet pkt;
function new(string name = "apb_monitor", uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ap_mon = new("ap_mon",this);
pkt = packet::type_id::create("pkt");
uvm_config_db#(virtual spi_interface)::get(this,"","vif",mon_if);
endfunction
task run_phase(uvm_phase phase);
   forever begin
        @(posedge mon_if.PCLK);
        if(mon_if.PENABLE && mon_if.PWRITE && mon_if.PRESETN)begin
	pkt.PENABLE = mon_if.PENABLE; 
	pkt.PSEL    = mon_if.PSEL;
	pkt.PADDR   = mon_if.PADDR;
	pkt.PWDATA  = mon_if.PWDATA;
        pkt.PWRITE  = mon_if.PWRITE;
        	`uvm_info(get_type_name(), $sformatf(" addr = 0x%0h data = 0x%0h write = 0x%0h enable = %0h sel = %0h",
		pkt.PADDR,pkt.PWDATA,pkt.PWRITE,pkt.PENABLE,pkt.PSEL),UVM_LOW);  
        ap_mon.write(pkt);
	//repeat(3)@(mon_if.spi_cb);
        end
        if((mon_if.PWRITE == 0) && mon_if.PENABLE && mon_if.PRESETN) begin
	`uvm_info(get_type_name(), $sformatf(" Inside Read "),UVM_LOW);
	@(posedge mon_if.PCLK);
        pkt.PWRITE = mon_if.PWRITE;
        pkt.PADDR = mon_if.PADDR;	
	pkt.PRDATA = mon_if.PRDATA;
	pkt.PREADY = mon_if.PREADY;
        pkt.PSLVERR = mon_if.PSLVERR;
        `uvm_info(get_type_name(), $sformatf(" addr = 0x%0h data = 0x%0h write = 0x%0h",pkt.PADDR,pkt.PRDATA,pkt.PWRITE),UVM_LOW); 
       ap_mon.write(pkt);
       
end
	end
endtask
endclass
