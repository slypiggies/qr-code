library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_sccb_tb is end entity;

architecture ov_sccb_tb_a of ov_sccb_tb is
	constant PERIOD100: time := 10 ns;
	signal reset, clk100, clk1400ns, scl, sda, tx_ed: std_logic;
	
	component clk_divider is
		generic (
			divider: positive
		);
		port (
			reset: in std_logic;
			i: in std_logic;
			o: out std_logic
		);
	end component;
	component ov_sccb is
		port (
			reset: in std_logic;
			CLK100, clk1400ns: in std_logic;
			addr: in std_logic_vector(7 downto 0);
			d: in std_logic_vector(15 downto 0);
			scl: out std_logic;
			sda: inout std_logic;
			tx_ed: out std_logic;
			en: in std_logic
		);
	end component;
begin
	clk_divider_i: clk_divider generic map (
		divider => 140
	) port map (
		reset => reset,
		i => clk100,
		o => clk1400ns
	);
	
	ov_sccb_i: ov_sccb port map (
		reset => reset,
		CLK100 => clk100,
		clk1400ns => clk1400ns,
		addr => X"42",
		d => B"01010101_00110011",
		scl => scl,
		sda => sda,
		tx_ed => tx_ed,
		en => '1'
	);

	process begin
		clk100 <= '0';
		reset <= '1';
		while true loop
			wait for PERIOD100 / 2;
			clk100 <= not clk100;
			reset <= '0';
		end loop;
	end process;
end architecture;
