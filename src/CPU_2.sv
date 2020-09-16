module cpu(
    input logic clk
);
logic [5:0]operation;
logic in_alu;
logic [31:0] operand1;
logic[31:0] operand2;
logic in_data_mem;
logic[31:0] result;
logic[31:0] result_final;
logic out_alu;
logic [3:0]adr_cmd;
logic [4:0]adr_data;
logic [4:0]adr_data_write;
logic [31:0]data;
logic out_data_mem;
logic in_cmd_mem;
logic [31:0]cmd;
logic out_cmd_mem;
logic [31:0]data_write;
logic write_data;

logic[4:0] adr1;
logic[4:0] adr2;
logic[4:0]adr_result[0:4];
logic [5:0]operation2[0:4];
logic [4:0]shamt_mas[0:4];
logic [4:0]shamt;
logic[5:0]op_mas[0:4];
logic[4:0] adr2_last;

logic [31:0]operand1_fpu;//fpu
logic [31:0]operand2_fpu;
logic [31:0]operand1_fpu_res;//fpu
logic [31:0]operand2_fpu_res;
logic [5:0]operation_fpu;
logic in_fpu;
logic [31:0]result_fpu;
logic out_fpu;

logic oper_dr[0:4];
logic [31:0]i = 0;
int k1 = 0;
int k2 = 0;
int k3 = 0;
int k4 = 0;
int g = 0;

logic flag_read_data1 = 1'b0;
logic flag_read_launch = 1'b0;
logic flag_decode_launch = 1'b0;
logic flag_operator_launch = 1'b0;
logic flag_exec_launch = 1'b0;
logic flag_write_launch = 1'b0;
logic flag_fpu_in =1'b0;
logic flag_res_fpu =1'b0;


alu alucpu(
    .clk(clk),
    .operation(operation),
    .op(op),
    .shamt(shamt),
    .in_alu(in_alu),
    .operand1(operand1),
    .operand2(operand2),
    .result(result),
    .out_alu(out_alu)
);

data_mem data_mem_cpu(
    .clk(clk),
    .in_data_mem(in_data_mem),
    .adr_data(adr_data),
    .adr_data_write(adr_data_write),
    .data(data),
    .data_write(data_write),
    .write_data(write_data),
    .out_data_mem(out_data_mem)
);

cmd_mem cmd_mem(
    .clk(clk),
    .in_cmd_mem(in_cmd_mem),
    .adr_cmd(adr_cmd),
    .cmd(cmd),
    .out_cmd_mem(out_cmd_mem)
);

fpu fpu_cpu(
    .operand1_fpu(operand1_fpu),
    .operand2_fpu(operand2_fpu),
    .operation_fpu(operation_fpu),
    .in_fpu(in_fpu),
    .clk(clk),
    .out_fpu(out_fpu),
    .result_fpu(result_fpu)
);

always_ff @(posedge clk)
begin

    if(g==0)
    begin
        flag_read_launch <= 1'b1;
    end

    if(g==1)
    begin
        flag_decode_launch <= 1'b1;
        flag_read_launch <= 1'b1;
    end

    if(g==3)
    begin
        flag_decode_launch <= 1'b1;
        flag_read_launch <= 1'b1;
        flag_operator_launch <=1'b1;
    end

    if(g==6)
    begin
        flag_decode_launch <= 1'b1;
        flag_read_launch <= 1'b1;
        flag_operator_launch <=1'b1;
        flag_exec_launch <= 1'b1;
    end

    if(g==10)
    begin
        flag_decode_launch <= 1'b1;
        flag_read_launch <= 1'b1;
        flag_operator_launch <=1'b1;
        flag_exec_launch <= 1'b1;
        flag_write_launch <= 1'b1;
    end

    if((flag_operator_launch==1'b0)&&(g>11)&&(flag_exec_launch==1'b0))
    begin
        flag_decode_launch <= 1'b1;
        flag_read_launch <= 1'b1;
        flag_operator_launch <=1'b1;
        flag_exec_launch <= 1'b1;
        flag_write_launch <= 1'b1;
    end

