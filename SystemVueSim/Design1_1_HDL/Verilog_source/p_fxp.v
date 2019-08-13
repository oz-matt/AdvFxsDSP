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
// p_fxp
//
// Declares and defines modules for performing fixedpoint conversion.
//
//-----------------------------------------------------------------------------

`timescale 1ns/10ps
// Overflow modes
`define OVF_SAT       0  // input signal to be processed
`define OVF_SAT_ZERO  1   // fixedpoint type of input
`define OVF_SAT_SYM   2   // fixedpoint type of result
`define OVF_WRAP      3   // quantization mode
`define OVF_WRAP_SM   4   // overflow mode

// Quantization modes    
`define QZN_RND             3'b000     //Rounding to plus infinity
`define QZN_RND_ZERO        3'b001     //Rounding to zero
`define QZN_RND_MIN_INF     3'b010     //Rounding to minus infinity
`define QZN_RND_INF         3'b011     //Rounding to infinity     
`define QZN_RND_CONV        3'b100     //Convergent rounding
`define QZN_TRN             3'b101     //Truncation
`define QZN_TRN_ZERO        3'b110     //Truncation to zero

module fxpconvert(y, x);

    parameter xWL = 0, xIWL = 0, xSGN = 0, xFWL = xWL - xIWL;
    parameter yWL = 0, yIWL = 0, ySGN = 0, yFWL = yWL - yIWL;
    parameter qWL = yWL + xIWL - yIWL + 1, qIWL = xIWL + 1, qSGN = xSGN, qFWL = qWL - qIWL;
    parameter quantMode = 0, ovfMode = 0, satBits = 0;
    parameter LSBsToDelete = xFWL - yFWL, MSBsToDelete = qIWL - yIWL;

    input [xWL - 1 : 0] x;

    output[yWL - 1: 0] y;
    wire [yWL - 1: 0] y;
    wire [yWL - 1: 0] temp;

    wire signed [xWL : 0] rs;
    wire [xWL : 0] ru;
    
    wire signed [qWL-1 :0] qs;
    wire [qWL-1 : 0] qu;

    wire [qWL-1 : 0] qs2u;
    wire signed [qWL : 0] qu2s;
    wire signed [yWL - 1: 0] yqu2s;
    
    
//---------------------------------------------------------------------------------------------------
// Function declarations ----------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------- 
    function [qWL-1 : 0] s2us;
        input xMSB;
        input [qWL-1 :0] x;
    
        begin
        if ((ovfMode <= 2) & xMSB)
            s2us = 0;
            else
            s2us = x;
    end
    endfunction
    
    function [yWL-1 : 0] us2s;
        input xMSB;
        input [qWL-1 :0] x;

    begin
        if (xMSB) begin
            case (ovfMode)
                `OVF_SAT : 
                    begin
                        us2s[yWL-1]   =  0;
                        us2s[yWL-2:0] = ~0;
                    end
                `OVF_SAT_ZERO : us2s = 0;
                `OVF_SAT_SYM : 
                    begin
                        us2s[yWL-1]   =  0;
                        us2s[yWL-2:0] = ~0;
                        us2s[0] = 1'b1;
                    end
                `OVF_WRAP : 
                    begin
                        if (satBits == 1)
                            us2s = 0;
                        else
                            us2s = x;
                    end
                `OVF_WRAP_SM : us2s = x;
            default us2s = 0;
        endcase
        end else
            us2s = x;
        end
    endfunction 
    
//----------------------------------------------------------------------------------------------------
// Code to instantiate required modules dependant upon parameters ------------------------------------
//----------------------------------------------------------------------------------------------------   
    generate
    if (xSGN)
        assign rs = $signed(x);
    else
        assign ru = x;
    
//----------------------------------------------------------------------------------------------------
// * QUANTIZATION ------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
        
    if (LSBsToDelete == 0) begin
        assign qs = rs;
        assign qu = ru;
    end
    else if (xSGN) begin
        if (LSBsToDelete >= 2)
            quantizeSignedA #( .bitsToDelete (LSBsToDelete),
                              .xWL(xWL+1),
                              .qznMode(quantMode)
                            ) qSA(qs, rs);
        else if (LSBsToDelete == 1)
            quantizeSignedB #( .bitsToDelete (LSBsToDelete),
                              .xWL(xWL+1),
                              .qznMode(quantMode)
                            ) qSB(qs, rs);
        else
            quantizeSignedC #( .bitsToDelete (LSBsToDelete),
                              .xWL(xWL+1)
                            ) qSC(qs, rs);

    end else begin
        if (LSBsToDelete >= 2)
            quantizeUnSignedA #( .bitsToDelete (LSBsToDelete),
                                .xWL(xWL+1),
                                .qznMode(quantMode)
                              ) qUSA(qu, ru);
        else if (LSBsToDelete == 1)
            quantizeUnSignedB #( .bitsToDelete (LSBsToDelete),
                                .xWL(xWL+1),
                                .qznMode(quantMode)
                              ) qUSB(qu, ru);
        else
            quantizeUnSignedC #( .bitsToDelete (LSBsToDelete),
                                .xWL(xWL+1)
                              ) qUSC(qu, ru);
    end
    endgenerate

