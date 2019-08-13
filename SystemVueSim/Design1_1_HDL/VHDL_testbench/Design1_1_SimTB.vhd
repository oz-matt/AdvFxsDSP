-------------------------------------------------------------------------------
-- Automatically generated VHDL code for non-primitive component
-- Design1_1_SimTB.vhd
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.p_fxp.all;
library work;
use work.p_testbench.all;
library std;
use std.textio.all;


entity Design1_1_SimTB is
end Design1_1_SimTB;


architecture Design1_1_SimTB_Arch of Design1_1_SimTB is
    
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
    
    component EnableGenerator
        generic (
            DivisionFactor : integer);
        port (
            ce  : out std_logic;
            clk : in  std_logic;
            en  : in  std_logic;
            rst : in  std_logic);
    end component;
    
    component FileInputProcess
        generic (
            RegisterLength : integer;
            TestVectorFile : string);
        port (
            clk     : in  std_logic;
            dataOut : out std_logic_vector(RegisterLength-1 downto 0);
            en      : in  std_logic;
            rst     : in  std_logic;
            stop    : in  std_logic);
    end component;
    
    component FileOutputProcess
        generic (
            OutputSignage  : string;
            RegisterLength : integer;
            TestVectorFile : string);
        port (
            clk    : in std_logic;
            dataIn : in std_logic_vector(RegisterLength-1 downto 0);
            en     : in std_logic;
            rst    : in std_logic;
            stop   : in std_logic);
    end component;
    
    signal UUT_dp1 : std_logic_vector(31 downto 0);
    signal UUT_dp2 : std_logic_vector(31 downto 0);
    signal ce      : std_logic;
    signal ce1     : std_logic;
    signal clk     : std_logic;
    signal en      : std_logic;
    signal rst     : std_logic;
    signal stop    : std_logic;

begin
    
    
    stop <= stopSimulation;
    
    
    -- generate clock signal 
    ClockGenerator_inst : process
    
      constant localClockPeriod : time    := 1.04166666666666660000e-005 sec;
      variable tempLine         : line;
      file setupFILE            : text;
    
    begin
    
        clk <= '1';
    
        while stop /= '1' loop
    
            wait for localClockPeriod/2;
            clk <= '0';    
            wait for localClockPeriod/2;
            clk <= '1';
    
        end loop;
    
        wait for localClockPeriod/2;
        clk <= '0';
        wait for localClockPeriod/2;
        clk <= '1';
        wait for localClockPeriod/2;
    
        displaySimCompleteMsg;
    
        wait;
    
    end process;
    
    
    
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
        dp1 => UUT_dp1,
        dp2 => UUT_dp2,
        rst => rst);
    
    
    EnableGenerator_inst : EnableGenerator
    generic map (
        DivisionFactor => 1)
    port map (
        ce  => ce,
        clk => clk,
        en  => en,
        rst => rst);
    
    
    FileInputProcess_dp1 : FileInputProcess
    generic map (
        RegisterLength => 32,
        TestVectorFile => "dp1.txt")
    port map (
        clk     => clk,
        dataOut => UUT_dp1,
        en      => ce1,
        rst     => rst,
        stop    => stop);
    
    
    FileOutputProcess_dp2 : FileOutputProcess
    generic map (
        OutputSignage  => "signed",
        RegisterLength => 32,
        TestVectorFile => "dp2.txt")
    port map (
        clk    => clk,
        dataIn => UUT_dp2,
        en     => ce1,
        rst    => rst,
        stop   => stop);
    
    
    -- generate a reset signal
    ResetProcess_inst : process
    
        -- Use 'resetInit' to select the initial value of reset.
        -- Initialise it to '0' if you would like like to run the simulation
        -- prior to reset for example to clear Don't care ('X') conditions.
        constant resetInit : std_logic := '1';
        constant ClockPeriod : time := 1.04166666666666660000e-005 sec;
    
    begin
    
        en <= '0';
        rst  <= resetInit;
        wait for 2.01 * ClockPeriod;
        rst  <= '1';
        wait for 2.0 * ClockPeriod;
        rst  <= '0';
        wait for 6.0 * ClockPeriod;
        en <= '1';
        wait;
    
    end process;
    
    
    

end Design1_1_SimTB_Arch;


