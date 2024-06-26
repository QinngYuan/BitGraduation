`timescale 1ns / 1ps

module sort #
(
    parameter integer C_S_AXIS_TDATA_WIDTH	= 128,

	parameter integer C_M_AXIS_TDATA_WIDTH	= 128,
	parameter integer C_M_AXIS_START_COUNT	= 64
)
(
    input wire  aclk,
	input wire  aresetn,
	(*mark_debug = "true"*)output wire  s_axis_tready,
	(*mark_debug = "true"*)input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
	(*mark_debug = "true"*)input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
	(*mark_debug = "true"*)input wire  s_axis_tlast,
	(*mark_debug = "true"*)input wire  s_axis_tvalid,

		// Ports of Axi Master Bus Interface M_AXIS
	(*mark_debug = "true"*)output wire  m_axis_tvalid,
	(*mark_debug = "true"*)output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
	(*mark_debug = "true"*)output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
	(*mark_debug = "true"*)output wire  m_axis_tlast,
	(*mark_debug = "true"*)input wire  m_axis_tready
    );
    wire res_fifo_valid;
    wire res_fifo_rd_en;
    wire [127:0] res_fifo_outdata;
        
// Instantiation of Axi Bus Interface S_AXIS
	sort_S_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH)
	) sort_S_AXIS_inst (
	    .res_fifo_valid(res_fifo_valid),
        .res_fifo_rd_en(res_fifo_rd_en),
        .res_fifo_outdata(res_fifo_outdata),
	
		.S_AXIS_ACLK(aclk),
		.S_AXIS_ARESETN(aresetn),
		.S_AXIS_TREADY(s_axis_tready),
		.S_AXIS_TDATA(s_axis_tdata),
		.S_AXIS_TSTRB(s_axis_tstrb),
		.S_AXIS_TLAST(s_axis_tlast),
		.S_AXIS_TVALID(s_axis_tvalid)
	);

// Instantiation of Axi Bus Interface M_AXIS
	sort_M_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M_AXIS_START_COUNT)
	) sort_M_AXIS_inst (
        .res_fifo_valid(res_fifo_valid),
        .res_fifo_rd_en(res_fifo_rd_en),
        .res_fifo_outdata(res_fifo_outdata),
        
		.M_AXIS_ACLK(aclk),
		.M_AXIS_ARESETN(aresetn),
		.M_AXIS_TVALID(m_axis_tvalid),
		.M_AXIS_TDATA(m_axis_tdata),
		.M_AXIS_TSTRB(m_axis_tstrb),
		.M_AXIS_TLAST(m_axis_tlast),
		.M_AXIS_TREADY(m_axis_tready)
	);
endmodule

