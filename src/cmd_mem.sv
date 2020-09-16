module cmd_mem(
    input logic clk,
    input logic in_cmd_mem,
    input logic[3:0] adr_cmd,
    output logic [31:0]cmd,
    output logic out_cmd_mem
);

logic [31:0]CMD_MEM[0:4] = '{
    32'b000000_00001_00000_00000_00000_110000,
    32'b000000_00001_00000_00000_00000_110001,
    32'b000001_00011_00000_00000_00000_000011,
    32'b000001_00100_00000_00000_00000_000100,
    32'b111111_00000_00000_00000_00000_000001};//adress

always_ff @(posedge clk)
begin
    if(in_cmd_mem==1'b1)
    begin
        out_cmd_mem <= 1'b1;
        cmd <= CMD_MEM[adr_cmd];
    end
    if (in_cmd_mem == 1'b0)
    begin
        out_cmd_mem <= 1'b0;
    end
end

endmodule