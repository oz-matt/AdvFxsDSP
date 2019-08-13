-- Template for GenericFilter VHDL
-- Created by script processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.p_fxp.all;

entity FIR_Fxp1 is

    generic
    (
        FxpCoeff : string;

        dataInWL  : integer;
        dataInIWL : integer;
        dataInSGN : integer;

        AccumulatorWordlength        : integer;
        AccumulatorIntegerWordlength : integer;
        AccumulatorIsSigned          : integer;

        dataOutWL  : integer;
        dataOutIWL : integer;
        dataOutSGN : integer;

        OutputOverflow       : natural;
        OutputQuantization   : natural;
        OutputSaturationBits : integer;

        DecimationFactor    : natural;
        InterpolationFactor : natural

    );
    port
    (
        -- Port: dataIns
        CLK    : in std_logic;
        CE     : in std_logic;
        RST    : in std_logic;
        dataIn : in std_logic_vector(dataInWL-1 downto 0);

        -- Port: dataOuts
        RDY     : out std_logic;
        dataOut : out std_logic_vector(dataOutWL -1 downto 0)
    );

end FIR_Fxp1;

architecture FIR_Fxp1_A of FIR_Fxp1 is

    component FIR_Fxp1_GNRC
        port
        (
            x     : in  std_logic_vector(dataInWL-1 downto 0);
            y     : out std_logic_vector(AccumulatorWordlength-1 downto 0);
            sor   : out std_logic;
            reset : in  std_logic;
            nsi   : in  std_logic;
            clk   : in  std_logic
        );
    end component;

    signal x           : std_logic_vector(dataInWL-1 downto 0);
    signal Acc         : std_logic_vector(AccumulatorWordlength-1 downto 0);
    signal sor         : std_logic;
    signal counter     : integer range 0 to DecimationFactor-1;
    signal rdyInternal : std_logic;
    
begin

    -- in reset, pass zeros into the filter to flush out any internal data
    x <= (others => '0') when RST = '1' else dataIn;

    -- instantiate the filter
    FilterInst : FIR_Fxp1_GNRC
    port map(x => x, y => Acc, sor => sor, reset => RST, nsi => CE, clk => CLK);

    ----------------------------------------------------------------------------
    -- rdy logic for single rate, decimation and interpolation modes
    ----------------------------------------------------------------------------

    generate_single_rate : if (DecimationFactor = 1) and (InterpolationFactor = 1) generate
        rdyInternal <= CE;
    end generate;

    generate_decimation : if DecimationFactor > 1 generate

        -- counter for decimation
        process (CLK)
        begin
            if CLK'event and clk = '1' then
                if RST = '1' then
                    counter <= 0;
                elsif CE = '1' then
                    if counter = DecimationFactor-1 then
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                end if;
            end if;
        end process;

        rdyInternal <= '1' when (CE = '1' and counter = 0) else '0';
        
    end generate;

    generate_interpolation : if InterpolationFactor > 1 generate
        rdyInternal <= not RST;
    end generate;

    RDY <= rdyInternal;

    ----------------------------------------------------------------------------
    -- convert and register filter output ensuring its valid when rdy strobe occurs
    ----------------------------------------------------------------------------

    process (clk)
        variable dataValid : boolean;
    begin
        if clk'event and clk = '1' then
            
            if rst = '1' then
                dataValid := false;
            elsif sor = '1'then
                dataValid := true;
            end if;

            if rst = '1' then
                dataOut <= (others => '0');
            elsif rdyInternal = '1' and dataValid then
                dataOut <= FxpConvert(Acc,
                                      (AccumulatorWordlength,
                                       AccumulatorIntegerWordlength,
                                       to_boolean(AccumulatorIsSigned)),
                                      (dataOutWL,
                                       dataOutIWL,
                                       to_boolean(dataOutSGN)),
                                      ToFxpQznModeT(OutputQuantization),
                                      ToFxpOvfModeT(OutputOverflow),
                                      OutputSaturationBits);
            end if;
            
        end if;
    end process;


end FIR_Fxp1_A;


