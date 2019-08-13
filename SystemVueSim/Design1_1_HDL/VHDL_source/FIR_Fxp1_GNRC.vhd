library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIR_Fxp1_GNRC is
port (

	x	: in std_logic_vector(31 downto 0);
	y	: out std_logic_vector(46 downto 0);
	rfs	: out std_logic;
	sor	: out std_logic;
	reset	: in std_logic;
	nsi	: in std_logic;
	clk	: in std_logic);

end FIR_Fxp1_GNRC;

architecture aFIR_Fxp1_GNRC of FIR_Fxp1_GNRC is 

signal x_pipe	:	signed(31 downto 0)	:= (others => '0');
signal M_57	:	signed(37 downto 0)	:= (others => '0');
signal M_25	:	signed(36 downto 0)	:= (others => '0');
signal M_7	:	signed(34 downto 0)	:= (others => '0');
signal M_99	:	signed(38 downto 0)	:= (others => '0');
signal M_101	:	signed(38 downto 0)	:= (others => '0');
signal M_19	:	signed(36 downto 0)	:= (others => '0');
signal M_145	:	signed(39 downto 0)	:= (others => '0');
signal M_107	:	signed(38 downto 0)	:= (others => '0');
signal M_267	:	signed(40 downto 0)	:= (others => '0');
signal M_33	:	signed(37 downto 0)	:= (others => '0');
signal M_113	:	signed(38 downto 0)	:= (others => '0');
signal M_403	:	signed(40 downto 0)	:= (others => '0');
signal M_43	:	signed(37 downto 0)	:= (others => '0');
signal M_483	:	signed(40 downto 0)	:= (others => '0');
signal M_39	:	signed(37 downto 0)	:= (others => '0');
signal M_27	:	signed(36 downto 0)	:= (others => '0');
signal M_1015	:	signed(41 downto 0)	:= (others => '0');
signal M_523	:	signed(41 downto 0)	:= (others => '0');
signal M_159	:	signed(39 downto 0)	:= (others => '0');
signal M_3429	:	signed(43 downto 0)	:= (others => '0');
signal M_2793	:	signed(43 downto 0)	:= (others => '0');
signal M_50	:	signed(37 downto 0)	:= (others => '0');
signal M_14	:	signed(35 downto 0)	:= (others => '0');
signal M_132	:	signed(39 downto 0)	:= (others => '0');
signal M_226	:	signed(39 downto 0)	:= (others => '0');
signal M_86	:	signed(38 downto 0)	:= (others => '0');
signal M_624	:	signed(41 downto 0)	:= (others => '0');
signal M_54	:	signed(37 downto 0)	:= (others => '0');
signal M_1046	:	signed(42 downto 0)	:= (others => '0');
signal M_636	:	signed(41 downto 0)	:= (others => '0');
signal M_5586	:	signed(44 downto 0)	:= (others => '0');


