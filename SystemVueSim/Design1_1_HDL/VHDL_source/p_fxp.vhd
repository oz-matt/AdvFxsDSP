-------------------------------------------------------------------------------
--
-- FXPLib - VHDL source
--
-- Copyright (C) 2008-2015 Steepest Ascent Ltd.
-- www.steepestascent.com
--
-- This source code is provided on an "as-is",
-- unsupported basis. You may include this source
-- code in your project providing this copyright
-- message is included, unaltered.
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- p_fxp
--
-- Declares and defines functions for performing fixedpoint conversion.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package p_fxp is

    -- fixedpoint type parameters
    type fxpTypeInfoT is
    record
        wl  : integer;                  -- Word length
        iwl : integer;                  -- Integer word length
        sgn : boolean;                  -- Is the signal signed? 
    end record;

    -- quantization mode enum
    type fxpQznModeT is (
        QZN_RND,                        -- Rounding to plus infinity
        QZN_RND_ZERO,                   -- Rounding to zero
        QZN_RND_MIN_INF,                -- Rounding to minus infinity
        QZN_RND_INF,                    -- Rounding to infinity        
        QZN_RND_CONV,                   -- Convergent rounding
        QZN_TRN,                        -- Truncation
        QZN_TRN_ZERO                    -- Truncation to zero
    );

    -- overflow mode enum
    type fxpOvfModeT is (
        OVF_SAT,                        -- Saturation
        OVF_SAT_ZERO,                   -- Saturation to zero        
        OVF_SAT_SYM,                    -- Symmetrical saturation
        OVF_WRAP,                       -- Wrap-around
        OVF_WAP_SM                      -- Sign magnitude wrap-around
    );

    function ToFxpQznModeT(n : natural) return fxpQznModeT;
    function ToFxpOvfModeT(n : natural) return fxpOvfModeT;

    ---------------------------------------------------------------------------
    --
    -- FxpConvert
    --
    -- Converts between fixedpoint types.
    --
    ---------------------------------------------------------------------------

    function FxpConvert
    (
        x         : std_logic_vector;   -- input signal to be processed
        xTypeInfo : fxpTypeInfoT;       -- fixedpoint type of input
        yTypeInfo : fxpTypeInfoT;       -- fixedpoint type of result
        qznMode   : fxpQznModeT;        -- quantization mode
        ovfMode   : fxpOvfModeT;        -- overflow mode
        satBits   : integer             -- number of saturate bits
    ) return std_logic_vector;

    function FxpQuantize
    (
        x            : signed;
        bitsToDelete : integer;         -- number of MSBs to be deleted
        qznMode      : fxpQznModeT
    ) return signed;

    function FxpQuantize
    (
        x            : unsigned;
        bitsToDelete : integer;         -- number of MSBs to be deleted
        qznMode      : fxpQznModeT
    ) return unsigned;

    function FxpHandleOverflow
    (
        x            : signed;
        bitsToDelete : integer;
        saturateBits : natural;
        ovfMode      : fxpOvfModeT
    ) return signed;

    function FxpHandleOverflow
    (
        x            : unsigned;
        bitsToDelete : integer;
        saturateBits : natural;
        ovfMode      : fxpOvfModeT
    ) return unsigned;


    ---------------------------------------------------------------------------
    --
    -- FxpConvertWithFlags
    --
    -- Converts between fixedpoint types.
    -- Two additional bits are appended to the left of the result to indicate
    -- whether overflow or underflow occurred.
    --
    -- Result format: ( overflowFlag | underflowFlag | y )
    -- 
    ---------------------------------------------------------------------------

    --     function FxpConvertWithFlags
    --     (
    --         x         : std_logic_vector;  -- input signal to be processed
    --         xTypeInfo : fxpTypeInfoT;      -- fixedpoint type of input
    --         yTypeInfo : fxpTypeInfoT;      -- fixedpoint type of result
    --         qznMode   : fxpQznModeT;       -- quantization mode
    --         ovfMode   : fxpOvfModeT;       -- overflow mode
    --     ) return std_logic_vector;

    ---------------------------------------------------------------------------
    -- conversion routines for 4 combinations of signed and unsigned
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- HELPER FUNCTIONS
    ---------------------------------------------------------------------------

    function GetMin(width : positive; usedBits : positive; isSigned : boolean) return std_logic_vector;
    function GetMax(width : positive; usedBits : positive; isSigned : boolean) return std_logic_vector;

    function AreAnyOne(inputVector : std_logic_vector) return boolean;

    function AreAllZero(INPUT_VECTOR       : std_logic_vector; UPPER_LIMIT, LOWER_LIMIT : integer) return boolean;
    function AreAllOne(INPUT_VECTOR        : std_logic_vector; UPPER_LIMIT, LOWER_LIMIT : integer) return boolean;
    function GetNumOfCarryBits(ISUNSGNDOUT : boolean; ROUND_ENABLED : boolean) return integer;

    -- other useful functions
    function bitWidthFor(value  : integer; isTargetVectorUnsigned : boolean) return positive;
    function isEven(value       : integer) return boolean;
    function isOdd(value        : integer) return boolean;
    function isPower2(val       : positive) return boolean;
    function log2Ceil(val       : positive) return natural;
    function max(a, b           : integer) return integer;
    function msbPosition(val    : positive) return natural;
    function to_boolean(VALUE   : integer) return boolean;
    function to_boolean(VALUE   : std_logic) return boolean;
    function to_std_logic(VALUE : boolean) return std_logic;

