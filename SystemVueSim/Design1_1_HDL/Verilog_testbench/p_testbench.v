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

//------------------------------------------------------------------------------
//
// p_testbench
//
// Declares and defines useful functions and tasks for testbench operation.
//
//------------------------------------------------------------------------------

module p_testbench();
    
    real currentTime;
    reg DO_TIME_STAMPS = 1;

    task displaySimcompleteMsg; begin
        $display("");        
        $display("***** simulation complete *****");
        $display(""); end        
    endtask
    
endmodule 