signal tap43_sub57	:	signed(37 downto 0)	:= (others => '0');
signal tap42_sub50	:	signed(38 downto 0)	:= (others => '0');
signal tap41_add14	:	signed(38 downto 0)	:= (others => '0');
signal tap40_add99	:	signed(39 downto 0)	:= (others => '0');
signal tap39_add101	:	signed(40 downto 0)	:= (others => '0');
signal tap38_sub19	:	signed(40 downto 0)	:= (others => '0');
signal tap37_sub145	:	signed(40 downto 0)	:= (others => '0');
signal tap36_sub107	:	signed(41 downto 0)	:= (others => '0');
signal tap35_add107	:	signed(41 downto 0)	:= (others => '0');
signal tap34_add267	:	signed(41 downto 0)	:= (others => '0');
signal tap33_add132	:	signed(42 downto 0)	:= (others => '0');
signal tap32_sub226	:	signed(42 downto 0)	:= (others => '0');
signal tap31_sub403	:	signed(42 downto 0)	:= (others => '0');
signal tap30_sub86	:	signed(42 downto 0)	:= (others => '0');
signal tap29_add483	:	signed(43 downto 0)	:= (others => '0');
signal tap28_add624	:	signed(43 downto 0)	:= (others => '0');
signal tap27_sub54	:	signed(43 downto 0)	:= (others => '0');
signal tap26_sub1015	:	signed(43 downto 0)	:= (others => '0');
signal tap25_sub1046	:	signed(44 downto 0)	:= (others => '0');
signal tap24_add636	:	signed(44 downto 0)	:= (others => '0');
signal tap23_add3429	:	signed(45 downto 0)	:= (others => '0');
signal tap22_add5586	:	signed(45 downto 0)	:= (others => '0');
signal tap21_add5586	:	signed(46 downto 0)	:= (others => '0');
signal tap20_add3429	:	signed(46 downto 0)	:= (others => '0');
signal tap19_add636	:	signed(46 downto 0)	:= (others => '0');
signal tap18_sub1046	:	signed(46 downto 0)	:= (others => '0');
signal tap17_sub1015	:	signed(46 downto 0)	:= (others => '0');
signal tap16_sub54	:	signed(46 downto 0)	:= (others => '0');
signal tap15_add624	:	signed(46 downto 0)	:= (others => '0');
signal tap14_add483	:	signed(46 downto 0)	:= (others => '0');
signal tap13_sub86	:	signed(46 downto 0)	:= (others => '0');
signal tap12_sub403	:	signed(46 downto 0)	:= (others => '0');
signal tap11_sub226	:	signed(46 downto 0)	:= (others => '0');
signal tap10_add132	:	signed(46 downto 0)	:= (others => '0');
signal tap9_add267	:	signed(46 downto 0)	:= (others => '0');
signal tap8_add107	:	signed(46 downto 0)	:= (others => '0');
signal tap7_sub107	:	signed(46 downto 0)	:= (others => '0');
signal tap6_sub145	:	signed(46 downto 0)	:= (others => '0');
signal tap5_sub19	:	signed(46 downto 0)	:= (others => '0');
signal tap4_add101	:	signed(46 downto 0)	:= (others => '0');
signal tap3_add99	:	signed(46 downto 0)	:= (others => '0');
signal tap2_add14	:	signed(46 downto 0)	:= (others => '0');
signal tap1_sub50	:	signed(46 downto 0)	:= (others => '0');
signal tap0_sub57	:	signed(46 downto 0)	:= (others => '0');

signal counter_en : std_logic;
constant LATENCY	: integer  := 4;

