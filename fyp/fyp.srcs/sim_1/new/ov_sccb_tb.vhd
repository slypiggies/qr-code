library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity ov_sccb_tb is end entity;

architecture ov_sccb_tb_a of ov_sccb_tb is
	constant PERIOD100: time := 10 ns;
	signal clk100: std_logic := '0';
	signal reset: std_logic := '1';
	signal clk1400ns, scl, sda, tx_ed: std_logic;
begin
	clk_divider_i: entity clk_divider generic map (
		divider => 140
	) port map (
		reset => reset,
		i => clk100,
		o => clk1400ns
	);
	
	ov_sccb_i: entity ov_sccb port map (
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
		wait for PERIOD100 / 2;
		clk100 <= not clk100;
		reset <= '0';
	end process;
end architecture;
