module uart_tb();
	reg CLK;
	reg RSTn;
	reg rs232_rx;
	wire rs232_tx;

	reg  [7:0] 		mem [4:0];

initial $readmemh ("D:/Project/verilog_pro/project_module/sdram_controller/src/tx_data.txt",mem);

initial
 	begin
		RSTn = 0;
		//rs232_tx = 1;
		#100
		RSTn = 1;
		#100
		tx_byte();
	end


initial 
 	begin
		CLK = 0;
		forever #5 CLK = ~CLK;
	end
task tx_byte();
	integer i;
	for (i = 0; i < 5;i=i+1 )
		begin
			tx_bit(mem[i]);
		end
endtask

task tx_bit(
	input [7:0] data
);
	integer i;
	for (i = 0; i < 10;i=i+1 )
		begin
			case(i)
				0:	rs232_rx <= 1'b0;
				1:	rs232_rx <= data [0];
				2:	rs232_rx <= data [1];
				3:	rs232_rx <= data [2];
				4:	rs232_rx <= data [3];
				5:	rs232_rx <= data [4];
				6:	rs232_rx <= data [5];
				7:	rs232_rx <= data [6];
				8:	rs232_rx <= data [7];
				9:	rs232_rx <= 1'b1;
			endcase
			#560;
		end

endtask

uart_top uart_inst(.CLK			(CLK),
					.RSTn		(RSTn),
					.rs232_rx	(rs232_rx),
					.rs232_tx	(rs232_tx));
endmodule