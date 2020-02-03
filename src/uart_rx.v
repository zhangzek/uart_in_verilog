//********************************************************//
//****************uart receive module接收*****************//
//********************************************************//
`define SIM
module uart_rx#(
	parameter DATAWIDTH 		= 8,
	parameter BAUD_CNT_WIDTH 	= 12,
	parameter BIT_CNT_WIDTH 	= 4
)
(
	input 								CLK,
	input 								RSTn,
	input 								rs232_rx,//input data
	output reg 	[ DATAWIDTH - 1 : 0 ] 	rx_data,//receive data
	output reg 							po_flag //finish sig
);
`ifndef SIM
localparam BAUD_END = 5207;//simulate time too long,change to 56(560)
`else
localparam BAUD_END = 56;
`endif
localparam BAUD_M 	= BAUD_END / 2 - 1;
localparam BIT_END 	= 8;
 
reg 							rx_r1;
reg 							rx_r2;
reg 							rx_r3;
reg 							rx_flag;
reg [ BAUD_CNT_WIDTH - 1 : 0 ] 	baud_cnt;
reg 							bit_flag;
reg [ BIT_CNT_WIDTH - 1 : 0 ] 	bit_cnt;
wire 							rx_neg;//rx negedge

assign rx_neg = ~rx_r2 & rx_r3;

always @(posedge CLK or negedge RSTn) begin
	rx_r1 <= 0;
	rx_r2 <= 0;
	rx_r3 <= 0;
end

always @(posedge CLK) begin
	rx_r1 <= rs232_rx;
	rx_r2 <= rx_r1;
	rx_r3 <= rx_r2;
end

//rx_flag
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		rx_flag <= 0;
	end
	else if (rx_neg) begin
		rx_flag <= 1;
	end
	else if (bit_cnt == 0 && baud_cnt == BAUD_END) begin
		rx_flag <= 0;
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
	else if (rx_flag) begin
		baud_cnt <= baud_cnt + 1;
	end
	else begin
		baud_cnt <= 0;
	end
end

//bit_flag
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		bit_flag <= 0;
	end
	else if (baud_cnt == BAUD_M ) begin
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

//rx_data
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		rx_data <= 0;
	end
	else if (bit_flag == 1 && bit_cnt >= 1) begin
		rx_data <= { rx_r2, rx_data [ DATAWIDTH - 1 : 1 ] };
	end
end

//po_flag
always @(posedge CLK or negedge RSTn) begin
	if (!RSTn) begin
		// reset
		po_flag <= 0;
	end
	else if (bit_cnt == BIT_END && bit_flag == 1) begin
		po_flag <= 1;
	end
	else begin
		po_flag <= 0;
	end
end
endmodule