////////////////////////////////////////////////////////
    if(flag_read_launch==1'b1)
    begin
        in_cmd_mem<=1'b1;
        adr_cmd<= i;
        if (out_cmd_mem == 1'b1)
        begin
            in_cmd_mem<=1'b0;
            flag_read_launch<=1'b0;
            i <= i+1;
            g <= g+1;
        end
    end
////
    if(flag_decode_launch==1'b1)
    begin
        adr2_last <= cmd[20:16];
        adr1 <= cmd[25:21];
        adr2 <= adr2_last;
        op_mas[k1]<=cmd[31:26];
        adr_result[k1] <= cmd[15:11];
        operation2[k1] <= cmd[5:0];
        if(cmd[5:4]==2'b11) oper_dr[k1]<=1'b1;
        shamt_mas[k1]<=cmd[10:6];
        flag_decode_launch<=1'b0;
        g <= g+1;
        k1<=k1+1;
        if(k1==4)
        begin
            k1<=0;
        end
    end
///
    case(op_mas[k4])
    0:
    begin
        if(flag_operator_launch==1'b1)
        begin
            if(flag_read_data1==1'b0)
            begin
                in_data_mem <= 1'b1;
                adr_data<=adr1;
                if(out_data_mem==1'b1)
                begin
                    operand1<=data;
                    in_data_mem<=1'b0;
                    flag_read_data1 <=1'b1;
                end
            end
            if(flag_read_data1==1'b1)
            begin
                in_data_mem <= 1'b1;
                adr_data<=adr2;
                if(out_data_mem == 1'b1)
                begin
                    operand2 <= data;
                    in_data_mem<=1'b0;
                    flag_read_data1<=1'b0;
                    flag_operator_launch <= 1'b0;
                    g<=g+1;
                    k4<=k4+1;
                end
            end
        end
    end
    6'b11_11_11:
    begin
        i<={adr2,adr1,adr_result[k4],shamt_mas[k4],operation2[k4]};
        k1<=0;
        k2<=0;
        k3<=0;
        k4<=0;
        g<=0;
        flag_decode_launch <= 1'b0;
        flag_read_launch <= 1'b0;
        flag_operator_launch <=1'b0;
        flag_exec_launch <= 1'b0;
        flag_write_launch <= 1'b0;
        flag_read_data1 <= 1'b0;
    end
    default:
    begin
        if(flag_operator_launch==1'b1)
        begin
            in_data_mem <= 1'b1;
            adr_data<=adr1;
            if(out_data_mem==1'b1)
            begin
                if(flag_read_data1==1'b0)
                begin
                    operand1<=data;
                    flag_read_data1<=1'b1;
                end
                if(flag_read_data1==1'b1)
                begin
                    adr_result[k4]<=adr2;            
                    operand2<={adr_result[k4],shamt_mas[k4],operation2[k4]};
                    in_data_mem<=1'b0;
                    g<=g+1;
                    flag_operator_launch <= 1'b0;
                    flag_read_data1<=1'b0;
                    k4<=k4+1;
                end
            end
        end
    end
    endcase
////
    if(flag_exec_launch==1'b1)
    begin

        if(flag_res_fpu==1'b0)
        begin
            operand1_fpu <= operand1;
            operand2_fpu <= operand2;
            operation_fpu<=operation2[k2];
            flag_res_fpu<=1'b1;
        end

        if(op_mas[k2]==0)
        begin
            operation <= operation2[k2];
        end
        else
        begin
            operation <= op_mas[k2];
        end
        
        shamt<=shamt_mas[k2];

        if(in_fpu==1'b1) in_fpu<=1'b0;

        if((oper_dr[k2] == 1'b1)&&(flag_res_fpu==1'b0))
        begin
            if(flag_fpu_in==1'b0) 
            begin
                in_fpu<=1'b1;
                flag_fpu_in<=1'b1;
            end
        end

        if(out_fpu==1'b1)
        begin
            result_final<=result;
            flag_fpu_in<=1'b0;
            g<=g+1;
            flag_res_fpu<=1'b0;
            flag_exec_launch<=1'b0;
            k2<=k2+1;
            if(k2==4)
            begin
                k2<=0;
            end
        end

        if(oper_dr[k2] != 1'b1)
        begin
            in_alu<=1'b1;
            if(out_alu==1'b1)
            begin
                result_final<=result;
                in_alu <= 1'b0;
                g<=g+1;
                flag_exec_launch<=1'b0;
                k2<=k2+1;
                if(k2==4)
                begin
                    k2<=0;
                end
            end
        end

    end
////
    if(flag_write_launch==1'b1)
    begin
        adr_data_write<=adr_result[k3];
        write_data<=1'b1;
        data_write<=result_final;
        if(out_data_mem==1'b1)
        begin
            flag_write_launch<=1'b0;
            write_data<=1'b0;
            k3<=k3+1;
            g<=g+1;
            if(k3==4)
            begin
                k3<=0;
            end
        end
    end
end

endmodule
