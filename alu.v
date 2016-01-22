
module alu(resetn,clk,A,B,opCode,C,completed);

input           resetn;
input           clk;
input   signed  [63:0]  A,B;
input   [1:0]   opCode;
output  signed  [127:0] C;
output          completed;

reg     signed  [127:0] C;
reg     signed  [63:0]  A_d1r,B_d1r;
reg             [1:0]   opCode_d1r;
reg             [1:0]   opCode_d2r;
reg             [1:0]   opCode_d3r;
wire    signed  [63:0]  A,B;
wire    signed  [64:0]  A_B_SUM;
wire    signed  [127:0] A_B_PROD;

always @(negedge resetn or posedge clk)
begin
    if(resetn==0)
    begin
        A_d1r <= 0;
        B_d1r <= 0;
    end
    else
    begin
        A_d1r <= A;
        B_d1r <= B;
    end
end

always @(negedge resetn or posedge clk)
begin
    if(resetn==0)
    begin
        C <= 0;
    end
    else
    begin
        case(opCode_d1r)
            'd0: C <= 0;
            'd1: C <= A_B_SUM;
            'd2: C <= A_B_PROD;
            'd3: C <= 0;
        endcase
    end
end

always @(negedge resetn or posedge clk)
begin
    if(resetn==0)
    begin
        opCode_d1r <= 0;
        opCode_d2r <= 0;
        opCode_d3r <= 0;
    end
    else
    begin
        opCode_d1r <= opCode;
        opCode_d2r <= opCode_d1r;
        opCode_d3r <= opCode_d2r;
    end
end

assign completed = (opCode_d2r!=0) && (opCode_d3r==0);

ADD     u1_ADD(
        .A(A_d1r[63:0]),
        .B(B_d1r[63:0]),
        .SUM(A_B_SUM[64:0])
        );

MUL     u1_MUL(
        .A(A_d1r[63:0]),
        .B(B_d1r[63:0]),
        .PROD(A_B_PROD[127:0])
        );

endmodule

module ADD(A,B,SUM);

input   signed [63:0] A, B;
output  signed [64:0] SUM;

wire signed [63:0] A;
wire signed [63:0] B;
wire signed [64:0] SUM;
// Your code starts here
//assign SUM = A + B;
wire Cin;
wire symbol;
wire [2:0] C_inter;
assign Cin = 1'b0;

C16_ADDER A0(
.A(A[15:0]),
.B(B[15:0]),
.C(Cin),
.Cout(C_inter[0]),
.S(SUM[15:0])
);

C16_ADDER A1(
.A(A[31:16]),
.B(B[31:16]),
.C(C_inter[0]),
.Cout(C_inter[1]),
.S(SUM[31:16])
);

C16_ADDER A2(
.A(A[47:32]),
.B(B[47:32]),
.C(C_inter[1]),
.Cout(C_inter[2]),
.S(SUM[47:32])
);

C16_ADDER A3(
.A(A[63:48]),
.B(B[63:48]),
.C(C_inter[2]),
.Cout(symbol),
.S(SUM[63:48])
);

// TODO 
// ADDING A NEW HIERARCHICAL LEVEL
// TEST PASSED 

assign SUM[64] = (A[63] ^ B[63]) ? SUM[63]:A[63];


// Your code ends here
endmodule

module ADD_carryout(A,B,SUM);

input   signed [63:0] A, B;
output  signed [64:0] SUM;

wire signed [63:0] A;
wire signed [63:0] B;
wire signed [64:0] SUM;
// Your code starts here
//assign SUM = A + B;
wire Cin;
wire [2:0] C_inter;
assign Cin = 1'b0;


C16_ADDER A0(
.A(A[15:0]),
.B(B[15:0]),
.C(Cin),
.Cout(C_inter[0]),
.S(SUM[15:0])
);

C16_ADDER A1(
.A(A[31:16]),
.B(B[31:16]),
.C(C_inter[0]),
.Cout(C_inter[1]),
.S(SUM[31:16])
);

C16_ADDER A2(
.A(A[47:32]),
.B(B[47:32]),
.C(C_inter[1]),
.Cout(C_inter[2]),
.S(SUM[47:32])
);

C16_ADDER A3(
.A(A[63:48]),
.B(B[63:48]),
.C(C_inter[2]),
.Cout(SUM[64]),
.S(SUM[63:48])
);


// TODO 
// ADDING A NEW HIERARCHICAL LEVEL
// TEST PASSED 



// Your code ends here
endmodule

// 1-bit carry lookahead adder
module C1_ADDER(A,B,C,G,P,S);
input A,B,C;
output G,P,S;

wire A,B,C;
wire G,P,S;
assign P = A ^ B;
assign G = A & B;
assign S = P ^ C;
endmodule

