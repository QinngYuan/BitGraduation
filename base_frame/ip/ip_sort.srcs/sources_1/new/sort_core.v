`timescale 1ns / 1ps

module sort_core(clk, rst, in0, in1, in2, in3, out, out_valid);
                        
        input clk;
        input rst;
        input [31:0] in0, in1, in2, in3;//输入的4个需要比较的数字
        reg [31:0] out_temp[3:0];//输出数据放入此数组中
        output reg [127:0] out;//输出的比较后的结果
        output reg out_valid;
        //下面定义的变量用于存储比较结果，如in0 > in1,则a0 <= 1,否则a0 <= 0; 
        reg  a0, a1, a2;
        reg  b0, b1, b2;
        reg  c0, c1, c2;
        reg  d0, d1, d2;
            
        reg rst_valid = 1'b1;
        reg add_start; //该变量的作用是判断比较是否结束，比较结束后赋值为1，进入相加模块
        reg assignm_start; //该变量作用在于判断相加模块执行是否结束，结束后赋值为1，进入下一个输出模块
        //下面定义的变量用于存储上述中间变量累加结果，（9个1位2进制数相加最多4位）2的（0,1,2,3）次方的累加，那么4个1位的2进制数相加最多3位，2的（0,1,2）的累加
        reg out_start;
        //reg [3:0] mid0, mid1, mid2, mid3, mid4, mid5, mid6, mid7, mid8, mid9;
        reg [2:0] mid0, mid1, mid2, mid3;//4 input numbers
        
        
        //排序算法在FPGA内进行，实现过程主要有以下几个步骤：
        //1、第一个clk，数据的全比较程序，4个数据排序，输入数据为in0~in3;
        //2、第二个clk，比较值累加，mid0,mid1,mid2,mid3;
        //3、第三个clk，把输入值赋给相对应的排序空间；
        //4、第四个clk，把排序结果输出；
        //并行比较模块（第一个时钟）
        always @ (posedge clk)
            begin
                if(rst&rst_valid)
                    begin
                        {a0, a1, a2} <= 3'b0000_0000_0;
                        {b0, b1, b2} <= 3'b0000_0000_0;
                        {c0, c1, c2} <= 3'b0000_0000_0;
                        {d0, d1, d2} <= 3'b0000_0000_0;
                    
                        {mid0, mid1, mid2, mid3} <= 
                        30'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
                        out <= 0;
                        add_start <= 0;
                        assignm_start <= 0;
                        out_start <= 0;
                        out_valid <= 0;
                        rst_valid <= 0;
                    end
                else
                    begin
                        if(in0 > in1) a0 <= 1'b1; //in0和所有除自己外的其他数据比较，大于则标志置1
                        else a0 <= 1'b0;
                        if(in0 > in2) a1 <= 1'b1;
                        else a1 <= 1'b0;
                        if(in0 > in3) a2 <= 1'b1;
                        else a2 <= 1'b0;
                    
                        
                        if(in1 > in0) b0 <= 1'b1;//in1和所有除自己外的数据比较，大于标志位置1，否则为0
                        else b0 <= 1'b0;
                        if(in1 > in2) b1 <= 1'b1;
                        else b1 <= 1'b0;
                        if(in1 > in3) b2 <= 1'b1;
                        else b2 <= 1'b0;
                        
                        
                        if(in2 > in0) c0 <= 1'b1;
                        else c0 <= 1'b0;
                        if(in2 > in1) c1 <= 1'b1;
                        else c1 <= 1'b0;
                        if(in2 > in3) c2 <= 1'b1;
                        else c2 <= 1'b0;
                        
                        
                        if(in3 > in0) d0 <= 1'b1;
                        else d0 <= 1'b0;
                        if(in3 > in1) d1 <= 1'b1;
                        else d1 <= 1'b0;
                        if(in3 > in2) d2 <= 1'b1;
                        else d2 <= 1'b0;
                        
                        rst_valid <= 0;
                        add_start <= 1; //比较结束标志，相加开始标志
                    end
            
            end
    //相加模块，mid（i）的值代表着in（i）所在输出数组中的位置，（第二个时钟）
    always @ (posedge clk)
        begin
            if(add_start == 1)
                begin
                    mid0 <= a0 + a1 + a2; //标志位相加，所得结果就是其所在位置
                    mid1 <= b0 + b1 + b2;
                    mid2 <= c0 + c1 + c2;
                    mid3 <= d0 + d1 + d2;
                        
                end
                assignm_start <= 1;//相加结束，赋值开始标志
        end
        
        //输出模块，将排序好的数据放入输出数组中（第三个时钟）
    always @ (posedge clk)
        begin
            if(assignm_start == 1)
                begin
                    out_temp[mid0] <= in0;
                    out_temp[mid1] <= in1;
                    out_temp[mid2] <= in2;
                    out_temp[mid3] <= in3;
                    
                    out_start <= 1;//赋值结束，输出开始标志位
                end
        end
    always @ (posedge clk)
        begin
            if(out_start == 1)
                begin
                    out[31:0] <= out_temp[0];
                    out[63:32] <= out_temp[1];
                    out[95:64] <= out_temp[2];
                    out[127:96] <= out_temp[3];
                    out_valid <= 1;
                    rst_valid <=1;
                end         
        end
     
endmodule