begin



    process (clk)
       variable counter    : integer range 0 to LATENCY-1;
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                counter_en     <= '1';
                counter        := 0;
            elsif nsi = '1' and counter_en = '1' then
                if counter = (LATENCY-1) then
                    counter_en <= '0';
                else
                    counter    := counter + 1;
                end if;
            end if;
        end if;
    end process;

    sor <= nsi and (not counter_en);
    rfs <= '0';
	
    InputPipelineStage : process (clk, reset)

	begin

		if (clk'event and clk='1') then

            if (reset = '1') then

                x_pipe <= (others => '0');

			elsif (nsi = '1') then

				x_pipe <= signed(x);

			end if;

		end if;

	end process;

	
	MultiplierBank : process (clk)

	begin

		if (clk'event and clk='1') then

			if (nsi = '1') then

				M_57 <= resize(x_pipe * to_signed( 57, 7 ), 38);
				M_25 <= resize(x_pipe * to_signed( 25, 6 ), 37);
				M_7 <= resize(x_pipe * to_signed( 7, 4 ), 35);
				M_99 <= resize(x_pipe * to_signed( 99, 8 ), 39);
				M_101 <= resize(x_pipe * to_signed( 101, 8 ), 39);
				M_19 <= resize(x_pipe * to_signed( 19, 6 ), 37);
				M_145 <= resize(x_pipe * to_signed( 145, 9 ), 40);
				M_107 <= resize(x_pipe * to_signed( 107, 8 ), 39);
				M_267 <= resize(x_pipe * to_signed( 267, 10 ), 41);
				M_33 <= resize(x_pipe * to_signed( 33, 7 ), 38);
				M_113 <= resize(x_pipe * to_signed( 113, 8 ), 39);
				M_403 <= resize(x_pipe * to_signed( 403, 10 ), 41);
				M_43 <= resize(x_pipe * to_signed( 43, 7 ), 38);
				M_483 <= resize(x_pipe * to_signed( 483, 10 ), 41);
				M_39 <= resize(x_pipe * to_signed( 39, 7 ), 38);
				M_27 <= resize(x_pipe * to_signed( 27, 6 ), 37);
				M_1015 <= resize(x_pipe * to_signed( 1015, 11 ), 42);
				M_523 <= resize(x_pipe * to_signed( 523, 11 ), 42);
				M_159 <= resize(x_pipe * to_signed( 159, 9 ), 40);
				M_3429 <= resize(x_pipe * to_signed( 3429, 13 ), 44);
				M_2793 <= resize(x_pipe * to_signed( 2793, 13 ), 44);

			end if;

		end if;

	end process;

	M_50 <= shift_left(resize(M_25, 38), 1);
	M_14 <= shift_left(resize(M_7, 36), 1);
	M_132 <= shift_left(resize(M_33, 40), 2);
	M_226 <= shift_left(resize(M_113, 40), 1);
	M_86 <= shift_left(resize(M_43, 39), 1);
	M_624 <= shift_left(resize(M_39, 42), 4);
	M_54 <= shift_left(resize(M_27, 38), 1);
	M_1046 <= shift_left(resize(M_523, 43), 1);
	M_636 <= shift_left(resize(M_159, 42), 2);
	M_5586 <= shift_left(resize(M_2793, 45), 1);


	SummationChain : process (clk)

	begin

		if (clk'event and clk='1') then

			if (nsi = '1') then

				tap43_sub57 <= resize("0",38) - resize(M_57,38);
				tap42_sub50 <= resize(tap43_sub57,39) - resize(M_50,39);
				tap41_add14 <= resize(tap42_sub50,39) + resize(M_14,39);
				tap40_add99 <= resize(tap41_add14,40) + resize(M_99,40);
				tap39_add101 <= resize(tap40_add99,41) + resize(M_101,41);
				tap38_sub19 <= resize(tap39_add101,41) - resize(M_19,41);
				tap37_sub145 <= resize(tap38_sub19,41) - resize(M_145,41);
				tap36_sub107 <= resize(tap37_sub145,42) - resize(M_107,42);
				tap35_add107 <= resize(tap36_sub107,42) + resize(M_107,42);
				tap34_add267 <= resize(tap35_add107,42) + resize(M_267,42);
				tap33_add132 <= resize(tap34_add267,43) + resize(M_132,43);
				tap32_sub226 <= resize(tap33_add132,43) - resize(M_226,43);
				tap31_sub403 <= resize(tap32_sub226,43) - resize(M_403,43);
				tap30_sub86 <= resize(tap31_sub403,43) - resize(M_86,43);
				tap29_add483 <= resize(tap30_sub86,44) + resize(M_483,44);
				tap28_add624 <= resize(tap29_add483,44) + resize(M_624,44);
				tap27_sub54 <= resize(tap28_add624,44) - resize(M_54,44);
				tap26_sub1015 <= resize(tap27_sub54,44) - resize(M_1015,44);
				tap25_sub1046 <= resize(tap26_sub1015,45) - resize(M_1046,45);
				tap24_add636 <= resize(tap25_sub1046,45) + resize(M_636,45);
				tap23_add3429 <= resize(tap24_add636,46) + resize(M_3429,46);
				tap22_add5586 <= resize(tap23_add3429,46) + resize(M_5586,46);
				tap21_add5586 <= resize(tap22_add5586,47) + resize(M_5586,47);
				tap20_add3429 <= resize(tap21_add5586,47) + resize(M_3429,47);
				tap19_add636 <= resize(tap20_add3429,47) + resize(M_636,47);
				tap18_sub1046 <= resize(tap19_add636,47) - resize(M_1046,47);
				tap17_sub1015 <= resize(tap18_sub1046,47) - resize(M_1015,47);
				tap16_sub54 <= resize(tap17_sub1015,47) - resize(M_54,47);
				tap15_add624 <= resize(tap16_sub54,47) + resize(M_624,47);
				tap14_add483 <= resize(tap15_add624,47) + resize(M_483,47);
				tap13_sub86 <= resize(tap14_add483,47) - resize(M_86,47);
				tap12_sub403 <= resize(tap13_sub86,47) - resize(M_403,47);
				tap11_sub226 <= resize(tap12_sub403,47) - resize(M_226,47);
				tap10_add132 <= resize(tap11_sub226,47) + resize(M_132,47);
				tap9_add267 <= resize(tap10_add132,47) + resize(M_267,47);
				tap8_add107 <= resize(tap9_add267,47) + resize(M_107,47);
				tap7_sub107 <= resize(tap8_add107,47) - resize(M_107,47);
				tap6_sub145 <= resize(tap7_sub107,47) - resize(M_145,47);
				tap5_sub19 <= resize(tap6_sub145,47) - resize(M_19,47);
				tap4_add101 <= resize(tap5_sub19,47) + resize(M_101,47);
				tap3_add99 <= resize(tap4_add101,47) + resize(M_99,47);
				tap2_add14 <= resize(tap3_add99,47) + resize(M_14,47);
				tap1_sub50 <= resize(tap2_add14,47) - resize(M_50,47);
				tap0_sub57 <= resize(tap1_sub50,47) - resize(M_57,47);
				y <= std_logic_vector(resize(tap0_sub57,47));

			end if;

		end if;

	end process;

end aFIR_Fxp1_GNRC;

