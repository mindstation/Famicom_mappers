module hc161_like (
							input  wire [3:0] cpu_d
							, input  wire Ncpu_rw
							, input  wire Ncpu_rom_cs
							, output wire hc161_out0
							, output wire hc161_out1
							, output wire hc161_out2
							, output wire hc161_out3
							);
	reg [3:0] hc161_krn; //register for a bank number
	
	assign hc161_out0 = hc161_krn [0:0];
	assign hc161_out1 = hc161_krn [1:1];
	assign hc161_out2 = hc161_krn [2:2];
	assign hc161_out3 = hc161_krn [3:3];
	
	always @(posedge Ncpu_rom_cs) //Use Ncpu_rom_cs like CLK
	begin
		if (!Ncpu_rw) //Change register only if LOAD allow
		begin
			hc161_krn <= cpu_d; 
		end
	end
	
endmodule