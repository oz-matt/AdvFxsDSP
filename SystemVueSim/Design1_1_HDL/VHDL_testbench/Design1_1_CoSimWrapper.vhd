-------------------------------------------------------------------------------
-- Automatically generated VHDL code for non-primitive component
-- Design1_1_CoSimWrapper.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.p_fxp.all;


entity Design1_1_CoSimWrapper is
    port (
        ce  : in  std_logic;
        clk : in  std_logic;
        dp1 : in  std_logic_vector(31 downto 0);
        dp2 : out std_logic_vector(31 downto 0);
        rst : in  std_logic);
end Design1_1_CoSimWrapper;


architecture Design1_1_CoSimWrapper_Arch of Design1_1_CoSimWrapper is
    
    component Design1_1_CE
        port (
            ce1 : out std_logic;
            clk : in  std_logic;
            en  : in  std_logic;
            rst : in  std_logic);
    end component;
    
    component Design1_1
        port (
            ce1 : in  std_logic;
            clk : in  std_logic;
            dp1 : in  std_logic_vector(31 downto 0);
            dp2 : out std_logic_vector(31 downto 0);
            rst : in  std_logic);
    end component;
    
    signal ce1 : std_logic;

begin
    
    Design1_1_CE_inst : Design1_1_CE
    port map (
        ce1 => ce1,
        clk => clk,
        en  => ce,
        rst => rst);
    
    
    Design1_1_inst : Design1_1
    port map (
        ce1 => ce1,
        clk => clk,
        dp1 => dp1,
        dp2 => dp2,
        rst => rst);
    

end Design1_1_CoSimWrapper_Arch;


