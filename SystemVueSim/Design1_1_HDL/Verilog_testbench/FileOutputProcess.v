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
// FileOutputProcess
//
//-----------------------------------------------------------------------------

 
module FileOutputProcess # (
    parameter RegisterLength = 0,
    parameter TestVectorFile = 0,
    parameter OutputSignage = 0 )
(
    input clk,
    input rst,
    input stop,
    input en,
    input [RegisterLength-1 : 0] dataIn );

// begin body

    reg fileOpen = 0;
    integer outFile;
    integer sample;
    
    always@(posedge clk) begin
        
        if (rst) begin
            
            if (!fileOpen) begin
                outFile = $fopen(TestVectorFile, "w");
                fileOpen = 1;
            end
        
        end else if ((stop === 1'b1) & fileOpen) begin
            
            $fclose(outFile);
            fileOpen  = 0;
        
        end else if (fileOpen & en) begin
            
            if(OutputSignage == "signed") begin                
                sample = $signed(dataIn);    
                $fwrite (outFile ,"%0d\n", $signed(sample));
            end else begin                
                sample = dataIn;
                $fwrite (outFile ,"%0d\n", $unsigned(sample));
            end
            
        end
    end
    
endmodule 