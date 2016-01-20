
`timescale 1ns/1ps
module tb_top();

reg             clk;
reg             resetn;
reg     signed  [63:0]  A, B;
reg     [1:0]   opCode;
integer         wfid_1;
reg     [257:0] pattern[0:65535];
reg     [257:0] pattern_tmp_1;
reg     [257:0] pattern_tmp_2;
integer         i;
integer         j;

real            CYCLETIME;

wire    signed  [127:0] C;
wire            completed;

initial
begin
    wfid_1 = $fopen("ofile.txt");
    $fdisplay(wfid_1, "A B Your_C Correct_C Pass");
    $readmemh("ifile.txt", pattern);
    CYCLETIME = 0.5;
    clk = 0;
    resetn = 1;
    j=0;
    A = 0; B = 0; opCode = 0;
    #1;
    resetn = 0;
    #(CYCLETIME * 3)
    resetn = 1;

    #(CYCLETIME * 1) 
    for(i=0;i<10;i=i+1)
    begin
        pattern_tmp_1 = pattern[i];
        @(negedge clk);
        A = pattern_tmp_1[127:64]; B =pattern_tmp_1[63:0] ; opCode = pattern_tmp_1[257:256]; 
        @(negedge clk);
        A = 0; B = 0; opCode = 0;
        @(posedge clk);
    end
    #(CYCLETIME * 1) 
    #(CYCLETIME * 1) 
    $fclose(wfid_1);
    $finish;
end

always #(0.25) clk = ~clk;


reg     signed [127:0]  Correct_C;
always @(negedge clk)
begin
    if(completed)
    begin
        pattern_tmp_2 = pattern[j];
        A = pattern_tmp_2[127:64]; B =pattern_tmp_2[63:0]; Correct_C = pattern_tmp_2[255:128];
        //fdisplay(wfid_1, "%d %d %d %d", A, B, C, Correct_C);
        $fdisplay(wfid_1, "%x %x %x %x %d", A, B, C, Correct_C, (C==Correct_C));
        j=j+1;
    end
end


initial
begin
   $dumpfile ("tb_top.vcd"); 
   $dumpvars(0, tb_top); 
end


alu     u1( .resetn(resetn),
            .clk(clk),
            .A(A),
            .B(B),
            .C(C),
            .opCode(opCode),
            .completed(completed)
            );


endmodule

