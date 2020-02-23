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
						output reg[3:0] PRG_A, //Extended program ROM address.						
						output wire nPRG_CE,
						output wire nWRAM_CE,
						output reg[4:0] CHR_A //Extended char ROM address.
						);
						
	//MMC1 registers
	reg[4:0] rLoad;				 		//MMC1 Load shift register with power on reset state 5'b00000. Quartus 13 can't make power-on on register like 10000. Only 00000 or 11111.
	reg[4:0] rControl; 					//MMC1 Control register with power on reset state 5'b00000.
	//Made inversion for rControl[3:2] in the code.
	reg[4:0] rPRG_b; 					//MMC1 PRG bank selector. With default power on reset state (all zeros) like MMC1C version.
	reg[4:0] rCHR_b0; 					//MMC1 CHR bank 0 selector.
	reg[4:0] rCHR_b1; 					//MMC1 CHR bank 1 selector. CHR is zero too, because it's default power on.
	
	assign nPRG_CE = nCPU_ROMSEL || !nCPU_RW; 		//Switch on ROM when a catridge was selected, and the mapper had not been written.
	assign nWRAM_CE = !(nCPU_ROMSEL && rPRG_b[4]); 	//If nCPU_ROMSEL is hight, then no ROM or mapper selection. Switch on W_RAM (active is low).
																	//Active signal is low (0).
	
	//Mirroring mode. Multiplexer4. 00 - One-screen Low. 01 - One-screen High. 10 - Two-screen vertical. 11 - Two-screen horizontal.
	assign CIRAM_A10 = rControl[1] ? (rControl[0] ? PPU_A11 : PPU_A10) : (rControl[0] ? 1'b1 : 1'b0);
	
	always @(negedge CPU_M2)
		begin
			if (nCPU_ROMSEL == 0 && nCPU_RW == 0) //Check nCPU_ROMSEL and CPU must be writting.
				begin
					if (CPU_D7)
						begin
							rLoad = 5'b00000; // The initial value.
							
							rControl = 5'b00000; //fixed last PRG bank at $C000, rControl[3:2] is inverted.
						end
					else
						begin							
							if (rLoad[0]) //Inintial 1 come to a zero position, 4 writes was made.
								begin
									case ({CPU_A14, CPU_A13})
										2'b00: rControl = {CPU_D0,~rLoad[4:3],rLoad[2:1]};
										2'b01: rCHR_b0 = {CPU_D0,rLoad[4:1]};
										2'b10: rCHR_b1 = {CPU_D0,rLoad[4:1]};
										2'b11: rPRG_b = {CPU_D0,rLoad[4:1]};
									endcase
									rLoad = 5'b00000; // Reset to inintial value
								end
							else
								begin
									if (rLoad == 0) rLoad = 5'b10000;
									rLoad = rLoad >> 1'b1;
									rLoad[4] = CPU_D0;
								end
						end
				end

			//PRG ROM bank switching mode.
			if (~rControl[3] == 1) //rControl is 2'b01000 or 2'b01100. Inverted logic.
				if (~rControl[2] == 1) //rControl = 2'b01100. Inverted logic.
					begin //Fix last bank at $C000 (CPU_A14 is high) and switch 16 KB bank at $8000 (CPU_A14 is low).
						PRG_A[0] = rPRG_b[0] || CPU_A14;
						PRG_A[1] = rPRG_b[1] || CPU_A14;
						PRG_A[2] = rPRG_b[2] || CPU_A14;
						PRG_A[3] = rPRG_b[3] || CPU_A14;
					end
				else //2'b01000. Inverted logic.
					begin //Fix first bank at $8000 (CPU_A14 is low) and switch 16 KB bank at $C000 (CPU_A14 is high).
						PRG_A[0] = rPRG_b[0] && CPU_A14;
						PRG_A[1] = rPRG_b[1] && CPU_A14;
						PRG_A[2] = rPRG_b[2] && CPU_A14;
						PRG_A[3] = rPRG_b[3] && CPU_A14;
					end				
			else //2'b00000, 2'b00100. Inverted logic.
				begin //Switch 32 KB at $8000.
					PRG_A = {rPRG_b[3:1],CPU_A14};
				end

			//CHR ROM bank switching mode.
			if (rControl[4]) 
				begin //If 1 then switch two separate 4 KB banks.
					//If the same value is in both CHR registers, 4KB mode causes erratic switching of bank
					//during rendering.
					if (PPU_A12)
						CHR_A = rCHR_b1;
					else
						CHR_A = rCHR_b0;
				end
			else //If 0 then switch 8 KB at a time.
				CHR_A = {rCHR_b0[4:1],PPU_A12};
				//It looks like a short circuit, if MMC1 CHR_A12 connected to ROM with PPU_A12. DON'T DO IT!
		end	
endmodule