end p_fxp;

-------------------------------------------------------------------------------
-- P_FXP package body
-------------------------------------------------------------------------------

package body p_fxp is

    ---------------------------------------------------------------------------
    -- Convert from integer to quantization mode
    ---------------------------------------------------------------------------

    function ToFxpQznModeT(n : natural) return fxpQznModeT is

        type naturalQznMapT is array (natural range 0 to 6) of fxpQznModeT;
        
        constant NATURAL_QZN_MAP : naturalQznMapT := (
            QZN_RND,
            QZN_RND_ZERO,
            QZN_RND_MIN_INF,
            QZN_RND_INF,
            QZN_RND_CONV,
            QZN_TRN,
            QZN_TRN_ZERO);

    begin

        return NATURAL_QZN_MAP(n);

    end function;

    ---------------------------------------------------------------------------
    -- Convert from integer to overflow mode
    ---------------------------------------------------------------------------

    function ToFxpOvfModeT(n : natural) return fxpOvfModeT is

        type naturalOvfMapT is array (natural range 0 to 4) of fxpOvfModeT;

        constant NATURAL_OVF_MAP : naturalOvfMapT := (
            OVF_SAT,
            OVF_SAT_ZERO,
            OVF_SAT_SYM,
            OVF_WRAP,
            OVF_WAP_SM);

    begin

        return NATURAL_OVF_MAP(n);

    end function;

    ----------------------------------------------------------------------
    -- FxpConvert
    -- Converts from one fixedpoint type to another.
    ----------------------------------------------------------------------

    function FxpConvert
    (
        x         : std_logic_vector;   -- input signal to be processed
        xTypeInfo : fxpTypeInfoT;       -- fixedpoint type of input
        yTypeInfo : fxpTypeInfoT;       -- fixedpoint type of result
        qznMode   : fxpQznModeT;        -- quantization mode
        ovfMode   : fxpOvfModeT;        -- overflow mode
        satBits   : integer             -- number of saturate bits
    ) return std_logic_vector is

        -- determine fixedpoint type of quantized value
        -- before overflow handling, alowing for extra bits
        -- due to quantization 
        constant qTypeInfo : fxpTypeInfoT := (
            yTypeInfo.wl + xTypeInfo.iwl - yTypeInfo.iwl + 1,
            xTypeInfo.iwl + 1,
            xTypeInfo.sgn);

        constant x_fwl : integer := xTypeInfo.wl - xTypeInfo.iwl;
        constant y_fwl : integer := yTypeInfo.wl - yTypeInfo.iwl;

        -- resized input to quantizer
        variable rs : signed(xTypeInfo.wl downto 0);
        variable ru : unsigned(xTypeInfo.wl downto 0);

        -- output of quantizer
        variable qs : signed(qTypeInfo.wl-1 downto 0);
        variable qu : unsigned(qTypeInfo.wl-1 downto 0);

        -- crossover variables, when going signed to unsigned and vice versa
        variable qs2u : unsigned(qTypeInfo.wl-1 downto 0);
        -- NOTE one extra bit required going from unsigned to signed
        variable qu2s : signed(qTypeInfo.wl downto 0);

        -- result of this function
        variable y : std_logic_vector(yTypeInfo.wl-1 downto 0);

        variable LSBsToDelete, MSBsToDelete : integer;

    begin

        -- resize before quantizing in case of overflow
        if xTypeInfo.sgn then
            rs := resize(signed(x), xTypeInfo.wl+1);
        else
            ru := resize(unsigned(x), xTypeInfo.wl+1);
        end if;

        -- quantize
        LSBsToDelete := x_fwl-y_fwl;

        if xTypeInfo.sgn then
            qs := FxpQuantize(rs, LSBsToDelete, qznMode);
        else
            qu := FxpQuantize(ru, LSBsToDelete, qznMode);
        end if;

        -- handle overflow
        if xTypeInfo.sgn and yTypeInfo.sgn then
            -- signed in signed out
            y := std_logic_vector(FxpHandleOverflow(qs, qTypeInfo.iwl-yTypeInfo.iwl, satBits, ovfMode));

        elsif xTypeInfo.sgn and not yTypeInfo.sgn then
            -- signed in unsigned out
            MSBsToDelete    := qTypeInfo.iwl-yTypeInfo.iwl;
            if MSBsToDelete <= 0 then
                if (ovfMode = OVF_SAT or ovfMode = OVF_SAT_SYM or ovfMode = OVF_SAT_ZERO) and qs(qs'left) = '1' then
                    y := (others => '0');
                else
                    y := std_logic_vector(resize(qs, qs'length-MSBsToDelete));
                end if;
                if ovfMode = OVF_WRAP and qs(qs'left) = '1' then
                    y(y'left downto y'left - satBits + 1) := (others => '0');
                end if;
            else
                if (ovfMode = OVF_SAT or ovfMode = OVF_SAT_SYM or ovfMode = OVF_SAT_ZERO) and qs(qs'left) = '1' then
                    y := (others => '0');
                else
                    qs2u := unsigned(qs);
                    y    := std_logic_vector(FxpHandleOverflow(qs2u, MSBsToDelete, satBits, ovfMode));
                end if;
                if ovfMode = OVF_WRAP and qs(qs'left) = '1' then
                    y(y'left downto y'left - satBits + 1) := (others => '0');
                end if;
            end if;

        elsif not xTypeInfo.sgn and yTypeInfo.sgn then
            -- unsigned in signed out
            qu2s := '0' & signed(qu);
            y    := std_logic_vector(FxpHandleOverflow(qu2s, qTypeInfo.iwl+1-yTypeInfo.iwl, satBits, ovfMode));

        else
            -- unsigned in unsigned out
            y := std_logic_vector(FxpHandleOverflow(qu, qTypeInfo.iwl-yTypeInfo.iwl, satBits, ovfMode));

        end if;


        return y;

    end FxpConvert;

    ----------------------------------------------------------------------
    -- FxpQuantize
    -- Performs quantization of a signed fixedpoint number to another
    -- fixedpoint type of less accuracy. 
    ----------------------------------------------------------------------

    function FxpQuantize
    (
        x            : signed;
        bitsToDelete : integer;         -- number of LSBs to be deleted
        qznMode      : fxpQznModeT
    ) return signed is

        variable y             : signed(x'length - bitsToDelete - 1 downto 0);
        variable addOne        : boolean;
        variable mD, sR, r, lR : boolean;

    begin

        if bitsToDelete = 0 then
            y := x;
        elsif bitsToDelete < 0 then
            y := x & to_signed(0, -bitsToDelete);
        else

            mD := x(bitsToDelete-1) = '1';
            sR := x(x'left) = '1';
            if bitsToDelete < 2 then
                r := false;
            else
                r := x(bitsToDelete-2 downto 0) /= 0;
            end if;
            lR := x(bitsToDelete) = '1';

            case qznMode is
                when QZN_RND =>
                    addOne := mD;
                when QZN_RND_ZERO =>
                    addOne := mD and (sR or r);
                when QZN_RND_MIN_INF =>
                    addOne := mD and r;
                when QZN_RND_INF =>
                    addOne := mD and ((not sR) or r);
                when QZN_RND_CONV =>
                    addOne := mD and (lR or r);
                when QZN_TRN =>
                    addOne := false;
                when QZN_TRN_ZERO =>
                    addOne := sR and (mD or r);
                when others => null;

            end case;

            if addOne then
                y := x(x'length-1 downto bitsToDelete)+1;
            else
                y := x(x'length-1 downto bitsToDelete);
            end if;

        end if;

        return y;

    end function;

    ----------------------------------------------------------------------
    -- FxpQuantize
    -- Performs quantization of an unsigned fixedpoint number to another
    -- fixedpoint type of less accuracy. 
    ----------------------------------------------------------------------

    function FxpQuantize
    (
        x            : unsigned;
        bitsToDelete : integer;         -- number of LSBs to be deleted
        qznMode      : fxpQznModeT
    ) return unsigned is

        variable y         : unsigned(x'length - bitsToDelete - 1 downto 0);
        variable addOne    : boolean;
        variable mD, r, lR : boolean;

    begin

        if bitsToDelete = 0 then
            y := x;
        elsif bitsToDelete < 0 then
            y := x & to_unsigned(0, -bitsToDelete);
        else

            mD := x(bitsToDelete-1) = '1';
            if bitsToDelete < 2 then
                r := false;
            else
                r := x(bitsToDelete-2 downto 0) /= 0;
            end if;
            lR := x(bitsToDelete) = '1';

            case qznMode is
                when QZN_RND =>
                    addOne := mD;
                when QZN_RND_ZERO =>
                    addOne := mD and r;
                when QZN_RND_MIN_INF =>
                    addOne := mD and r;
                when QZN_RND_INF =>
                    addOne := mD;
                when QZN_RND_CONV =>
                    addOne := mD and (lR or r);
                when QZN_TRN =>
                    addOne := false;
                when QZN_TRN_ZERO =>
                    addOne := false;
                when others => null;

            end case;

            if addOne then
                y := x(x'length-1 downto bitsToDelete)+1;
            else
                y := x(x'length-1 downto bitsToDelete);
            end if;

        end if;

        return y;

    end function;

    ----------------------------------------------------------------------
    -- FxpHandleOverflow
    -- Performs overflow handling for an signed fixedpoint number to
    -- another fixedpoint type of less accuracy. 
    ----------------------------------------------------------------------

    function FxpHandleOverflow
    (
        x            : signed;
        bitsToDelete : integer;
        saturateBits : natural;
        ovfMode      : fxpOvfModeT
    ) return signed is

        constant bitsToDeleteLimited : integer := max(bitsToDelete, 1);
        variable xdel                : signed(bitsToDeleteLimited-1 downto 0);
        variable xrem                : signed(x'length-bitsToDelete-1 downto 0);
        variable y                   : signed(x'length-bitsToDelete-1 downto 0);


        constant OVF_MASK_ZERO : signed(bitsToDeleteLimited downto 0) := (others => '0');
        constant OVF_MASK_ONE  : signed(bitsToDeleteLimited downto 0) := (others => '1');

        variable stdOverflow, overflow : boolean;

        variable sRo, lNo, sD, lD : std_logic;

        -- function to determine how many bits beed to be xor-ed as this is
        -- slightly irregular
        function xorBitLen(xLen : positive; delBits : integer; satBits : natural) return natural is
        begin
            if saturateBits = 0 then
                return xLen-bitsToDelete-1;
            else
                return xLen-bitsToDelete-saturateBits;
            end if;
        end function;

        constant REM_BITS_LENGTH : natural := xorBitLen(x'length, bitsToDelete, saturateBits);
        variable xorResult       : signed(REM_BITS_LENGTH-1 downto 0);
        variable remBits         : signed(REM_BITS_LENGTH-1 downto 0);

    begin

        if bitsToDelete = 0 then
            y := x;
        elsif bitsToDelete < 0 then
            y := resize(x, x'length - bitsToDelete);
        else

            -- original value of sign of remaining bits
            sRo := x(x'length-bitsToDelete-1);
            -- original value of least significant saturated bit
            lNo := x(x'length-bitsToDelete-saturateBits);
            -- sign of deleted bits
            sD  := x(x'length-1);
            -- least significant deleted bit
            lD  := x(x'length-bitsToDelete);

            xdel    := x(x'length-1 downto x'length-bitsToDelete);
            xrem    := x(x'length-bitsToDelete-1 downto 0);
            remBits := x(REM_BITS_LENGTH-1 downto 0);

            -- check for overflow
            stdOverflow := (((x(x'length-1 downto x'length-bitsToDelete-1) /= OVF_MASK_ZERO) and
                             (x(x'length-1 downto x'length-bitsToDelete-1) /= OVF_MASK_ONE)));

            if ovfMode = OVF_SAT_SYM then
                overflow := stdOverflow or (x = signed(GetMin(x'length, x'length-bitsToDelete, true)));
            else
                overflow := stdOverflow;
            end if;

            -- deal with overflow
            if overflow then
                case ovfMode is
                    when OVF_SAT =>
                        y(y'length-1)          := sD;
                        y(y'length-2 downto 0) := (others => not sD);

                    when OVF_SAT_ZERO =>
                        y := (others => '0');

                    when OVF_SAT_SYM =>
                        y(y'length-1)          := sD;
                        y(y'length-2 downto 1) := (others => not sD);
                        y(0)                   := '1';

                    when OVF_WRAP =>
                        if saturateBits = 0 then
                            y := xrem;

                        elsif saturateBits = 1 then
                            y := sD & xrem(xrem'length-2 downto 0);

                        else            -- saturate bits > 1
                            y(y'length-1)                              := sD;
                            y(y'length-2 downto y'length-saturateBits) := (others => not sD);
                            y(y'length-saturateBits-1 downto 0)        := remBits;

                        end if;

                    when OVF_WAP_SM =>
                        if saturateBits = 0 then
                            y(y'length-1)          := lD;
                            xorResult              := (others => (sRo xor y(y'left)));
                            y(y'length-2 downto 0) := xorResult xor remBits;

                        elsif saturateBits = 1 then
                            y(y'length-1)          := sD;
                            xorResult              := (others => (sRo xor y(y'left)));
                            y(y'length-2 downto 0) := xorResult xor remBits;

                        else
                            y(y'length-1)                              := sD;
                            y(y'length-2 downto y'length-saturateBits) := (others => not sD);
                            xorResult                                  := (others => (lNo xor (not sD)));
                            y(y'length-saturateBits-1 downto 0)        := xorResult xor remBits;

                        end if;

                    when others => null;
                end case;
            else
                y := xrem;
            end if;

        end if;

        return y;

    end function;

    ----------------------------------------------------------------------
    -- FxpHandleOverflow
    -- Performs overflow handling for an unsigned fixedpoint number to
    -- another fixedpoint type of less accuracy.
    ----------------------------------------------------------------------


    function FxpHandleOverflow
    (
        x            : unsigned;
        bitsToDelete : integer;
        saturateBits : natural;
        ovfMode      : fxpOvfModeT
    ) return unsigned is

        constant bitsToDeleteLimited : integer := max(bitsToDelete, 1);
        variable xdel : unsigned(bitsToDeleteLimited-1 downto 0);
        variable xrem : unsigned(x'length-bitsToDelete-1 downto 0);
        variable y    : unsigned(x'length-bitsToDelete-1 downto 0);

        constant OVF_MASK_ZERO : unsigned(bitsToDeleteLimited-1 downto 0) := (others => '0');

        variable ovf : boolean;
    begin


        if bitsToDelete = 0 then
            y := x;
        elsif bitsToDelete < 0 then
            y := resize(x, x'length - bitsToDelete);
        else

            ovf  := (x(x'length-1 downto x'length-bitsToDelete) /= OVF_MASK_ZERO);
            xdel := x(x'length-1 downto x'length-bitsToDelete);
            xrem := x(x'length-bitsToDelete-1 downto 0);

            -- check if overflow has occurred
            if ovf then
                case ovfMode is
                    when OVF_SAT =>
                        y := (others => '1');

                    when OVF_SAT_ZERO =>
                        y := (others => '0');

                    when OVF_SAT_SYM =>
                        y := (others => '1');

                    when OVF_WRAP =>
                        if saturateBits = 0 then
                            y := xrem;
                        else
                            y(y'length-1 downto y'length-saturateBits) := (others => '1');
                            y(y'length-saturateBits-1 downto 0)        := xrem(y'length-saturateBits-1 downto 0);
                        end if;

                    when OVF_WAP_SM =>
                        y := xrem;

                    when others => null;
                end case;
            else
                y := xrem;
            end if;

        end if;

        return y;

    end function;

    --------------------------------------------------------------------------------
    -- function to get the number of carry bits required for the rounding
    -- computation
    --------------------------------------------------------------------------------

    function GetNumOfCarryBits(ISUNSGNDOUT : boolean; ROUND_ENABLED : boolean) return integer is
    begin
        if (ISUNSGNDOUT = true) and ROUND_ENABLED then
            return 1;
        else
            return 0;
        end if;
    end GetNumOfCarryBits;

    --------------------------------------------------------------------------------
    -- function to get the bit vector representing the minimum possible value
    --------------------------------------------------------------------------------

    function GetMin(width : positive; usedBits : positive; isSigned : boolean) return std_logic_vector is
        variable y : std_logic_vector(width-1 downto 0);
    begin

        if isSigned then

            if width /= usedBits then
                y(width-1 downto usedBits) := (others => '1');
            end if;

            y(usedBits-1)          := '1';
            y(usedBits-2 downto 0) := (others => '0');

        else

            y := (others => '0');

        end if;

        return y;
    end;

    --------------------------------------------------------------------------------
    -- function to get the bit vector representing the maximum possible value
    --------------------------------------------------------------------------------

    function GetMax(width : positive; usedBits : positive; isSigned : boolean) return std_logic_vector is
        variable y : std_logic_vector(width-1 downto 0);
    begin

        -- set value of unused bits, if there are any
        if usedBits /= width then
            y(width-1 downto usedBits) := (others => '0');
        end if;

        if isSigned then
            y(usedBits-1)          := '0';
            y(usedBits-2 downto 0) := (others => '1');
        else
            y(usedBits-1 downto 0) := (others => '1');
        end if;

        return y;
    end;

    --------------------------------------------------------------------------------
    -- function to check if any bits in a vector are one
    --------------------------------------------------------------------------------

    function AreAnyOne(inputVector : std_logic_vector) return boolean is
    begin
        return unsigned(inputVector) /= 0;
    end function;

    --------------------------------------------------------------------------------
    -- function to check if all bits in a vector are zeros
    --------------------------------------------------------------------------------

    function AreAllZero(INPUT_VECTOR : std_logic_vector; UPPER_LIMIT, LOWER_LIMIT : integer) return boolean is
    begin
        for i in UPPER_LIMIT downto LOWER_LIMIT loop
            if INPUT_VECTOR(i) /= '0' then
                return false;
            end if;
        end loop;
        return true;
    end;

    --------------------------------------------------------------------------------
    -- function to check if all bits in a vector are ones
    --------------------------------------------------------------------------------

    function AreAllOne(INPUT_VECTOR : std_logic_vector; UPPER_LIMIT, LOWER_LIMIT : integer) return boolean is
    begin
        for i in UPPER_LIMIT downto LOWER_LIMIT loop
            if INPUT_VECTOR(i) /= '1' then
                return false;
            end if;
        end loop;
        return true;
    end;

    ---------------------------------------------------------------------------
    -- function to convert from integer to boolean type
    ---------------------------------------------------------------------------

    function to_boolean(VALUE : integer) return boolean is
    begin
        if value = 0 then
            return false;
        else
            return true;
        end if;
    end;

    ---------------------------------------------------------------------------
    -- function to convert from std_logic to boolean type
    ---------------------------------------------------------------------------

    function to_boolean(VALUE : std_logic) return boolean is
    begin
        if value = '0' then
            return false;
        else
            return true;
        end if;
    end;

    ---------------------------------------------------------------------------
    -- function to convert from boolean to std_logic type
    ---------------------------------------------------------------------------

    function to_std_logic(VALUE : boolean) return std_logic is
    begin
        if value = false then
            return '0';
        else
            return '1';
        end if;
    end;

    ---------------------------------------------------------------------------
    -- function to determin the max of two integers
    ---------------------------------------------------------------------------

    function max(a, b : integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
    end;


    ---------------------------------------------------------------------------
    -- function to determine if an integer is odd
    ---------------------------------------------------------------------------

    function isOdd(value : integer) return boolean is
        constant VALUE_WIDTH : integer                        := bitWidthFor(value, false);
        variable valueVec    : signed(VALUE_WIDTH-1 downto 0) := to_signed(value, VALUE_WIDTH);
    begin
        if (valueVec(0) = '1') then
            return true;
        else
            return false;
        end if;
    end;


    ---------------------------------------------------------------------------
    -- function to determine if an integer is even
    ---------------------------------------------------------------------------

    function isEven(value : integer) return boolean is
        constant VALUE_WIDTH : integer                        := bitWidthFor(value, false);
        variable valueVec    : signed(VALUE_WIDTH-1 downto 0) := to_signed(value, VALUE_WIDTH);
    begin
        if (valueVec(0) = '0') then
            return true;
        else
            return false;
        end if;
    end;


    ---------------------------------------------------------------------------
    -- function to determine the position of the msb of a positive number
    -- e.g. for msbPosition(3), 2 is returned
    ---------------------------------------------------------------------------

    function msbPosition(val : positive) return natural is
        variable pos        : integer  := 1;
        variable valWorking : positive := val;
    begin
        if (valWorking = 1) then
            return 1;
        end if;

        while (valWorking /= 1) loop
            pos        := pos + 1;
            valWorking := valWorking / 2;
        end loop;

        return pos;
    end;


    ---------------------------------------------------------------------------
    -- function to determine if a positive number is a power of 2
    ---------------------------------------------------------------------------

    function isPower2(val : positive) return boolean is
    begin
        if (val = 1) then
            return(true);
        end if;

        if (val = (2 ** (msbPosition(val)-1))) then
            return true;
        else
            return false;
        end if;
    end;


    ---------------------------------------------------------------------------
    -- function to determine ceil(log(val)/log(2)) using integers only
    ---------------------------------------------------------------------------

    function log2Ceil(val : positive) return natural is
        variable result     : natural := 0;
        variable valWorking : natural := val;
    begin
        while valWorking > 0 loop
            valWorking := valWorking / 2;
            result     := result + 1;
        end loop;

        if (isPower2(val)) then
            result := result - 1;
        end if;

        return result;
    end;


    ---------------------------------------------------------------------------
    -- function to determine the bit-width required to represent a given integer.
    -- Note that the isUnisgned boolean is to indicate the signage of the vector
    -- that the integer could be assigned to and NOT the signage of the integer itself.
    ---------------------------------------------------------------------------

    function bitWidthFor(value : integer; isTargetVectorUnsigned : boolean) return positive is
        variable width    : integer := 0;
        variable valueNeg : integer := 0;
    begin

        if (value = 0) then
            return 1;
        end if;

        if ((isTargetVectorUnsigned) and (value = 1)) then
            return 1;
        end if;

        if (value > 0) then
            width := log2Ceil(value);

            if not(isTargetVectorUnsigned) then
                width := width + 1;
            end if;

            if (isPower2(value)) then
                width := width + 1;
            end if;

        else
            valueNeg := value * (-1);
            width    := log2Ceil(valueNeg);
            width    := width + 1;
        end if;

        return width;
    end;

end p_fxp;