//----------------------------------------------------------------------------------------------------
// * OVERFLOW ----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
    generate
    if (satBits >= yWL) begin                  // Overflow conditions for satBits >= output wordlength
        if (xSGN && ySGN)                      // separate modules required to avoid ranging errors
            if (MSBsToDelete <= 0)
            assign y = $signed(qs);
        else
                overflowSignedC #( .ovfMode (ovfMode),
                                .saturateBits (satBits),
                                .bitsToDelete (qIWL - yIWL),
                                .xWL(qWL)
                                ) ovfSC1(y, qs);
        else if (xSGN && !ySGN) begin
            if (MSBsToDelete <= 0)
                sToUsC #( .ovfMode (ovfMode),
                         .satBits (0),
                         .xWL     (qWL),
                         .yWL     (yWL)
                        ) sToUs1(y, qs, qs[qWL-1]);
        else begin
                assign qs2u = s2us(qs[qWL-1], qs);
                overflowUnSignedC #( .ovfMode (ovfMode),
                                    .saturateBits (satBits),
                                    .bitsToDelete (MSBsToDelete),
                                    .xWL(qWL)
                                    ) ovfUSC1(temp, qs2u);
                if (ovfMode >= 3)
                    wrapS2USC #( .satBits (satBits),
                                .yWL (yWL)
                               ) wrap1(y, temp, x[xWL-1]);
                else assign y = temp;
            end
        end else begin
            if (!xSGN & ySGN) begin
                if (MSBsToDelete <= 0) begin
                    assign yqu2s = qu;
                    assign y = us2s(yqu2s[yWL-1], yqu2s);
                end else begin
                assign qu2s = {1'b0, qu};
                overflowSignedC #( .ovfMode (ovfMode),
                                .saturateBits (satBits),
                                .bitsToDelete (MSBsToDelete + 1),
                                .xWL(qWL+1)
                                ) ovfSC2(y, qu2s);
                end
            end else
                if (MSBsToDelete <= 0)
                    assign y = qu;
                else
                    overflowUnSignedC #( .ovfMode (ovfMode),
                                    .saturateBits (satBits),
                                    .bitsToDelete (MSBsToDelete),
                                    .xWL(qWL)
                                    ) ovfUSC2(y, qu);
        end
