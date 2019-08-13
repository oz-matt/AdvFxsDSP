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

--------------------------------------------------------------------------------
--
-- p_testbench
--
-- Declares and defines useful functions and procedures for testbench operation.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;

package p_testbench is

    -- Stop variable
    -- Tristate variable controlled by all input file processes
    -- to stop the simulation when the first end of file is reached.
    signal stopSimulation : std_logic := 'Z';

    -- Current simulation time.
    -- Note that this is different from HDL simulator time.
    -- CurrentTime = 0 on first clock cycle after reset is released.
    signal   currentTime    : real;    
    constant DO_TIME_STAMPS : boolean := true;

    ---------------------------------------------------------------------------
    -- procedure simulation complete message
    ---------------------------------------------------------------------------
    procedure displaySimCompleteMsg;

    ---------------------------------------------------------------------------
    -- conv_std_logic_vector(R : real; N : integer)
    -- Function converts real to std_logic_vector with a specified number
    -- of bits.
    ---------------------------------------------------------------------------
    function conv_std_logic_vector(R : real; N : integer) return std_logic_vector;

    ---------------------------------------------------------------------------
    -- conv_real(x : signed)
    -- Function converts signed to real
    ---------------------------------------------------------------------------
    function conv_real(x : signed) return real;

    ---------------------------------------------------------------------------
    -- conv_real(x : unsigned)
    -- Function converts unsigned to real
    ---------------------------------------------------------------------------
    function conv_real(x : unsigned) return real;

end p_testbench;


-------------------------------------------------------------------------------
-- ****************************************************************************
-------------------------------------------------------------------------------

package body p_testbench is


    -------------------------------------------------------------------------------

    procedure displaySimCompleteMsg is

        variable tempLine : line;

    begin

        write( tempLine, string'("") );
        writeline( output, tempLine );
        write( tempLine, string'("***** simulation complete *****") );
        writeline( output, tempLine );
        write( tempLine, string'("") );
        writeline( output, tempLine );

    end displaySimCompleteMsg;

    ------------------------------------------------------------------------------

    function conv_std_logic_vector(R : real; N : integer)
    return std_logic_vector is
        variable I                   : std_logic_vector(N-1 downto 0);
        variable p                   : real;
        variable x                   : real;
    begin
        I     := (others => '0');
        if R >= 0.0 then
            x := R;
        else
            x := -R;
        end if;

        for n in N-1 downto 0 loop
            p        := 2.0 ** n;
            if abs(x)/p >= 1.0 then
                x    := x - p;
                I(n) := '1';
            else
                I(n) := '0';
            end if;
        end loop;

        if R < 0.0 then
            -- I := std_logic_vector(unsigned(not I) + 1);
            I := unsigned(not I) + 1;
        end if;

        return I;
    end conv_std_logic_vector;

    --------------------------------------------------------------------------------

    function conv_real(x : signed) return real is
        variable R       : real;
        variable msb     : integer;
    begin
        R   := 0.0;
        msb := x'high;

        -- Discard any sign extension.
        for n in x'high downto 0 loop
            if x(n) /= x(x'high) then
                msb := n + 1;
                exit;
            end if;
        end loop;

        -- Compute the unsigned value
        for n in msb-1 downto 0 loop
            if x(n) = '1' then
                R := R + 2.0**n;
            end if;
        end loop;

        -- Add in the sign bit if -ve
        if x(msb) = '1' then
            R := R - 2.0**msb;
        end if;

        return R;
    end conv_real;
    --------------------------------------------------------------------------------

    function conv_real(x : unsigned) return real is
        variable R       : real;
        variable msb     : integer;
    begin
        R := 0.0;

        -- Compute the unsigned value
        for n in x'high downto 0 loop
            if x(n) = '1' then
                R := R + 2.0**n;
            end if;
        end loop;

        return R;
    end conv_real;
    --------------------------------------------------------------------------------

end p_testbench;

