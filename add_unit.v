module Add(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);

wire carry;
wire [31:0] res;
ahead_addr16 cla_1(
    .cin(1'b0),
    .a(a[15:0]),
    .b(b[15:0]),
    .sum(res[15:0]),
    .carry(carry)
);

ahead_addr16 cla_2(
    .cin(carry),
    .a(a[31:16]),
    .b(b[31:16]),
    .sum(res[31:16]),
    .carry(carry_out)
);

always @(*) begin
    sum <= res;
end

endmodule

module ahead_addr4(
    input cin,
    input [3:0] a,
    input [3:0] b,
    output [3:0] sum,
    output carry
);

wire [3:0] p, g, c;

assign p = a ^ b;
assign g = a & b;

assign c[0] = g[0] | (cin&p[0]);
assign c[1] = g[1] | (p[1]&g[0]) | (p[1]&p[0]&cin);
assign c[2] = g[2] | (p[2]&g[1]) | (p[2]&p[1]&g[0]) | (p[2]&p[1]&p[0]&cin);
assign carry = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]) | (p[3]&p[2]&p[1]&p[0]&cin);

assign sum[0]=a[0]^b[0]^cin;
assign sum[1]=a[1]^b[1]^c[0];
assign sum[2]=a[2]^b[2]^c[1];
assign sum[3]=a[3]^b[3]^c[2];

endmodule

module ahead_carry(
    input cin,
    input [15:0] G,
    input [15:0] P,
    output [3:0] cout
);

reg [3:0] g;
reg [3:0] p;

always @(*) begin
    g[0] = G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0];
    g[1] = G[7] | P[7]&G[6] | P[7]&P[6]&G[5] | P[7]&P[6]&P[5]&G[4];
    g[2] = G[11] | P[11]&G[10] | P[11]&P[10]&G[9] | P[11]&P[10]&P[9]&G[8];
    g[3] = G[15] | P[15]&G[14] | P[15]&P[14]&G[13] | P[15]&P[14]&P[13]&G[12];

    p[0] = P[3]&P[2]&P[1]&P[0];
    p[1] = P[7]&P[6]&P[5]&P[4];
    p[2] = P[11]&P[10]&P[9]&P[8];
    p[3] = P[15]&P[14]&P[13]&P[12];
end

assign cout[0] = g[0] | (cin&p[0]);
assign cout[1] = g[1] | (p[1]&g[0]) | (p[1]&p[0]&cin);
assign cout[2] = g[2] | (p[2]&g[1]) | (p[2]&p[1]&g[0]) | (p[2]&p[1]&p[0]&cin);
assign cout[3] = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]) | (p[3]&p[2]&p[1]&p[0]&cin);

endmodule

module ahead_addr16(
    input cin,
    input [15:0] a,
    input [15:0] b,
    output [15:0] sum,
    output carry
);

wire [15:0] p;
wire [15:0] g;

assign p = a ^ b;
assign g = a & b;

wire [3:0] carry_out;

ahead_carry cla_carry(
    .cin(cin),
    .G(g),
    .P(p),
    .cout(carry_out)
);

ahead_addr4 cla4_0(
    .cin(cin),
    .a(a[3:0]),
    .b(b[3:0]),
    .sum(sum[3:0]),
    .carry()
);

ahead_addr4 cla4_1(
    .cin(carry_out[0]),
    .a(a[7:4]),
    .b(b[7:4]),
    .sum(sum[7:4]),
    .carry()
);

ahead_addr4 cla4_2(
    .cin(carry_out[1]),
    .a(a[11:8]),
    .b(b[11:8]),
    .sum(sum[11:8]),
    .carry()
);

ahead_addr4 cla4_3(
    .cin(carry_out[2]),
    .a(a[15:12]),
    .b(b[15:12]),
    .sum(sum[15:12]),
    .carry(carry)
);

endmodule