-------------------------------------------------------------------------------
-- Automatically generated VHDL code for non-primitive component
-- Design1_1_CE.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.p_fxp.all;


entity Design1_1_CE is
    port (
        ce1 : out std_logic;
        clk : in  std_logic;
        en  : in  std_logic;
        rst : in  std_logic);
end Design1_1_CE;


architecture Design1_1_CE_Arch of Design1_1_CE is
    
    component EnableGenerator
        generic (
            DivisionFactor : integer);
        port (
            ce  : out std_logic;
            clk : in  std_logic;
            en  : in  std_logic;
            rst : in  std_logic);
    end component;
    

begin
    
    EnableGenerator1 : EnableGenerator
    generic map (
        DivisionFactor => 1)
    port map (
        ce  => ce1,
        clk => clk,
        en  => en,
        rst => rst);
    

end Design1_1_CE_Arch;


