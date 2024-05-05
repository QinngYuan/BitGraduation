`timescale 1ns / 1ps

module sort_core(clk, rst, in0, in1, in2, in3, out, out_valid);
                        
        input clk;
        input rst;
        input [31:0] in0, in1, in2, in3;//�����4����Ҫ�Ƚϵ�����
        reg [31:0] out_temp[3:0];//������ݷ����������
        output reg [127:0] out;//����ıȽϺ�Ľ��
        output reg out_valid;
        //���涨��ı������ڴ洢�ȽϽ������in0 > in1,��a0 <= 1,����a0 <= 0; 
        reg  a0, a1, a2;
        reg  b0, b1, b2;
        reg  c0, c1, c2;
        reg  d0, d1, d2;
            
        reg rst_valid = 1'b1;
        reg add_start; //�ñ������������жϱȽ��Ƿ�������ȽϽ�����ֵΪ1���������ģ��
        reg assignm_start; //�ñ������������ж����ģ��ִ���Ƿ������������ֵΪ1��������һ�����ģ��
        //���涨��ı������ڴ洢�����м�����ۼӽ������9��1λ2������������4λ��2�ģ�0,1,2,3���η����ۼӣ���ô4��1λ��2������������3λ��2�ģ�0,1,2�����ۼ�
        reg out_start;
        //reg [3:0] mid0, mid1, mid2, mid3, mid4, mid5, mid6, mid7, mid8, mid9;
        reg [2:0] mid0, mid1, mid2, mid3;//4 input numbers
        
        
        //�����㷨��FPGA�ڽ��У�ʵ�ֹ�����Ҫ�����¼������裺
        //1����һ��clk�����ݵ�ȫ�Ƚϳ���4������������������Ϊin0~in3;
        //2���ڶ���clk���Ƚ�ֵ�ۼӣ�mid0,mid1,mid2,mid3;
        //3��������clk��������ֵ�������Ӧ������ռ䣻
        //4�����ĸ�clk���������������
        //���бȽ�ģ�飨��һ��ʱ�ӣ�
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
                        if(in0 > in1) a0 <= 1'b1; //in0�����г��Լ�����������ݱȽϣ��������־��1
                        else a0 <= 1'b0;
                        if(in0 > in2) a1 <= 1'b1;
                        else a1 <= 1'b0;
                        if(in0 > in3) a2 <= 1'b1;
                        else a2 <= 1'b0;
                    
                        
                        if(in1 > in0) b0 <= 1'b1;//in1�����г��Լ�������ݱȽϣ����ڱ�־λ��1������Ϊ0
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
                        add_start <= 1; //�ȽϽ�����־����ӿ�ʼ��־
                    end
            
            end
    //���ģ�飬mid��i����ֵ������in��i��������������е�λ�ã����ڶ���ʱ�ӣ�
    always @ (posedge clk)
        begin
            if(add_start == 1)
                begin
                    mid0 <= a0 + a1 + a2; //��־λ��ӣ����ý������������λ��
                    mid1 <= b0 + b1 + b2;
                    mid2 <= c0 + c1 + c2;
                    mid3 <= d0 + d1 + d2;
                        
                end
                assignm_start <= 1;//��ӽ�������ֵ��ʼ��־
        end
        
        //���ģ�飬������õ����ݷ�����������У�������ʱ�ӣ�
    always @ (posedge clk)
        begin
            if(assignm_start == 1)
                begin
                    out_temp[mid0] <= in0;
                    out_temp[mid1] <= in1;
                    out_temp[mid2] <= in2;
                    out_temp[mid3] <= in3;
                    
                    out_start <= 1;//��ֵ�����������ʼ��־λ
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