// 4-bit carry lookahead generator
module C_GEN(GIN,PIN,CIN,COUT,GOUT,POUT);
input [3:0] GIN,PIN;
input CIN;
output [2:0] COUT;
output GOUT,POUT;
wire [3:0] GIN,PIN;
wire CIN,GOUT,POUT;
wire [2:0] COUT;
assign COUT[0] = CIN & PIN[0] | GIN[0];
assign COUT[1] = COUT[0] & PIN[1] | GIN[1];
assign COUT[2] = COUT[1] & PIN[2] | GIN[2];
assign POUT = PIN[0] & PIN[1] & PIN[2] & PIN[3];
assign GOUT = COUT[2] & PIN[3] | GIN[3];
endmodule

// 4-bit carry lookahead adder
module C4_ADDER(A,B,C,G,P,S);
input [3:0] A,B;
input C;
output G,P;
output [3:0] S;
wire [3:0] A;
wire [3:0] B;
wire [3:0] S;
wire C,G,P;
wire [2:0]C_inter;
wire [3:0] G_inter,P_inter;

C1_ADDER AD0( A[0],B[0],C,G_inter[0],P_inter[0],S[0]);
C1_ADDER AD1( A[1],B[1],C_inter[0],G_inter[1],P_inter[1],S[1]);
//debugging C_inter[1]
C1_ADDER AD2( A[2],B[2],C_inter[1],G_inter[2],P_inter[2],S[2]);
C1_ADDER AD3( A[3],B[3],C_inter[2],G_inter[3],P_inter[3],S[3]);

C_GEN Carry_Gen(
.GIN(G_inter[3:0]),
.PIN(P_inter[3:0]),
.CIN(C),
.COUT(C_inter[2:0]),
.GOUT(G),
.POUT(P)
);
endmodule
// C16_ADDER(A,B,C,G,P,S)
module C16_ADDER(A,B,C,Cout,S);
input [15:0] A,B;
input C;
output [15:0] S;
output Cout;
wire [15:0] A,B;
wire [15:0] S;
wire C,Cout,G,P;
wire [2:0]C_inter;
wire [3:0] G_inter,P_inter;

C4_ADDER A0(
.A(A[3:0]),
.B(B[3:0]),
.C(C),
.G(G_inter[0]),
.P(P_inter[0]),
.S(S[3:0])
);
C4_ADDER A1(
.A(A[7:4]),
.B(B[7:4]),
.C(C_inter[0]),
.G(G_inter[1]),
.P(P_inter[1]),
.S(S[7:4])
);
C4_ADDER A2(
.A(A[11:8]),
.B(B[11:8]),
.C(C_inter[1]),
.G(G_inter[2]),
.P(P_inter[2]),
.S(S[11:8])
);
C4_ADDER A3(
.A(A[15:12]),
.B(B[15:12]),
.C(C_inter[2]),
.G(G_inter[3]),
.P(P_inter[3]),
.S(S[15:12])
);

// level 2 generator
C_GEN Carry_Gen(
.GIN(G_inter[3:0]),
.PIN(P_inter[3:0]),
.CIN(C),
.COUT(C_inter[2:0]),
.GOUT(G),
.POUT(P)
); 
assign Cout = C & P | G;
endmodule

module two_complement(IN,OUT);
input [127:0] IN;
output [127:0] OUT;
wire [127:0] IN;
wire [127:0] OUT;
wire [127:0] inter1;
wire one;
wire carry;
wire [62:0] zeros;
wire dumb;
assign zeros = 63'b0;
assign one = 1'b1;
assign inter1 = ~IN;
ADD_carryout add_1(inter1[63:0],{zeros[62:0],one},{carry,OUT[63:0]});
ADD_carryout add_2(inter1[127:64],{zeros[62:0],carry} ,{dumb,OUT[127:64]});

endmodule

module MUL(A,B,PROD);

input   signed [63:0] A, B;
output  signed [127:0] PROD;

wire signed [127:0] PROD;
// Your code starts here
wire signed [63:0] A;
wire signed [63:0] B;
wire [127:0] pre_PROD,s_PROD;
wire [63:0] zeros;
wire [65*63-1:0] inter_add;
wire [64*64-1:0] add_in;
wire [63:0] A_n,B_n;
wire [63:0] A_in,B_in;
wire [63:0] one;
wire numb1,numb2,numb3;
assign one = 64'b1;
assign zeros = 64'b0;
ADD twos_comp_A(~A, one, {numb1,A_n});
ADD twos_comp_B(~B, one, {numb2,B_n});
assign A_in = A[63]? A_n:A;
assign B_in = B[63]? B_n:B;
assign inter_add[62:0] = 63'b0;

genvar n;
  generate
    for (n=0; n<64; n=n+1) begin : adders
      assign add_in[n*64+63: n*64 ] = B_in[n] ? A_in:zeros;
      ADD u (.A(add_in[n*64 + 63 : n*64]), .B({1'b0, inter_add[n * 63 + 62 : n * 63]}), .SUM({ numb3, inter_add[(n+1) * 63 + 62 : (n+1) * 63 ] , pre_PROD[n]}));
    end
  endgenerate
assign pre_PROD[126:64] = inter_add[64*63 + 62 : 64*63  ];
assign pre_PROD[127] = 1'b0 ;
two_complement TC (pre_PROD,s_PROD);
assign PROD = (A[63] ^ B[63]) ? s_PROD:pre_PROD;
// Your code ends here
endmodule
