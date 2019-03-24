module wholeMMC1 (
						input  wire CPU_M2,	//"Talk" CPU mode is low M2 (aka Fi2).
													//"Listen" CPU mode is high M2 (aka Fi2).
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
						output reg[4:0] CHR_A //Extended char ROM address. Five bits. The first one is taken by combinational logic.
						);
						
	//MMC1 registers
	reg[4:4] rLoad4 = 1'b1;
	reg[3:0] rLoad;				 		//MMC1 Load shift register (rLoad4 + rLoad) with power on reset state 5'b10000.
	reg[1:0] rControl32 = 2'b11;
	reg[2:0] rControl; 					//MMC1 Control register (rControl32 + rControl) with power on reset state 5'b01100.
	reg[4:0] rPRG_b; 						//MMC1 PRG bank selector. With default power on reset state (all zeros) like MMC1C version.
	reg[4:0] rCHR_b0; 					//MMC1 CHR bank 0 selector.
	reg[4:0] rCHR_b1; 					//MMC1 CHR bank 1 selector. CHR is zero too, because it's default power on.
	

	//Output registers
	reg[3:0] oPRG_A; //Extended program ROM address.
	
	//Connecting output wires
	assign PRG_A17 = oPRG_A[3];
	assign PRG_A16 = oPRG_A[2];
	assign PRG_A15 = oPRG_A[1];
	assign PRG_A14 = oPRG_A[0];
	
	assign nPRG_CE = nCPU_ROMSEL || !nCPU_RW; 		//Switch on ROM when a catridge was selected, and the mapper had not been written.
	assign nWRAM_CE = !(nCPU_ROMSEL && rPRG_b[4]); 	//If nCPU_ROMSEL is hight, then no ROM or mapper selection. Switch on W_RAM (active is low).
																	//Active signal is low (0).
	
	//Mirroring mode. Multiplexer4. 00 - One-screen Low. 01 - One-screen High. 10 - Two-screen vertical. 11 - Two-screen horizontal.
	assign CIRAM_A10 = rControl[1] ? (rControl[0] ? PPU_A11 : PPU_A10) : (rControl[0] ? 1'b1 : 1'b0);
	
	
	
	always @(negedge nCPU_ROMSEL) //nCPU_ROMSEL like clock, because nCPU_ROMSEL = !(CPU_A15 && M2). But #ROMSEL is later M2.
		begin
			if (CPU_M2 && !nCPU_RW) //Check nCPU_ROMSEL negedge because M2 changes, or CPU_A15? And CPU must be writting.
				begin
					if (CPU_D7)
						begin
							rLoad4 = 1'b1;
							rLoad = 4'b0000; // The initial value.
							
							rControl32 = 2'b11; //fixed last PRG bank at $C000, don't change other bits.
						end
					else
						begin							
							if (rLoad[0]) //Inintial 1 come to a zero position, 4 writes was made.
								begin
									case ({CPU_A14, CPU_A13})
										2'b00:
											begin
												rControl = {CPU_D0,rLoad[2:1]};
												rControl32 = {rLoad4[4],rLoad[3]};
											end
										2'b01: rCHR_b0 = {CPU_D0,rLoad4[4],rLoad[3:1]};
										2'b10: rCHR_b1 = {CPU_D0,rLoad4[4],rLoad[3:1]};
										2'b11: rPRG_b = {CPU_D0,rLoad4[4],rLoad[3:1]};
									endcase
									
									rLoad4 = 1'b1;
									rLoad = 4'b0000; // Reset to inintial value
								end
							else
								begin
									rLoad = rLoad >> 1'd1;
									rLoad[3] = rLoad4;
									rLoad4 = CPU_D0;
								end
						end
				end
		end
	
	always //Switching out async nCPU_ROMSEL
		begin
			//PRG ROM bank switching mode.
			if (rControl32[1]) //2'b10, 2'b11:
				if (rControl32[1] && rControl32[0]) //2'b11
					begin //Fix last bank at $C000 (CPU_A14 is high) and switch 16 KB bank at $8000 (CPU_A14 is low).
						oPRG_A[0] = rPRG_b[0] || CPU_A14;
						oPRG_A[1] = rPRG_b[1] || CPU_A14;
						oPRG_A[2] = rPRG_b[2] || CPU_A14;
						oPRG_A[3] = rPRG_b[3] || CPU_A14;
					end
				else //2'b10
					begin //Fix first bank at $8000 (CPU_A14 is low) and switch 16 KB bank at $C000 (CPU_A14 is high).
						oPRG_A[0] = rPRG_b[0] && CPU_A14;
						oPRG_A[1] = rPRG_b[1] && CPU_A14;
						oPRG_A[2] = rPRG_b[2] && CPU_A14;
						oPRG_A[3] = rPRG_b[3] && CPU_A14;
					end				
			else //2'b00, 2'b01:
				begin //Switch 32 KB at $8000.
					oPRG_A[3:1] = rPRG_b[3:1];
					oPRG_A[0] = rControl32[1] && CPU_A14;
				end
					
			if (rControl[2]) //CHR ROM bank switching mode.
				begin //If 1 then switch two separate 4 KB banks.
					//If the same value is in both CHR registers, 4KB mode causes erratic switching of bank
					//during rendering.
					if (PPU_A12)
						CHR_A = rCHR_b1;
					else
						CHR_A = rCHR_b0;
				end
			else //If 0 then switch 8 KB at a time.
				CHR_A[4:1] = rCHR_b0[4:1];
				CHR_A[0] = PPU_A12;
				//It looks like a short circuit, if MMC1 CHR_A12 connected to ROM with PPU_A12. DON'T DO IT!
			
		end
	
endmodule
