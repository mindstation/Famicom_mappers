module hc161_like ( //Этот модуль описывает только одну часть маппера UNROM:
		//регистр, в который CPU записывает номер текущего банка памяти PRG ROM.
		//Вторая часть - микросхема содержащая сборку из четырех ИЛИ элементов, реализована графически.
 //This module only a part of an UNROM mapper. Register keeps a PRG ROM bank number.
 //The second part is 4 x OR chip. It's implemented graphically.
							input  wire [3:0] cpu_d
							, input  wire cpu_rw
							, input  wire Ncpu_romsel
							, output wire hc161_out0
							, output wire hc161_out1
							, output wire hc161_out2
							, output wire hc161_out3
							);
	reg [3:0] hc161_krn; //сам регистр, хранящий четырехбитное число - номер банка
			//register for a bank number
	
	assign hc161_out0 = hc161_krn [0:0];
	assign hc161_out1 = hc161_krn [1:1];
	assign hc161_out2 = hc161_krn [2:2];
	assign hc161_out3 = hc161_krn [3:3]; //выходы регистра
			//register outputs
	
	always @(posedge Ncpu_romsel) //сигнал обращения CPU к картриджу
			//Ncpu_romsel is a cartridge selecting signal
	begin
		if (!cpu_rw) //низкий уровень сигнала - CPU производит запись
			//low level - CPU make write to the cartridge
		begin
			hc161_krn <= cpu_d; 
		end
	end
	
endmodule
