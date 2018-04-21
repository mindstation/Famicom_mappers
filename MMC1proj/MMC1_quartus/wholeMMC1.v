module wholeMMC1 (
						input  wire CPU_M2,
						input  wire CPU_A13,
						input  wire CPU_A14,
						input  wire nCPU_ROMSEL,
						input  wire CPU_D0,
						input  wire CPU_D7,
						input  wire nCPU_RW,
						input  wire PPU_A12,
						input  wire PPU_A11,
						input  wire PPU_A10,
						output wire CIRAM_A10,
						output wire PRG_A17,
						output wire PRG_A16,
						output wire PRG_A15,
						output wire PRG_A14,
						output wire nPRG_CE,
						output wire nWRAM_CE,
						output wire CHR_A16,
						output wire CHR_A15,
						output wire CHR_A14,
						output wire CHR_A13,
						output wire CHR_A12
						);
						
	//MMC1 registers
	reg[4:0] rLoad = 5'b10000; //MMC1 Load shift register with power on reset state.
	reg[4:0] rControl = 5'b01100; //MMC1 Control register with power on reset state.
	reg[4:0] rCHR_b0; //MMC1 CHR bank 0 selector.
	reg[4:0] rCHR_b1; //MMC1 CHR bank 1 selector.
	reg[4:0] rPRG_b; //MMC1 PRG bank selector.

	//Output registers
	reg[3:0] oPRG_A; //Extended program ROM address.
	reg[3:0] oCHR_A; //Extended char ROM address. Five bits. The first one is taken by combinational logic.
	
	//Connecting output wires
	assign PRG_A17 = oPRG_A[3];
	assign PRG_A16 = oPRG_A[2];
	assign PRG_A15 = oPRG_A[1];
	assign PRG_A14 = oPRG_A[0];
	
	assign nPRG_CE = nCPU_ROMSEL || !nCPU_RW; 	//Switch on ROM when a catridge was selected, and the mapper had not been written.
	assign nWRAM_CE = !nCPU_ROMSEL; 				//If nCPU_ROMSEL is hight, then no ROM or mapper selection. Switch on W_RAM (active is low).
															//Active signal is low (0).
	
	assign CHR_A16 = oCHR_A[4];
	assign CHR_A15 = oCHR_A[3];
	assign CHR_A14 = oCHR_A[2];
	assign CHR_A13 = oCHR_A[1];
	
	//CPU and PPU works with different clocks. Made a combinational logic (multiplexer) for the PPU bus.
	//A part of the CHR ROM bank switching mode. Multiplexer3.
	assign CHR_A12 = rControl[4] ? (PPU_A12 ? rCHR_b1[0] : rCHR_b0[0]) : PPU_A12;
		//It looks like a short circuit, if MMC1 CHR_A12 connected to ROM with PPU_A12. DON'T DO IT!
	
	//Mirroring mode. Multiplexer4. 00 - One-screen Low. 01 - One-screen High. 10 - Two-screen vertical. 11 - Two-screen horizontal.
	assign CIRAM_A10 = rControl[1] ? (rControl[0] ? PPU_A11 : PPU_A10) : (rControl[0] ? 1'b1 : 1'b0);
	
	
	
	always @(negedge CPU_M2) //"Talk" CPU mode is low M2 (aka Fi2).
										//"Listen" CPU mode is high M2 (aka Fi2). nCPU_ROMSEL = !(CPU_A15 && M2).
		begin
			if (!nCPU_ROMSEL) //#ROMSEL is later M2.
				begin
					if (!nCPU_RW) //CPU writes to the cartridge memory.
						begin
							if (CPU_D7)
								begin
									rLoad = 5'b10000; // The initial value.
									rControl = rControl || 5'b01100; //fixed last PRG bank at $C000, don't change other bits.
								end
							else
								begin
									if (rLoad[0]) //Inintial 1 come to a zero position, 4 writes was made.
										begin
											case ({CPU_A14, CPU_A13})
												2'b00: rControl = {CPU_D0,rLoad[4:1]};
												2'b01: rCHR_b0 = {CPU_D0,rLoad[4:1]};
												2'b10: rCHR_b1 = {CPU_D0,rLoad[4:1]};
												2'b11: rPRG_b = {CPU_D0,rLoad[4:1]};
											endcase
											rLoad = 5'b10000; // Reset to inintial value
										end
									else
										begin
											rLoad = rLoad >> 1'd1;							
											rLoad[4] = CPU_D0;							
										end							
								end
						end					
				end
			
			case ({rControl[3], rControl[2]}) //PRG ROM bank switching mode.
				2'b00, 2'b01: //Switch 32 KB at $8000.
					begin
						oPRG_A[3:1] = rPRG_b[3:1];
						oPRG_A[0] = CPU_A14;
					end
				2'b10: //Fix first bank at $8000 (CPU_A14 is low) and switch 16 KB bank at $C000 (CPU_A14 is high).
					begin
						if (CPU_A14) 
							oPRG_A = rPRG_b;
						else //First 16KB is fixed.
							oPRG_A = 4'b0000;
					end
				2'b11: //Fix last bank at $C000 (CPU_A14 is high) and switch 16 KB bank at $8000 (CPU_A14 is low).
					begin
						if (CPU_A14) 
							oPRG_A = 4'b1111;
						else //First 16KB is switchable.
							oPRG_A = rPRG_b;
					end
			endcase
					
			if (rControl[4]) //CHR ROM bank switching mode.
				begin //If 1 then switch two separate 4 KB banks.
					//If the same value is in both CHR registers, 4KB mode causes erratic switching of bank
					//during rendering.
					if (PPU_A12)
						oCHR_A[4:1] = rCHR_b1[4:1];
					else
						oCHR_A[4:1] = rCHR_b0[4:1];
				end
			else //If 0 then switch 8 KB at a time.
				oCHR_A[4:1] = rCHR_b0[4:1];
				//The last bit is PPU_A12 by the combinational logic.
			
		end
	
endmodule
