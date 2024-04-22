`timescale 1ns / 1ps

module sort_S_AXIS#
(
    parameter integer C_S_AXIS_TDATA_WIDTH	= 128
 )
(
    output wire res_fifo_valid,
    input wire res_fifo_rd_en,
    output wire [31:0] res_fifo_outdata,
    
    input wire  S_AXIS_ACLK,

	input wire  S_AXIS_ARESETN,
    output wire  S_AXIS_TREADY,
	input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
	input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,

	input wire  S_AXIS_TLAST,
	input wire  S_AXIS_TVALID
 );

    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction
	
	localparam NUMBER_OF_INPUT_WORDS  = 16;

	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1);
	
	(*mark_debug = "true"*)reg [3:0] aclk_state;
	reg [3:0] aclk_next;
	
	(*mark_debug = "true"*)reg [31:0] sort_1_indata;
    (*mark_debug = "true"*)wire sort_1_ready;
    (*mark_debug = "true"*)reg sort_1_valid;
    (*mark_debug = "true"*)reg [31:0] sort_2_indata;
    (*mark_debug = "true"*)wire sort_2_ready;
    (*mark_debug = "true"*)reg sort_2_valid;
    (*mark_debug = "true"*)reg [31:0] sort_3_indata;
    (*mark_debug = "true"*)wire sort_3_ready;
    (*mark_debug = "true"*)reg sort_3_valid;
    (*mark_debug = "true"*)reg [31:0] sort_4_indata;
    (*mark_debug = "true"*)wire sort_4_ready;
    (*mark_debug = "true"*)reg sort_4_valid;
    (*mark_debug = "true"*)wire [127:0] sort_outdata;
    (*mark_debug = "true"*)wire sort_valid;

    (*mark_debug = "true"*)reg [127:0] res_fifo_indata;
    (*mark_debug = "true"*)wire res_fifo_full;
    (*mark_debug = "true"*)reg res_fifo_wr_en;
    (*mark_debug = "true"*)wire res_fifo_empty;
    
    wire EOL_IN;
    wire VALID_IN;
    reg  READY_OUT;
    wire XFER_SI;

    assign EOL_IN = S_AXIS_TLAST;
    assign VALID_IN = S_AXIS_TVALID;
    assign S_AXIS_TREADY = READY_OUT;
    assign XFER_SI = VALID_IN & READY_OUT;
    
    reg [bit_num-1:0] write_pointer;
    
    parameter C_STATE_IDLE   = 0,
               C_STATE_A0_START   = 1,
               C_STATE_A0_WAIT = 2,
               C_STATE_LAST_START = 3,
               C_STATE_LAST_WAIT = 4,
               C_STATE_ERROR  = 5;
    
    always @ (posedge S_AXIS_ACLK)
    begin
        if (!S_AXIS_ARESETN ) begin
            write_pointer <= 0;
        end else begin  
            if (EOL_IN && XFER_SI) begin
                write_pointer <= 0;
            end else if (XFER_SI) begin
                write_pointer <= write_pointer + 1;
            end
        end
    end
    
    // State machine
    always @(posedge S_AXIS_ACLK) begin
      if (!S_AXIS_ARESETN) begin
        aclk_state <= C_STATE_IDLE;
      end else begin
        aclk_state <= aclk_next;
      end
    end
    
    always @(*) begin
      case (aclk_state) 
        C_STATE_IDLE: begin
            if ( VALID_IN)
                aclk_next = C_STATE_A0_START;
            else 
                aclk_next = C_STATE_IDLE;
        end
        C_STATE_A0_START: aclk_next = C_STATE_A0_WAIT;
        C_STATE_A0_WAIT: begin
            if (sort_valid) begin
                if (write_pointer == NUMBER_OF_INPUT_WORDS - 1)
                    aclk_next = C_STATE_LAST_START;
                else
                    aclk_next = C_STATE_A0_START;
            end else
                aclk_next = C_STATE_A0_WAIT;
        end
        C_STATE_LAST_START: aclk_next = C_STATE_LAST_WAIT;
        C_STATE_LAST_WAIT: begin
            if (sort_valid) aclk_next = C_STATE_IDLE;
            else aclk_next = C_STATE_LAST_WAIT;
        end

        C_STATE_ERROR: aclk_next = C_STATE_IDLE;
        default: aclk_next = C_STATE_ERROR;
      endcase
    end
    
    always @ (posedge S_AXIS_ACLK)
    begin
        if ( !S_AXIS_ARESETN ) begin
            //window_addr <= 0;
            sort_1_valid <= 0;
            sort_2_valid <= 0;
            sort_3_valid <= 0;
            sort_4_valid <= 0;
            READY_OUT <= 0;     
        end else begin
            case (aclk_next)
                C_STATE_IDLE: begin
                    //window_addr <= 0;
                    sort_1_valid <= 0;
                    sort_2_valid <= 0;
                    sort_3_valid <= 0;
                    sort_4_valid <= 0;
                    READY_OUT <= 0;
                end
                C_STATE_A0_START: begin
                    READY_OUT <= 1;
                    //window_addr <= window_addr + 1;
                    sort_1_indata <= S_AXIS_TDATA[31:0];
                    sort_2_indata <= S_AXIS_TDATA[63:32];
                    sort_3_indata <= S_AXIS_TDATA[95:64];
                    sort_4_indata <= S_AXIS_TDATA[127:96];
                    sort_1_valid <= 1;
                    sort_2_valid <= 1;
                    sort_3_valid <= 1;
                    sort_4_valid <= 1;
                end
                C_STATE_A0_WAIT: begin
                    READY_OUT <= 0;
                    sort_1_valid <= 0;
                    sort_2_valid <= 0;
                    sort_3_valid <= 0;
                    sort_4_valid <= 0;
                end
                C_STATE_LAST_START: begin
                    READY_OUT <= 1;
                    //window_addr <= window_addr + 1;
                    sort_1_indata <= S_AXIS_TDATA[31:0];
                    sort_2_indata <= S_AXIS_TDATA[63:32];
                    sort_3_indata <= S_AXIS_TDATA[95:64];
                    sort_4_indata <= S_AXIS_TDATA[127:96];
                    sort_1_valid <= 1;
                    sort_2_valid <= 1;
                    sort_3_valid <= 1;
                    sort_4_valid <= 1;
                end
                C_STATE_LAST_WAIT: begin
                    READY_OUT <= 0;
                    sort_1_valid <= 0;
                    sort_2_valid <= 0;
                    sort_3_valid <= 0;
                    sort_4_valid <= 0;
                end
                C_STATE_ERROR: begin

                end
            endcase
        end
    end

    always @ (*)
    begin
        if ( !S_AXIS_ARESETN ) begin
            res_fifo_indata <= 0;
            res_fifo_wr_en <= 0;
        end else begin
            if (sort_valid) begin
                res_fifo_indata <= sort_outdata;
                res_fifo_wr_en <= 1;
            end else begin
                res_fifo_indata <= res_fifo_indata;
                res_fifo_wr_en <= 0;
            end
        end
    end


fifo_generator_0 fifo_res_inst (
  .clk(S_AXIS_ACLK),      // input wire clk  
  .din(res_fifo_indata),      // input wire [127 : 0] din
  .wr_en(res_fifo_wr_en),  // input wire wr_en
  .rd_en(res_fifo_rd_en),  // input wire rd_en
  .dout(res_fifo_outdata),    // output wire [127 : 0] dout
  .full(res_fifo_full),    // output wire full
  .empty(res_fifo_empty),  // output wire empty
  .valid(res_fifo_valid)  // output wire valid
);

sort_core sort_mid (
  .clk(S_AXIS_ACLK),
  .rst(sort_1_valid),
  .in0(sort_1_indata), 
  .in1(sort_2_indata),
  .in2(sort_3_indata), 
  .in3(sort_4_indata), 
  .out(sort_outdata),
  .out_valid(sort_valid)
);

endmodule