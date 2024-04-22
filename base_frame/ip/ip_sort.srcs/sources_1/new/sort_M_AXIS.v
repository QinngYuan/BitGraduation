`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 22:05:39
// Design Name: 
// Module Name: sort_M_AXIS
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sort_M_AXIS#
(
    parameter integer C_M_AXIS_TDATA_WIDTH	= 128,
	parameter integer C_M_START_COUNT	= 16
 )
(
    input wire res_fifo_valid,
        output reg res_fifo_rd_en,
        input wire [31:0] res_fifo_outdata,

		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
);
    localparam NUMBER_OF_OUTPUT_WORDS = 16;                                               
	                                                                                     
	// function called clogb2 that returns an integer which has the                      
	// value of the ceiling of the log base 2.                                           
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
	                                                                                     
	// WAIT_COUNT_BITS is the width of the wait counter.                                 
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);                      
	                                                                                     
	// bit_num gives the minimum number of bits needed to address 'depth' size of FIFO.  
	localparam bit_num  = clogb2(NUMBER_OF_OUTPUT_WORDS);                                
    reg [bit_num-1:0] read_pointer;

    reg VALID_OUT;
    wire READY_IN;
    reg EOL_OUT;
    reg [C_M_AXIS_TDATA_WIDTH-1 : 0] TDATA_OUT;
    
    assign M_AXIS_TLAST = EOL_OUT;
    assign READY_IN = M_AXIS_TREADY;
    assign M_AXIS_TDATA = TDATA_OUT;
    assign M_AXIS_TVALID = VALID_OUT;
    
    reg [2:0] curr_out_state;
    reg [2:0] next_out_state;
    
    parameter OUT_IDLE = 0, 
            OUT_START=1, OUT_START_LAST=2;
            //OUT_DETERMIN=6;

    always @ (*)
    begin
     VALID_OUT =
        ((curr_out_state == OUT_START || curr_out_state == OUT_START_LAST) && res_fifo_valid);//
    end
    
    always @ (*)
    begin
        if (VALID_OUT && READY_IN) begin
            if (curr_out_state == OUT_START || curr_out_state == OUT_START_LAST) begin
                res_fifo_rd_en = 1;
                TDATA_OUT = res_fifo_outdata;
            end else begin // if (curr_out_state == OUT_A1_LINE || curr_out_state == OUT_A1_LINE_LAST) begin
                res_fifo_rd_en = 0;
                TDATA_OUT = 0;
            end
        end else begin
            res_fifo_rd_en = 0;
            TDATA_OUT = 0;
        end
    end
    
    always @(posedge M_AXIS_ACLK)
    begin
        if (M_AXIS_ARESETN == 0) begin
            read_pointer <= 0;
        end else begin
            if (VALID_OUT && READY_IN)
                if (EOL_OUT) begin
                    read_pointer <= 0;
                end else 
                    read_pointer <= read_pointer + 1;
            else
                read_pointer <= read_pointer; 
        end
    end

    always @ (posedge M_AXIS_ACLK)
    begin
        if ( M_AXIS_ARESETN == 0 )
            curr_out_state <= OUT_IDLE;
        else
            curr_out_state <= next_out_state;
    end
    
    always @ (*)//process_line_starting or ipic_done_wire or curr_process_state)
    begin
        case (curr_out_state)
            OUT_IDLE:
            begin
                if (res_fifo_valid) 
                    next_out_state = OUT_START;
                else
                    next_out_state = OUT_IDLE;
            end
            OUT_START: begin
                if ((read_pointer == (NUMBER_OF_OUTPUT_WORDS - 2)) && VALID_OUT && READY_IN)//
                    next_out_state = OUT_START_LAST;
                else
                    next_out_state = OUT_START;
            end
            OUT_START_LAST: begin
                if (VALID_OUT && READY_IN) 
                    next_out_state = OUT_IDLE;
                else
                    next_out_state = OUT_START_LAST;
            end
            default:
                next_out_state = OUT_IDLE;
        endcase
    end

    always @(posedge M_AXIS_ACLK)
    begin
        if ( M_AXIS_ARESETN == 0 )
        begin
            EOL_OUT <= 0;
        end else begin
            case (next_out_state)
                OUT_IDLE: begin
                    EOL_OUT <= 0;
                end
                OUT_START: begin
                
                end
                OUT_START_LAST: begin
                    EOL_OUT <= 1;
                end
            endcase
        end
    end
    
endmodule