//-------------------------------------------------------------------------------------------------
// If satBits is >= 2 use normal modules since no chance range error ------------------------------
//-------------------------------------------------------------------------------------------------
    end else if (satBits >= 2) begin
        if (xSGN && ySGN)
            if (MSBsToDelete <= 0)
                assign y = $signed(qs);
            else
            overflowSignedA #( .ovfMode (ovfMode),
                            .saturateBits (satBits),
                            .bitsToDelete (qIWL - yIWL),
                            .xWL(qWL)
                            ) ovfSA1(y, qs);
        else if (xSGN && !ySGN) begin
            if (MSBsToDelete <= 0)
                sToUs #( .ovfMode (ovfMode),
                         .satBits (satBits),
                         .xWL     (qWL),
                         .yWL     (yWL)
                        ) sToUs2(y, qs, qs[qWL-1]);
            else begin
                assign qs2u = s2us(qs[qWL-1], qs);
            overflowUnSignedA #( .ovfMode (ovfMode),
                                .saturateBits (satBits),
                                .bitsToDelete (MSBsToDelete),
                                .xWL(qWL)
                                    ) ovfUSA1(temp, qs2u);
                if (ovfMode >= 3)
                    wrapS2US #( .satBits (satBits),
                                .yWL (yWL)
                               ) wrap2(y, temp, x[xWL-1]);
                else assign y = temp;
            end
        end else begin
            if (!xSGN & ySGN) begin
                if (MSBsToDelete <= 0) begin
                    assign yqu2s = qu;
                    if (ovfMode<=2)
                        assign y = us2s(yqu2s[yWL-1], yqu2s);
                    else begin
						if (yWL != qWL) begin
							assign y[yWL-1:qWL] = {yWL-qWL{1'b0}};
							assign y[qWL-1:0] = qu;
						end
						else begin
							assign y = qu[qWL-1] ? {1'b0, {satBits-1{1'b1}}, {qWL-satBits{1'b0}}} : {1'b0, qu[qWL-2:0]};
						end
					end
                end else begin
                assign qu2s = {1'b0, qu};
                overflowSignedA #( .ovfMode (ovfMode),
                                .saturateBits (satBits),
                                .bitsToDelete (MSBsToDelete + 1),
                                .xWL(qWL+1)
                                ) ovfSA2(y, qu2s);
                end
            end else
                if (MSBsToDelete <= 0)
                    assign y = qu;
                else
                overflowUnSignedA #( .ovfMode (ovfMode),
                                .saturateBits (satBits),
                                .bitsToDelete (MSBsToDelete),
                                .xWL(qWL)
                                ) ovfUSA2(y, qu);
        end


//----------------------------------------------------------------------------------------------------------------
// If satBits is =< 1 use "safe" modules which avoids range error ------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
    end else begin
        if (xSGN && ySGN)
            if (MSBsToDelete <= 0)
                assign y = $signed(qs);
            else
            overflowSignedB #( .ovfMode (ovfMode),
                            .saturateBits (satBits),
                            .bitsToDelete (qIWL - yIWL),
                            .xWL(qWL)
                            ) ovfSB1(y, qs);
        else if (xSGN && !ySGN) begin
            if (MSBsToDelete <= 0)
                sToUs #( .ovfMode (ovfMode),
                         .satBits (satBits),
                         .xWL     (qWL),
                         .yWL     (yWL)
                        ) sToUs3(y, qs, qs[qWL-1]);
            else begin
                assign qs2u = s2us(qs[qWL-1], qs);
                overflowUnSignedB #( .ovfMode (ovfMode),
                                    .saturateBits (satBits),
                                    .bitsToDelete (MSBsToDelete),
                                    .xWL(qWL)
                                    ) ovfUSB1(temp, qs2u);
                if (ovfMode >= 3)
                    wrapS2US #( .satBits (satBits),
                                .yWL (yWL)
                               ) wrap3(y, temp, x[xWL-1]);
                else assign y = temp;
            end
        end else if (!xSGN & ySGN) begin
            if (MSBsToDelete <= 0) begin
                assign yqu2s = qu;
                assign y = us2s(yqu2s[yWL-1], yqu2s);
            end else begin
            assign qu2s = {1'b0, qu};
            overflowSignedB #( .ovfMode (ovfMode),
                            .saturateBits (satBits),
                            .bitsToDelete (MSBsToDelete + 1),
                            .xWL(qWL+1)
                            ) ovfSB2(y, qu2s);
            end
        end else
            if (MSBsToDelete <= 0)
                assign y = qu;
            else
            overflowUnSignedB #( .ovfMode (ovfMode),
                            .saturateBits (satBits),
                            .bitsToDelete (MSBsToDelete),
                            .xWL(qWL)
                            ) ovfUSB2(y, qu);
    end
    endgenerate
endmodule

// END GENERATE

//****************************************************************************************************************************
// * Start of qunatization and overflow module declarations ******************************************************************
//****************************************************************************************************************************

// ------------------------------------------------------------------------
// Quantization modules

// Contains 4 versions, original signed and original unsigned (suffix A) as 
// well as "safe" versions of the signed and unsigned modules (suffix B) 
// which avoid the range errors encountered when using original functions in 
// systems with bitsToDelete < 2
// --------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// Quantize Signed, Original
module quantizeSignedA (y, x);

