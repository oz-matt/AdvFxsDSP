//-----------------------------------------------------------------------------
//
// FXPLib - Verilog source
//
// Copyright (C) 2008-2015 Steepest Ascent Ltd.
// www.steepestascent.com
//
// This source code is provided on an "as-is",
// unsupported basis. You may include this source
// code in your project providing this copyright
// message is included, unaltered.
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//
// EnableGenerator
//
//-----------------------------------------------------------------------------

module EnableGenerator # (
    parameter DivisionFactor = 2 ) 
(
    input clk,
    input rst,
    input en,
    output ce);

// begin body

    integer counter;
    localparam WRAP_VALUE  = DivisionFactor-1;

    reg     newEn;
        
    generate
        if (DivisionFactor == 1) begin

            assign ce  = en;
                            
        end else begin
            
            always@(posedge clk) begin    
                if (rst) begin
                    counter <= 0;
                    newEn   <= 1;                    
                end else if (en) begin
                    if (counter == WRAP_VALUE) begin
                        counter <= 0;
                        newEn   <= 1;
                    end else begin
                        counter <= counter + 1;
                        newEn   <= 0;
                    end
                end
            end

            assign ce  = en & newEn;
           
        end
    endgenerate
   
endmodule
