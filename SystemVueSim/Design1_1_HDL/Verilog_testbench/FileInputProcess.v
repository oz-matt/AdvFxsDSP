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
// FileInputProcess
//
//-----------------------------------------------------------------------------

module FileInputProcess # (
    parameter RegisterLength = 0,
    parameter DECIMATION_FACTOR = 0,
    parameter TestVectorFile = 0,
	parameter TimeStampTolerance = 0 )
(    
    input  clk, 
    input  rst,
    input  en,
    inout  stop,   
    output [RegisterLength-1 : 0] dataOut);

// begin body                                   

    reg      endOfFile = 0;    
    wire     EnableInternal;
    real     tvInTime;
    integer  tvInSample = 0;
    reg      open = 0;
    integer  infile;
    integer  result;
    reg      ReadyReg;
    
    
    assign dataOut          = tvInSample;

    assign stop           = (endOfFile) ? 1'b1 : 1'bz;
        
    always@(posedge clk) begin
        
        if (rst) begin
            
            if (!open) begin
                infile = $fopen(TestVectorFile, "r");
                open   = 1;
                result = $fscanf(infile,"%d\n", tvInSample);
            end
            
            endOfFile  = 0; end
        
        else if (stop === 1'b1) begin
            
            if(open) begin
                $fclose (infile);
                open = 0; 
            end end
        
        else if (en && open) begin
            
            if (!($feof(infile))) begin
                result = $fscanf(infile,"%d\n", tvInSample); end
            else begin
                $fclose(infile);
                open      = 0;
                endOfFile = 1;
            end
            
        end
    end
    
endmodule 
