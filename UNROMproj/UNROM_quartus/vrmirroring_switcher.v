module vrmirroring_switcher (
					input  wire mirr_control,
					input  wire ppu_a10,
					input  wire ppu_a11,
					output wire vram_a10
					);
		
	//Swith VRAM_A10 to PPU_A10 (vertical mirr) or PPU_A11 (horizontal mirr)
	assign vram_a10 = mirr_control ? ppu_a10 : ppu_a11;
	
endmodule