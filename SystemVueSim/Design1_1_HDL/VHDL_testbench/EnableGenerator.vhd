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
-- EnableGenerator - generates an enable strobe with a frequency
-- equal to clk / DivisionFactor.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.p_fxp.all;

entity EnableGenerator is
    generic (
        DivisionFactor : integer := 2);
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        en  : in  std_logic;
        ce  : out std_logic);
end entity;

architecture EnableGeneratorArch of EnableGenerator is

    -- calculate required counter width
    constant N          : integer                := log2ceil(DivisionFactor);
    constant WRAP_VALUE : unsigned(N-1 downto 0) := to_unsigned(DivisionFactor-1, N);

    signal counter : unsigned(N-1 downto 0);
    signal newEn   : std_logic;
    
begin

    div1 : if DivisionFactor = 1 generate

        ce <= en;
        
    end generate;

    divN : if DivisionFactor > 1 generate

        process (clk)
        begin
            if clk'event and clk = '1' then
                if rst = '1' then
                    counter <= (others => '0');
                    newEn   <= '1';
                elsif en = '1' then
                    if counter = WRAP_VALUE then
                        counter <= (others => '0');
                        newEn   <= '1';
                    else
                        counter <= counter + 1;
                        newEn   <= '0';
                    end if;
                end if;
            end if;
        end process;

        ce <= en and newEn;

    end generate;

end architecture;
