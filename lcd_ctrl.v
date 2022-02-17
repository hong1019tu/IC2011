module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [2:0] cmd;
input cmd_valid;
output reg IROM_EN;
output reg [5:0] IROM_A;
output reg IRB_RW;//enable when 0
output reg [7:0] IRB_D;
output reg [5:0] IRB_A;
output reg busy;
output reg done;//all finish when 1
reg [5:0]addr;
reg [2:0]x,y;
reg [7:0] arr [63:0];
reg [1:0] load,load2;
wire [9:0] average;

assign average=(arr[addr] + arr[addr+1] + arr[addr+8] + arr[addr+9])>>2;
always @(posedge clk or posedge reset) begin
    if(reset)begin
      IROM_EN <= 1'd1;
      IRB_RW <= 1'd1;
      IRB_A <= 6'd0;
      busy <= 1'd1;
      done <= 1'd0;
      load <= 2'd0;//for all
      load2 <= 2'd0;//for write
    end
    else begin
      if(load == 2'd0)begin
         IROM_EN <= 1'd0;
         IROM_A <= 6'd0;
         load <= load + 1;
      end
      else if(load < 2)begin//endnot
        if (IROM_A == 63) begin
          IROM_EN <= 1'd1;
          x <= 3;
          y <= 3;
          load <= load + 1;
        end
        else begin
          IROM_A<=IROM_A+1;
        end
        arr[IROM_A-1] <= IROM_Q;
      end
      else if(load == 2)begin
        load <= 3;
        arr[63] <= IROM_Q;
        busy <= 1'd0;
      end
      else begin
        case (cmd)
            3'd0:begin//write
              if(load2 == 2'd0)begin
                IRB_RW <= 0;
                busy <= 1'd1;
                load2 <= load2 + 1; 
              end      
              else if (load2 == 2'd1) begin
                IRB_D <= arr[0];
                load2 <= load2 + 1;
              end
              else begin
                if(IRB_A==63)begin
                  done<=1;
                end
                else  begin
                  IRB_A<=IRB_A+1;
                end
                IRB_D<=arr[IRB_A+1];               
              end
            end
            3'd1:begin//u
              if (y > 0) begin
                y <= y - 1;
              end
            end
            3'd2:begin//d
              if (y < 6) begin
                y <= y + 1;
              end
            end
            3'd3:begin//l
              if (x > 0) begin
                x <= x - 1;
              end
            end
            3'd4:begin//r
              if (x < 6) begin
                x <= x + 1;
              end
            end
            3'd5:begin//avg
              arr[addr] <= average;
              arr[addr+1] <= average;
              arr[addr+8] <= average;
              arr[addr+9] <= average;                
            end
            3'd6:begin//m_x
              arr[addr] <= arr[addr+8];
              arr[addr+8] <= arr[addr];
              arr[addr+1] <= arr[addr+9];
              arr[addr+9] <= arr[addr+1];
            end
            3'd7:begin//m_y
              arr[addr] <= arr[addr+1];
              arr[addr+1] <= arr[addr];
              arr[addr+8] <= arr[addr+9];
              arr[addr+9] <= arr[addr+8];
            end  
        endcase
      end
    end 
end//always
always @(*) begin
  addr <= (y << 3) + x;
end
endmodule


