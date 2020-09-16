module alu(
    input logic clk,
    input logic in_alu,
    input logic[31:0] operand1,
    input logic[31:0] operand2,
    input logic [5:0]operation,
    input logic[5:0]op,
    input logic [4:0]shamt,
    output logic[31:0] result,
    output logic out_alu
);

logic [31:0]ii=0;
logic [31:0]g=0;

logic flag_shift=1'b0;
logic flag_del =1'b0;
logic flag_shift2 = 1'b0;

logic [31:0]operand1_use;
logic [31:0]R;
logic [31:0]Ri=0;
logic signed [31:0]D;

always_ff @(posedge clk)
begin

if(in_alu==1'b1)
begin
    case(operation)
        6'b001101:
        begin
            result <= operand1+operand2;
            out_alu <= 1'b1;
        end
        6'b000001:
        begin
            result <= operand1-operand2;
            out_alu <= 1'b1;
        end
        6'b000010:
        begin
            if(flag_shift==1'b0)
            begin
                ii<=operand2;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={operand1_use[14:0],1'b0};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b000011:
        begin
            if(flag_shift==1'b0)
            begin
                ii<=shamt;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={1'b0,operand1_use[15:1]};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b000100:
        begin
            result<=operand1<operand2;//<
            out_alu<=1'b1;
        end
        6'b000101:
        begin
            result<=operand1>operand2;//>
            out_alu<=1'b1;
        end
        6'b000110:
        begin
            result<=(operand1==operand2);//==
            out_alu<=1'b1;
        end
        6'b000111://>>arif
        begin
            if(flag_shift==1'b0)
            begin
                ii<=shamt;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={operand1_use[15],operand1_use[15:1]};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b001000://<<arif
        begin
            if(flag_shift==1'b0)
            begin
                ii<=shamt;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={operand1_use[14:0],operand1_use[15]};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b001001://>>cic
        begin
            if(flag_shift==1'b0)
            begin
                ii<=shamt;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={operand1_use[0],operand1_use[15:1]};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b001010://<<cic
        begin
            if(flag_shift==1'b0)
            begin
                ii<=shamt;
            end
            flag_shift<=1'b1;
            operand1_use<=operand1;
            if(flag_shift==1'b1)
            begin
                operand1_use<={operand1_use[14:0],operand1_use[15]};
                ii<=ii-1;
                if(ii==0)
                begin
                    result<=operand1_use;
                    out_alu <= 1'b1;
                    flag_shift<=1'b0;
                end
            end
        end
        6'b001011://*
        begin
            result<=operand1*operand2;
            out_alu<=1'b1;
        end
        // 4'b1101:
        // begin
        //     if(flag_shift==1'b0)
        //     begin
        //         ii <= 15;
        //         R<={Ri[15:1],operand1[ii]};
        //     end
        //     flag_shift<=1'b1;
        //     if(flag_shift==1'b1)
        //     begin
        //         D<=R-operand2;
        //         if(flag_del==1'b1)
        //         begin
        //             R<={Ri[15:1],operand1[ii]};
        //             ii<=ii-1;
        //         end
        //         if (D<0)
        //         begin
        //             Ri<=R;
        //             operand1_use[ii]<=1'b0;
        //             flag_del<=1'b1;
        //         end
        //         if ((D>0)||(D==0))
        //         begin
        //             Ri<=R-operand2;
        //             operand1_use[ii]<=1'b1;
        //             flag_del<=1'b1;
        //         end
        //         if(ii==0)
        //         begin
        //             result<=operand1_use;
        //             flag_shift<=1'b0;
        //             out_alu<=1'b1;
        //         end
        //     end
        // end
        6'b001100://del
        begin
            if(flag_shift2==1'b0)
            begin
                D<=(operand1-operand2);
                flag_shift2<=1'b1;
                ii<=0;
            end
            if(flag_shift2==1'b1)
            begin
                if(D>=0)
                begin
                    ii<=ii+1;
                    D<=D-operand2;
                end
                if(D<0)
                begin
                    result<=ii;
                    flag_shift2<=1'b0;
                    out_alu<=1'b1;
                end 
            end
        end
    endcase
    if (out_alu==1'b1)
    begin
        out_alu<=1'b0;
    end
end
end
endmodule