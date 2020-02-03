module uart_tx_tb;
	reg CLK;
	reg RSTn;
	reg tx_trig;
	reg [7:0] tx_data;

	wire rs232_tx;

initial
 	begin
		CLK = 1;
		forever #5 CLK = ~CLK;
	end

initial 
 	begin
		RSTn = 0;
		#100
		RSTn = 1;
	end

initial 
 	begin
		tx_data <= 0;
		tx_trig <= 0;
		#200
		tx_trig <= 1;
		tx_data <= 8'h55;
		#10
		tx_trig <= 0;
	end

uart_tx uart_tx_inst(.CLK(CLK),
					 .RSTn(RSTn),
					 .tx_data(tx_data),
					 .tx_trig(tx_trig),
					 .rs232_tx(rs232_tx)
	);

endmodule