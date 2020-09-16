module data_mem(
    input logic clk,
    input logic in_data_mem,
    input logic write_data,
    input logic [4:0]adr_data,
    input logic[4:0]adr_data_write,
    input logic [31:0]data_write,
    output logic [31:0]data,
    output logic out_data_mem
);

logic [31:0]DATA_MEM[0:15] = '{
    32'b1_10000000_00100100000000000000000,
    32'b0_10000001_11101110000000000000000,
    32'd3,
    32'd4,
    32'd10,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'b0_01111111_00110011001100110011011,
    32'd0,
    32'd0,
    32'd0
};

always_ff @(posedge clk)
begin
    if (in_data_mem==1'b1)
    begin
        data<=DATA_MEM[adr_data];
        out_data_mem <= 1'b1;
    end
    if (out_data_mem == 1'b1)
    begin
        out_data_mem <= 1'b0;
    end
    if(write_data==1'b1)
    begin
        DATA_MEM[adr_data_write]<=data_write;
    end
end

endmodule