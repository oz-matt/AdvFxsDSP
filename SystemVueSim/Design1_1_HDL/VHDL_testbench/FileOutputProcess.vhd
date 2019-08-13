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
-- FileOutputProcess
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.p_testbench.all;
use work.p_fxp.all;

entity FileOutputProcess is

    generic (
        RegisterLength : integer;
        TestVectorFile : string;
        OutputSignage  : string);
    port (
        clk    : in std_logic;
        rst    : in std_logic;
        stop   : in std_logic;
        en     : in std_logic;
        dataIn : in std_logic_vector(RegisterLength-1 downto 0));

end entity;

architecture FileOutputProcessArch of FileOutputProcess is
begin

    fileWriter : process(clk)

        variable FileOpen  : boolean := false;
        file tvOutFile     : text;
        variable tvOutLine : line;

    begin

        if clk'event and clk = '1' then

            if rst = '1' then

                if not FileOpen then
                    file_open(tvOutFile, TestVectorFile, write_mode);
                    FileOpen := true;
                end if;

            elsif stop = '1' and FileOpen then

                file_close(tvOutFile);
                FileOpen := false;

            elsif FileOpen and en = '1' then
                
                if OutputSignage = string'("signed") then
                    write(tvOutLine, to_integer(signed(dataIn)));
                else
                    write(tvOutLine, to_integer(unsigned(dataIn)));
                end if;

                writeline(tvOutFile, tvOutLine);

            end if;
        end if;
    end process;

end architecture;
