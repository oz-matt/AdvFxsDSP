-------------------------------------------------------------------------------
-- Automatically generated VHDL code for non-primitive component
-- Design1_1.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.p_fxp.all;


entity Design1_1 is
    port (
        ce1 : in  std_logic;
        clk : in  std_logic;
        dp1 : in  std_logic_vector(31 downto 0);
        dp2 : out std_logic_vector(31 downto 0);
        rst : in  std_logic);
end Design1_1;


architecture Design1_1_Arch of Design1_1 is
    
    component FIR_Fxp1
        generic (
            AccumulatorIntegerWordlength : integer;
            AccumulatorIsSigned          : integer;
            AccumulatorWordlength        : integer;
            DecimationFactor             : integer;
            FxpCoeff                     : string;
            InterpolationFactor          : integer;
            OutputOverflow               : integer;
            OutputQuantization           : integer;
            OutputSaturationBits         : integer;
            dataInIWL                    : integer;
            dataInSGN                    : integer;
            dataInWL                     : integer;
            dataOutIWL                   : integer;
            dataOutSGN                   : integer;
            dataOutWL                    : integer);
        port (
            CE      : in  std_logic;
            CLK     : in  std_logic;
            RDY     : out std_logic;
            RST     : in  std_logic;
            dataIn  : in  std_logic_vector(dataInWL-1 downto 0);
            dataOut : out std_logic_vector(dataOutWL-1 downto 0));
    end component;
    
    signal F1_dataOut : std_logic_vector(31 downto 0);

begin
    
    F1 : FIR_Fxp1
    generic map (
        AccumulatorIntegerWordlength => 3,
        AccumulatorIsSigned          => 1,
        AccumulatorWordlength        => 47,
        DecimationFactor             => 1,
        FxpCoeff                     => "",
        InterpolationFactor          => 1,
        OutputOverflow               => 3,
        OutputQuantization           => 5,
        OutputSaturationBits         => 0,
        dataInIWL                    => 2,
        dataInSGN                    => 1,
        dataInWL                     => 32,
        dataOutIWL                   => 4,
        dataOutSGN                   => 1,
        dataOutWL                    => 32)
    port map (
        CE      => ce1,
        CLK     => clk,
        RDY     => open,
        RST     => rst,
        dataIn  => dp1,
        dataOut => F1_dataOut);
    
    
    dp2 <= F1_dataOut;

end Design1_1_Arch;


