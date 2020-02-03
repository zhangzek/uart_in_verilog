module uart_top(
	input 		CLK,
	input 		RSTn,
	input 		rs232_rx,
	output    	rs232_tx
);

//***************Main Code*************//
wire [7:0] rx_data;
wire tx_trig;
//reg  rs232_tx_t;



uart_rx uart_rx_inst(.CLK		(CLK		),
					 .RSTn		(RSTn		),
					 .rs232_rx	(rs232_rx	),
					 .rx_data	(rx_data	),
					 .po_flag	(tx_trig	));

uart_tx uart_tx_inst(.CLK		(CLK		),
					 .RSTn		(RSTn		),
					 .tx_data	(rx_data	),
					 .tx_trig	(tx_trig	),
					 .rs232_tx	(rs232_tx 	));

endmodule