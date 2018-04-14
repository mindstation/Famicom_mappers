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
	reg[4:0] rLoad; //MMC1 Load shift register.
	reg[4:0] rControl; //MMC1 Control register.
	reg[4:0] rCHR_b0; //MMC1 CHR bank 0 selector.
	reg[4:0] rCHR_b1; //MMC1 CHR bank 1 selector.
	reg[4:0] rPRG_b; //MMC1 PRG bank selector.

	always @(negedge CPU_M2) //"Talk" CPU mode is low M2 (aka Fi2).
										//"Listen" CPU mode is high M2 (aka Fi2). nCPU_ROMSEL = !(CPU_A15 && M2).
		begin
			if (rLoad == 5'b00000 && rControl == 5'b00000) //A "zero state" is a default power on reset state for FPGA registers.
				begin		//Make right MMC1 power on reset.
					rLoad = 5'b10000;
					rControl = 5'b01100;
				end

			nPRG_CE = nCPU_ROMSEL || !nCPU_RW; 	//Switch on ROM when a catridge was selected, and the mapper had not been written.
			nWRAM_CE = !nCPU_ROMSEL; 				//If nCPU_ROMSEL is hight, then no ROM or mapper selection. Switch on W_RAM (active is low).
															//Active signal is low (0).

			if (!nCPU_ROMSEL) //#ROMSEL is later M2.
				begin
					if (!nCPU_RW) //CPU writes cartridge memory.
						begin
							nPRG_CE = 1'b1; //Mapper listens. Switch off PRG_ROM (active is low).
							if (CPU_D7)
								begin
									rLoad = 5'b10000; // The initial value.
									rControl = rControl || 5'b01100; //fixed last PRG bank at $C000, don't change other bits.
								end
							else
								begin
									if (rLoad[0]) //Inintial 1 come to a zero position, 4 writes was made.
										begin
											case {CPU_A14, CPU_A13}
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
				
			case {rControl[1], rControl[0]} //Mirroring mode.			
				2'b00: CIRAM_A10 = 1'b0; //One-screen Low.
				2'b01: CIRAM_A10 = 1'b1; //One-screen High.
				2'b10: CIRAM_A10 = PPU_A10; //Two-screen vertical.
				2'b11: CIRAM_A10 = PPU_A11; //Two-screen horizontal.
			endcase
			
			case {rControl[3], rControl[2]} //PRG ROM bank switching mode.
				2'b00, 2'b01: //Switch 32 KB at $8000.
					begin
						PRG_A17 = rPRG_b[3];
						PRG_A16 = rPRG_b[2];
						PRG_A15 = rPRG_b[1];
						PRG_A14 = CPU_A14;
					end
				2'b10: //Fix first bank at $8000 (CPU_A14 is low) and switch 16 KB bank at $C000 (CPU_A14 is high).
					begin
						if (CPU_A14) 
							begin
								PRG_A17 = rPRG_b[3];
								PRG_A16 = rPRG_b[2];
								PRG_A15 = rPRG_b[1];
								PRG_A14 = rPRG_b[0];
							end
						else //First 16KB is fixed.
							begin
								PRG_A17 = 1'b0;
								PRG_A16 = 1'b0;
								PRG_A15 = 1'b0;
								PRG_A14 = 1'b0;
							end
					end
				2'b11: //Fix last bank at $C000 (CPU_A14 is high) and switch 16 KB bank at $8000 (CPU_A14 is low).
					begin
						if (CPU_A14) 
							begin								
								PRG_A17 = 1'b1;
								PRG_A16 = 1'b1;
								PRG_A15 = 1'b1;
								PRG_A14 = 1'b1;
							end
						else //First 16KB is switchable.
							begin
								PRG_A17 = rPRG_b[3];
								PRG_A16 = rPRG_b[2];
								PRG_A15 = rPRG_b[1];
								PRG_A14 = rPRG_b[0];
							end
					end
			endcase
					
			if (rControl[4]) //CHR ROM bank switching mode.
				begin //If 1 then switch two separate 4 KB banks.
					//If the same value is in both CHR registers, 4KB mode causes erratic switching of bank
					//during rendering.
					if (PPU_A12)
						begin							
							CHR_A16 = rCHR_b1[4];
							CHR_A15 = rCHR_b1[3];
							CHR_A14 = rCHR_b1[2];
							CHR_A13 = rCHR_b1[1];
							CHR_A12 = rCHR_b1[0];
						end
					else
						begin
							CHR_A16 = rCHR_b0[4];
							CHR_A15 = rCHR_b0[3];
							CHR_A14 = rCHR_b0[2];
							CHR_A13 = rCHR_b0[1];
							CHR_A12 = rCHR_b0[0];
						else
				end
			else //If 0 then switch 8 KB at a time.
				begin
					CHR_A16 = rCHR_b0[4];
					CHR_A15 = rCHR_b0[3];
					CHR_A14 = rCHR_b0[2];
					CHR_A13 = rCHR_b0[1];
					CHR_A12 = PPU_A12; //It looks like a short circuit, if 
						//MMC1 CHR_A12 connected to ROM with PPU_A12. DON'T DO IT!
				end
			
		end
	
endmodule
