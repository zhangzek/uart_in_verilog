//***********************************************************//
//******************uart transfer module发送*****************//
//***********************************************************//
`define SIM
module uart_tx#(
	parameter DATAWIDTH 		= 8,
	parameter BAUD_CNT_WIDTH 	= 32,
	parameter BIT_CNT_WIDTH 	= 4

)
(
	input 								CLK,
	input 								RSTn,
	input 		[ DATAWIDTH - 1 : 0 ] 	tx_data,//data
	input 								tx_trig,//transfer sig
	output  reg							rs232_tx//transfer data
);
`ifndef SIM
localparam BAUD_END = 5207;//simulate time too long,change to 56(560)
`else
localparam BAUD_END = 56;
`endif
localparam BAUD_M 	= BAUD_END / 2 - 1;
localparam BIT_END 	= 8;

reg [ DATAWIDTH - 1 : 0 	 ] 	tx_data_r;
reg 							tx_flag;
reg [ BAUD_CNT_WIDTH - 1 : 0 ] 	baud_cnt;
reg 							bit_flag;
reg [ BIT_CNT_WIDTH - 1 : 0  ] 	bit_cnt;
//reg                             rs232_tx_t;

//tx_data_r
always @(posedge CLK or  negedge RSTn) begin
	if (!RSTn) begin
		// reset
		tx_data_r <= 0;
	end
	else if (tx_trig == 1 && tx_flag == 0) begin
		tx_data_r <= tx_data;
	end
end


//tx_flag
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		tx_flag <= 0;
	end
	else if (tx_trig == 1 && tx_flag == 0) begin
		tx_flag <= 1;
	end
	else if (bit_cnt == BIT_END && bit_flag == 1) begin
		tx_flag <= 0;
	end
end
//baud_cnt
always @(posedge CLK or  negedge RSTn) begin
	if (!RSTn) begin
		// reset
		baud_cnt <= 0;
	end
	else if (baud_cnt == BAUD_END) begin
		baud_cnt <= 0;
	end
	else if (tx_flag) begin
		baud_cnt <= baud_cnt + 1;
	end
	else begin
		baud_cnt <= 0;
	end

end
//bit_flag
always @(posedge CLK or  negedge RSTn) begin
	if (!RSTn) begin
		// reset
		bit_flag <= 0;
	end
	else if (baud_cnt == BAUD_END) begin
		bit_flag <= 1;
	end
	else begin
		bit_flag <= 0;
	end
end
//bit_cnt
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		bit_cnt <= 0;
	end
	else if (bit_flag == 1 && bit_cnt == BIT_END) begin
		bit_cnt <= 0;
	end
	else if (bit_flag) begin
		bit_cnt <= bit_cnt + 1;
	end
end
//rs232_tx
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		rs232_tx <= 1;
	end
	else if (tx_flag) begin
		case(bit_cnt)
		0:		rs232_tx <= 0;
		1:		rs232_tx <= tx_data_r[0];
		2:		rs232_tx <= tx_data_r[1];
		3:		rs232_tx <= tx_data_r[2];
		4:		rs232_tx <= tx_data_r[3];
		5:		rs232_tx <= tx_data_r[4];
		6:		rs232_tx <= tx_data_r[5];
		7:		rs232_tx <= tx_data_r[6];
		8:		rs232_tx <= tx_data_r[7];
		default:rs232_tx <= 1;

		endcase
	end
	else begin
		rs232_tx <= 1;
	end
end

//assign rs232_tx = rs232_tx_t;
endmodule