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
-- FileInputProcess
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


entity FileInputProcess is

    generic (
        RegisterLength : integer := 16;
        TestVectorFile : string);
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        en      : in  std_logic;
        stop    : in  std_logic;
        dataOut : out std_logic_vector(RegisterLength-1 downto 0)
    );

end entity;


architecture FileInputProcessArch of FileInputProcess is

    -- check that start phase is within range
    signal endOfFile      : boolean := false;

begin

    -- stop simulation is a tristate global signal defined in p_testbench.vhd
    stopSimulation <= '1' when endOfFile else 'Z';

    FileProcess : process(clk, rst)

        file tvInFile       : text;
        variable tvInLine   : line;
        variable tvInSample : real    := 0.0;
        variable fileOpen   : boolean := false;

    begin

        if clk'event and clk = '1' then

            if rst = '1' then

                if not fileOpen then
                    file_open(tvInFile, TestVectorFile, read_mode);
                    fileOpen := true;
                    readline(tvInFile, tvInLine);
                    read(tvInLine, tvInSample);
                end if;

                endOfFile <= false;

            elsif stop = '1' then

                if fileOpen then
                    file_close(tvInFile);
                    fileOpen := false;
                end if;

            elsif en = '1' and fileOpen then

                if not endfile(tvInFile) then
                    readline(tvInFile, tvInLine);
                    read(tvInLine, tvInSample);
                else
                    file_close(tvInFile);
                    fileOpen  := false;
                    endOfFile <= true;
                end if;

            end if;
        end if;

        dataOut <= CONV_STD_LOGIC_VECTOR(tvInSample, RegisterLength);

    end process;

end architecture;
