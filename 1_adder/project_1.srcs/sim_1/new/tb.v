`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 10:29:11
// Design Name: 
// Module Name: testbench
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


module testbench;

    // Inputs
    reg [63:0] operand1;
    reg [63:0] operand2;
    reg cin;

    // Outputs
    wire [63:0] result;
    wire cout;
    // Instantiate the Unit Under Test (UUT)
    adder32 uut (
        .operand1(operand1), 
        .operand2(operand2), 
        .cin(cin), 
        .result(result), 
        .cout(cout)
    );
    initial begin
        // Initialize Inputs
        operand1 = 0;
        operand2 = 0;
        cin = 0;
        // Wait 100 ns for global reset to finish
        #100;
        // Add stimulus here
    end
    always #10 operand1[31:0] = $random; 
    always #10 operand1[63:32]=$random; //$random为系统任务，产生一个随机的32位数
    always #10 operand2[31:0] = $random;
    always #10 operand2[63:32]=$random;//表示等待10个单位时间(10ns)，即每过10ns，赋值一个随机的32位数
    always #10 cin = {$random} % 2; //加了拼接符，{$random}产生一个非负数，除2取余得到0或1
endmodule