//    `include "defines.v"

    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter qznMode = 0;

    output signed [xWL - bitsToDelete - 1: 0] y;
    reg signed [xWL - bitsToDelete - 1: 0] y;

    input signed [xWL - 1 : 0] x;

    reg addOne, mD, sR, r, lR;

    always@(*)begin
            mD = (x[bitsToDelete -1] == 1);
            sR = (x[xWL - 1] == 1);
            r  = (x[bitsToDelete -2 : 0] != 0);
            lR = (x[bitsToDelete] == 1);

            case (qznMode)
                `QZN_RND : addOne = mD;
                `QZN_RND_ZERO : addOne = (mD & (sR | r));
                `QZN_RND_MIN_INF : addOne = (mD & r);
                `QZN_RND_INF :  addOne = (mD & (!sR | r));
                `QZN_RND_CONV : addOne = (mD & (lR | r));
                `QZN_TRN : addOne = 0;
                `QZN_TRN_ZERO : addOne = (sR & (mD | r));
                default : addOne = 0;
            endcase

            if (addOne)
                y = x[xWL - 1 : bitsToDelete] + 1;
            else
                y = x[xWL - 1 : bitsToDelete];
        
    end // always
endmodule

// ---------------------------------------------------------------------------
// Quantize Signed, Safe
module quantizeSignedB (y, x);

//    `include "defines.v"

    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter qznMode = 0;

    output signed [xWL - bitsToDelete - 1: 0] y;
    reg signed [xWL - bitsToDelete - 1: 0] y;

    input signed [xWL - 1 : 0] x;

    reg addOne, mD, sR, r, lR;

    always@(*)begin
        mD = (x[bitsToDelete -1] == 1);
        sR = (x[xWL - 1] == 1);
        r  = 0;
        lR = (x[bitsToDelete] == 1);

        case (qznMode)
            `QZN_RND : addOne = mD;
            `QZN_RND_ZERO : addOne = (mD & (sR | r));
            `QZN_RND_MIN_INF : addOne = (mD & r);
            `QZN_RND_INF :  addOne = (mD & (!sR | r));
            `QZN_RND_CONV : addOne = (mD & (lR | r));
            `QZN_TRN : addOne = 0;
            `QZN_TRN_ZERO : addOne = (sR & (mD | r));
            default : addOne = 0;
        endcase

        if (addOne)
            y = x[xWL - 1 : bitsToDelete] + 1;
        else
            y = x[xWL - 1 : bitsToDelete];
    
    end // always
endmodule


module quantizeSignedC (y, x);

    parameter bitsToDelete = 0;
    parameter xWL = 0;

    output signed [xWL - bitsToDelete - 1: 0] y;
    reg signed [xWL - bitsToDelete - 1: 0] y;

    input signed [xWL - 1 : 0] x;

    reg signed [-bitsToDelete - 1 : 0] temp;

    always@(x) begin
        temp = 0;
        y = {x, temp};
    end
endmodule


// ---------------------------------------------------------------------------
// Quantize Unsigned, Original
module quantizeUnSignedA (y, x);

//    `include "defines.v"

    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter qznMode = 0;

    output [xWL - bitsToDelete - 1: 0] y;
    reg [xWL - bitsToDelete - 1: 0] y;

    input [xWL - 1 : 0] x;

    reg addOne, mD, r, lR;

    always@(*)begin
        mD = (x[bitsToDelete -1] == 1);
        r  = (x[bitsToDelete - 2 :0] != 0);
        lR = (x[bitsToDelete] == 1);

        case (qznMode)
           `QZN_RND : addOne = mD;
           `QZN_RND_ZERO : addOne = (mD & r);
           `QZN_RND_MIN_INF : addOne = (mD & r);
           `QZN_RND_INF :  addOne = mD;
           `QZN_RND_CONV : addOne = (mD & (lR | r));
           `QZN_TRN : addOne = 0;
           `QZN_TRN_ZERO : addOne = 0;
           default : addOne = 0;
        endcase

        if (addOne)
           y = x[xWL - 1 : bitsToDelete] + 1;
        else
           y = x[xWL - 1 : bitsToDelete];
    end // always
endmodule


//---------------------------------------------------------------------------
// Quantize Unigned, Safe
module quantizeUnSignedB (y, x);

//    `include "defines.v"

    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter qznMode = 0;

    output [xWL - bitsToDelete - 1: 0] y;
    reg [xWL - bitsToDelete - 1: 0] y;

    reg [-bitsToDelete - 1: 0] temp;

    input [xWL - 1 : 0] x;

    reg addOne, mD, r, lR;

    always@(*)begin
        temp = 0;
        if (bitsToDelete == 0) begin
            y = x;
        end else if (bitsToDelete < 0) begin
            y = {x, temp};
        end else begin
            mD = (x[bitsToDelete -1] == 1);
            r  = 0;
            lR = (x[bitsToDelete] == 1);

            case (qznMode)
               `QZN_RND : addOne = mD;
               `QZN_RND_ZERO : addOne = (mD & r);
               `QZN_RND_MIN_INF : addOne = (mD & r);
               `QZN_RND_INF :  addOne = mD;
               `QZN_RND_CONV : addOne = (mD & (lR | r));
               `QZN_TRN : addOne = 0;
               `QZN_TRN_ZERO : addOne = 0;
               default : addOne = 0;
            endcase

            if (addOne)
               y = x[xWL - 1 : bitsToDelete] + 1;
            else
               y = x[xWL - 1 : bitsToDelete];
        end
    end // always
endmodule

module quantizeUnSignedC (y, x);

    parameter bitsToDelete = 0;
    parameter xWL = 0;

    output [xWL - bitsToDelete - 1: 0] y;
    reg [xWL - bitsToDelete - 1: 0] y;

    reg [-bitsToDelete - 1: 0] temp;

    input [xWL - 1 : 0] x;

    always@(x) begin
        temp = 0;
        y = {x, temp};
    end
endmodule

//*******************************************************************************************************************************
//*******************************************************************************************************************************
module sToUs(y, x, xMSB);

    parameter yWL = 0, xWL = 0;
    parameter ovfMode = 0, satBits = 0;
    
    input xMSB;
    input [xWL-1 :0] x;
    output reg [yWL-1 :0] y;

    always@(x) begin
        if ((ovfMode <= 2) & xMSB)
            y = 0;
        else if ((ovfMode <= 2) & !xMSB)
            y = x;
        if ((ovfMode >=3) & xMSB) begin
            y[yWL-1:yWL-satBits-1] = 0;
            y[yWL-satBits-1:0] = $signed(x);
        end else if ((ovfMode >=3) & !xMSB)
            y = x;
    end
endmodule 

module sToUsC(y, x, xMSB);

    parameter yWL = 0, xWL = 0;
    parameter ovfMode = 0, satBits = 0;
    
    input xMSB;
    input [xWL-1 :0] x;
    output reg [yWL-1 :0] y;

    always@(x) begin
        if ((ovfMode <= 2) & xMSB)
            y = 0;
        else if ((ovfMode <= 2) & !xMSB)
            y = x;
        if ((ovfMode >=3) & xMSB)
            y[yWL-1:0] = 0;
        else if ((ovfMode >=3) & !xMSB)
            y = x;
    end
endmodule 


module wrapS2US(y, x, xMSB);

    parameter yWL = 0;
    parameter satBits = 0;
    
    input xMSB;
    input [yWL-1 :0] x;
    output reg [yWL-1 :0] y;
//    reg signX;

    always@(*) begin
        if (xMSB & satBits) begin
            y[yWL-1] = 0;
           y[yWL - 2 : 0] = $signed(x);
        end else 
            if (xMSB & (satBits == 2)) begin
                y[yWL - 1 : yWL - 2] = 0;
                y[yWL - 3 : 0] = $signed(x);
        end else
            y = x;
    end
endmodule 


module wrapS2USC(y, x, xMSB);

    parameter yWL = 0, xWL = 0;
    parameter satBits = 0;
    
    input xMSB;
    input [xWL-1 :0] x;
    output reg [yWL-1 :0] y;

    always@(*) begin
        if (xMSB) begin
            y[yWL-1:0] = 0;
        end else
            y = x;
    end
endmodule 
//*******************************************************************************************************************************
//*******************************************************************************************************************************

//------------------------------------------------------------------------
// Overflow modules
//
// Contains 6 versions, original signed and original unsigned (suffix A) as 
// well as "safe" versions of the signed and unsigned modules (suffix B & C) 
// which avoid the range errors encountered when using original functions in 
// systems with saturateBits < 2  and satBits >= outputWL
//--------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Overflow Signed, Original
module overflowSignedA(y, x);

//    `include "defines.v"
//---------------------------------------------------------------
// Function to determine how many bits beed to be xor-ed as this is
// slightly irregular, for use in overflow task
//----------------------------------------------------------------
    function integer xorBitLen;
        input integer xLen; 
        input integer delBits; 
        input integer satBits;
    begin
            if (satBits == 0)
                xorBitLen = xLen-delBits-1;
            else
                xorBitLen = xLen-delBits-satBits;
            if (xorBitLen <= 0)
                xorBitLen = 1;
    end
    endfunction 
