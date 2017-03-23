`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2017 12:49:39 PM
// Design Name: 
// Module Name: prescaler
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


module prescaler #
   (parameter integer SIZE = 4,
    parameter integer BITS = 32)
   (input [BITS*SIZE-1:0] div,
    input clk,
    output reg [SIZE-1:0]f = 0
    );
    
    reg [BITS-1:0] count = 0;
    reg [SIZE-1:0] state = 0;
    
    
    always @(posedge clk)
    begin      
      if (state == (1<<SIZE)-1) 
       count = 1;
      else
       count = count+1;
    end
        
    generate
    genvar i;
    for( i = 0; i < SIZE; i = i + 1)
     begin : gen            
     always @(posedge clk)
     begin
      if (count % div[BITS*(i+1)-1:BITS*i] == 0) 
       begin
        state[i] = 1;
        f[i] = !f[i];
       end
      else
       state[i] = 0;       
     end
     end
    endgenerate
    

    
endmodule