//------------------------------------------------------------------ 

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input signed [xWL - 1 : 0] x;  
    output signed [xWL - bitsToDelete - 1 : 0] y;

    reg signed [bitsToDelete-1 : 0] xdel;
    reg signed [xWL - bitsToDelete - 1 : 0] xrem;
    reg signed [xWL - bitsToDelete - 1 : 0] y;

    reg signed [xWL - 1 : 0] xmin;
    
    reg stdOverflow;
    reg overflow;

    reg sRo, lNo, sD, lD;

    parameter REM_BITS_LENGTH = xorBitLen(xWL, bitsToDelete, saturateBits);
    reg signed [REM_BITS_LENGTH-1 : 0] xorResult;
    reg signed [REM_BITS_LENGTH-1 : 0] remBits;

    always@(x) begin
         sRo = x[xWL - bitsToDelete - 1];
         lNo = x[xWL - bitsToDelete - saturateBits];
         sD = x[xWL - 1];
         lD = x[xWL - bitsToDelete];
         
        if (ovfMode == `OVF_SAT_SYM) begin
            xmin[xWL-1 : xWL-bitsToDelete-1] = ~0;
            xmin[xWL-bitsToDelete-2 : 0] = 0; 
        end

        xdel          = x[xWL - 1 : xWL - bitsToDelete];
         xrem         = x[xWL - bitsToDelete -1 : 0];
         remBits      = x[REM_BITS_LENGTH - 1 : 0];

        stdOverflow   = $signed(x[xWL - 1 : xWL - bitsToDelete]) != $signed({bitsToDelete{x[xWL-bitsToDelete-1]}});

        if (ovfMode == `OVF_SAT_SYM)
            overflow  = stdOverflow |( x == xmin);
        else
            overflow = stdOverflow;

        if (overflow) begin
            case (ovfMode)

                `OVF_SAT : 
                    begin
                        y[yWL-1] = sD;
                        if (sD)
                            y[yWL - 2 : 0] = 0;
                        else
                            y[yWL - 2 : 0] = ~0;
                    end

                `OVF_SAT_ZERO : 
                    begin
                        y = 'b0;
                    end

                `OVF_SAT_SYM : 
                    begin
                        y[yWL - 1] = sD;
                        if (sD)
                            y[yWL - 2 : 1] = 0;
                        else
                            y[yWL - 2 : 1] = ~0;
                        y[0] = 1'b1;
                    end

                `OVF_WRAP : 
                    begin
                        if (saturateBits==0)
                            y = xrem;
                        else if (saturateBits==1)
                            y = {sD, xrem[xWL - bitsToDelete -2 : 0]};
                        else begin
                            y[yWL - 1] = sD;
                            if (sD)
                                y[yWL - 2 : yWL - saturateBits] = 0;
                            else
                                y[yWL - 2 : yWL - saturateBits] = ~0;
                            y[yWL - saturateBits -1 : 0] = remBits;
                        end
                    end

                `OVF_WRAP_SM : 
                    begin
                        if (saturateBits==0) begin
                            y[yWL - 1] = lD;
                            if (sRo ^ y[yWL -1])
                                xorResult = ~0;
                            else
                                xorResult = 0;
                            y[yWL - 2 : 0] = xorResult ^ remBits;
                        end
                        else if (saturateBits == 1) begin
                            y[yWL - 1] = sD;
                            if (sRo ^ y[yWL -1])
                                xorResult = ~0;
                            else
                                xorResult = 0;
                        end
                        else begin
                            y[yWL - 1] = sD;
                            if (sD)
                                y[yWL - 2 : 0] = 0;
                            else
                                y[yWL - 2 : 0] = ~0;
                            if (lNo ^ !sD)
                                xorResult = ~0;
                            else
                                xorResult = 0;
                            y[yWL - saturateBits - 1 : 0] = xorResult ^ remBits;
                        end  
                    end

                default y = 0;

            endcase
        end // if overflow
        else y = x;
    end // always @
endmodule  

//---------------------------------------------------------------------------
// Overflow Signed, safe
//---------------------------------------------------------------------------
// Overflow Signed, safe
module overflowSignedB(y, x);

    //    `include "defines.v"
    //---------------------------------------------------------------
    // Function to determine how many bits beed to be xor-ed as this is
    // slightly irregular, for use in overflow task
    //----------------------------------------------------------------
    function integer xorBitLen;
        input integer xLen; 
        input integer delBits; 
        input integer satBits;
        begin
            if (satBits == 0)
                xorBitLen = xLen-delBits-1;
            else
                xorBitLen = xLen-delBits-satBits;
        end
    endfunction 
    //------------------------------------------------------------------

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input signed [xWL - 1 : 0] x;
    output signed [xWL - bitsToDelete - 1 : 0] y;

    reg signed [xWL - bitsToDelete - 1 : 0] xrem;
    reg signed [xWL - bitsToDelete - 1 : 0] y;

    localparam signed [xWL - 1 : 0] xmin = { {bitsToDelete{1'b1}}, {xWL-bitsToDelete-1{1'b0}} };

    localparam REM_BITS_LENGTH = xorBitLen(xWL, bitsToDelete, saturateBits);
    
    reg stdOverflow;
    reg overflow;

    reg sRo, sD, lD;
    
    reg signed [REM_BITS_LENGTH-1 : 0] xorResult;
    reg signed [REM_BITS_LENGTH-1 : 0] remBits;

    always@(x) begin
        
        sRo           = x[xWL - bitsToDelete - 1];
        sD            = x[xWL - 1];
        lD            = x[xWL - bitsToDelete];
        
        xrem          = x[xWL - bitsToDelete -1 : 0];
        remBits       = x[REM_BITS_LENGTH - 1 : 0];

        stdOverflow   = $signed(x[xWL - 1 : xWL - bitsToDelete]) != $signed({bitsToDelete{x[xWL-bitsToDelete-1]}});
        
        if (ovfMode == `OVF_SAT_SYM)
            overflow  = stdOverflow | (x == xmin);
        else
            overflow = stdOverflow;
        
        if (overflow) begin
            case (ovfMode)
                
                `OVF_SAT : 
                    begin
                        y[yWL-1] = sD;
                        if (sD)
                            y[yWL - 2 : 0] = 0;
                        else
                            y[yWL - 2 : 0] = ~0;
                    end

                `OVF_SAT_ZERO : 
                    begin
                        y = 'b0;
                    end

                `OVF_SAT_SYM : 
                    begin
                        y[yWL - 1] = sD;
                        if (sD)
                            y[yWL - 2 : 0] = 0;
                        else
                            y[yWL - 2 : 0] = ~0;
                        y[0] = 1'b1 ;
                    end

                `OVF_WRAP : 
                    begin
                        if (saturateBits<=0)
                            y = xrem;
                        else if (saturateBits==1)
                            y = {sD, xrem[xWL - bitsToDelete -2 : 0]};
                    end

                `OVF_WRAP_SM : 
                    begin
                        if (saturateBits<=0) begin
                            y[yWL - 1] = lD;
                            if (sRo ^ y[yWL -1])
                                xorResult = ~0;
                            else
                                xorResult = 0;
                            y[yWL - 2 : 0] = xorResult ^ remBits;
                        end
                        else if (saturateBits == 1) begin
                            y[yWL - 1] = sD;
                            if (sRo ^ y[yWL -1])
                                xorResult = ~0;
                            else
                                xorResult = 0;
                        end
                    end

                default y = 0;

            endcase
        end // if overflow
        else y = x;
    end // always @
endmodule  

//---------------------------------------------------------------------------
// Overflow Unsigned, Original
module overflowUnSignedA(y, x);

//    `include "defines.v"

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input [xWL - 1 : 0] x;
    output [xWL - bitsToDelete - 1 : 0] y;

    reg [bitsToDelete-1 : 0] xdel;
    reg [xWL - bitsToDelete - 1 : 0] xrem;
    reg [xWL - bitsToDelete - 1 : 0] y;

    parameter [bitsToDelete - 1: 0] OVF_MASK_ZERO = 0;
    
    wire stdOverflow;
    reg overflow;

    always@ (x) begin
        overflow = (x[xWL - 1 : xWL - bitsToDelete] != OVF_MASK_ZERO);   
        xdel = x[xWL - 1 : xWL - bitsToDelete];
        xrem = x[xWL - bitsToDelete - 1 : 0];

        if (overflow) begin
            case (ovfMode)
                `OVF_SAT : 
                         y = ~0;
                `OVF_SAT_ZERO : 
                      y = 0;
                `OVF_SAT_SYM : y = ~0;
                `OVF_WRAP_SM : y = xrem;
                `OVF_WRAP :
                    begin 
                            y[yWL - 1 : yWL - saturateBits] = ~0;
                        y[yWL - saturateBits - 1 : 0] = xrem [yWL - saturateBits - 1 : 0];
                    end
                default y = xrem;
            endcase
        end else
            y = xrem;
    end
endmodule


//---------------------------------------------------------------------------
// Overflow Unsigned, safe
module overflowUnSignedB(y, x);

//    `include "defines.v"

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input [xWL - 1 : 0] x;
    output [xWL - bitsToDelete - 1 : 0] y;

    reg [xWL - bitsToDelete - 1 : 0] xrem;
    reg [xWL - bitsToDelete - 1 : 0] y;

    parameter [bitsToDelete : 0] OVF_MASK_ZERO = 0;
    
    wire stdOverflow;
    reg overflow;

    always@ (x) begin
        overflow = (x[xWL - 1 : xWL - bitsToDelete] != OVF_MASK_ZERO);   
        xrem = x[xWL - bitsToDelete - 1 : 0];
        if (overflow) begin
            case (ovfMode)

                `OVF_SAT : y = ~0;
                `OVF_SAT_ZERO : y = 0;
                `OVF_SAT_SYM : y = ~0;
                `OVF_WRAP : 
                    begin
                        if (saturateBits == 1) begin                    
                            y[yWL - 1] = 1;
                            y[yWL-2:0] = xrem[yWL-2:0];
                        end else
                            y = xrem;
                    end
                default y = 0;
            endcase
        end else
            y = xrem;
    end
endmodule

//---------------------------------------------------------------------------
// Overflow Unsigned, To avoid satBits related overflow
module overflowUnSignedC(y, x);

//    `include "defines.v"

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input [xWL - 1 : 0] x;
    output [xWL - bitsToDelete - 1 : 0] y;

    reg [bitsToDelete-1 : 0] xdel;
    reg [xWL - bitsToDelete - 1 : 0] xrem;
    reg [xWL - bitsToDelete - 1 : 0] y;

    parameter [bitsToDelete - 1: 0] OVF_MASK_ZERO = 0;
    
    wire stdOverflow;
    reg overflow;

    always@ (x) begin
        overflow = (x[xWL - 1 : xWL - bitsToDelete] != OVF_MASK_ZERO);   
        xdel = x[xWL - 1 : xWL - bitsToDelete];
        xrem = x[xWL - bitsToDelete - 1 : 0];

        if (overflow) begin
            case (ovfMode)
                `OVF_SAT : 
                         y = ~0;
                `OVF_SAT_ZERO : 
                      y = 0;
                `OVF_SAT_SYM : y = ~0;
                `OVF_WRAP :
                    begin 
                        y[yWL - 1 : 0] = ~0;
                    end
                default y = xrem;
            endcase
        end else
            y = xrem;
    end
endmodule

//---------------------------------------------------------------------------
// Overflow Signed, To avoid satBits related overflow
module overflowSignedC(y, x);

//    `include "defines.v"
//---------------------------------------------------------------
// Function to determine how many bits beed to be xor-ed as this is
// slightly irregular, for use in overflow task
//----------------------------------------------------------------
    function integer xorBitLen;
        input integer xLen; 
        input integer delBits; 
        input integer satBits;
    begin
            if (satBits == 0)
                xorBitLen = xLen-delBits-1;
            else
                xorBitLen = xLen-delBits-satBits;
            if (xorBitLen <= 0)
                xorBitLen = 1;
    end
    endfunction 
//------------------------------------------------------------------ 

    parameter ovfMode = 0;
    parameter saturateBits = 0;
    parameter bitsToDelete = 0;
    parameter xWL = 0;
    parameter yWL = xWL - bitsToDelete;

    input signed [xWL - 1 : 0] x;  
    output signed [xWL - bitsToDelete - 1 : 0] y;

    reg signed [bitsToDelete-1 : 0] xdel;
    reg signed [xWL - bitsToDelete - 1 : 0] xrem;
    reg signed [xWL - bitsToDelete - 1 : 0] y;

    reg signed [xWL - 1 : 0] xmin;
    reg signed [bitsToDelete : 0] OVF_MASK_ZERO = 0;
    reg signed [bitsToDelete : 0] OVF_MASK_ONE = ~0;
    
    reg stdOverflow;
    reg overflow;

    reg sRo, lNo, sD, lD;

    parameter REM_BITS_LENGTH = xorBitLen(xWL, bitsToDelete, saturateBits);
    reg signed [REM_BITS_LENGTH-1 : 0] xorResult;
    reg signed [REM_BITS_LENGTH-1 : 0] remBits;

    always@(x) begin
         sRo = x[xWL - bitsToDelete - 1];
         lNo = x[xWL - bitsToDelete - saturateBits];
         sD = x[xWL - 1];
         lD = x[xWL - bitsToDelete];
         
        if (ovfMode == `OVF_SAT_SYM) begin
            xmin[xWL-1 : xWL-bitsToDelete-1] = ~0;
            xmin[xWL-bitsToDelete-2 : 0] = 0; 
        end

         xdel = x[xWL - 1 : xWL - bitsToDelete];
         xrem = x[xWL - bitsToDelete -1 : 0];
         remBits = x[REM_BITS_LENGTH - 1 : 0];

        stdOverflow = ((x[xWL - 1 : xWL - bitsToDelete - 1] != OVF_MASK_ZERO) 
                     & (x[xWL - 1 : xWL - bitsToDelete - 1] != OVF_MASK_ONE));

        if (ovfMode == `OVF_SAT_SYM)
            overflow = stdOverflow |( x == xmin);
        else
            overflow = stdOverflow;

    if (overflow) begin
        case (ovfMode)

            `OVF_SAT : 
            begin
                y[yWL-1] = sD;
                if (sD)
                    y[yWL - 2 : 0] = 0;
                else
                    y[yWL - 2 : 0] = ~0;
            end

            `OVF_SAT_ZERO : 
            begin
                y = 'b0;
            end

            `OVF_SAT_SYM : 
            begin
                y[yWL - 1] = sD;
                if (sD)
                    y[yWL - 2 : 0] = 0;
                else
                    y[yWL - 2 : 0] = ~0;
                y[0] = 1'b1;
            end

            `OVF_WRAP : 
            begin
                if (saturateBits==0)
                    y = xrem;
                else if (saturateBits==1)
                    y = {sD, xrem[xWL - bitsToDelete -2 : 0]};
                else begin
                    y[yWL - 1] = sD;
                    if (sD)
                        y[yWL - 2 : yWL - saturateBits] = 0;
                    else
                        y[yWL - 2 : yWL - saturateBits] = ~0;

                end
            end

            `OVF_WRAP_SM : 
            begin
               if (saturateBits==0) begin
                    y[yWL - 1] = lD;
                    if (sRo ^ y[yWL -1])
                        xorResult = ~0;
                    else
                        xorResult = 0;
                    y[yWL - 2 : 0] = xorResult ^ remBits;
                end
                else if (saturateBits == 1) begin
                    y[yWL - 1] = sD;
                    if (sRo ^ y[yWL -1])
                        xorResult = ~0;
                    else
                        xorResult = 0;
                end
                else begin
                    y[yWL - 1] = sD;
                    if (sD)
                        y[yWL - 2 : yWL - saturateBits] = 0;
                    else
                        y[yWL - 2 : yWL - saturateBits] = ~0;
                    if (lNo ^ !sD)
                        xorResult = ~0;
                    else
                        xorResult = 0;
                end  
            end

            default y = 0;

        endcase
    end // if overflow
        else y = x;
    end // always @
endmodule 