library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity ov_sccb_tb is
	generic (
		ADDR: std_logic_vector(7 downto 0);
		D: std_logic_vector(15 downto 0);
		EN: std_logic
	);
	port (
		reset, clk100: in std_logic;
		scl: out std_logic;
		sda: inout std_logic;
		tx_ed: out std_logic
	);
end entity;

architecture ov_sccb_tb_a of ov_sccb_tb is
	signal clk1400ns: std_logic;
begin
	clk_divider_1400ns_i: entity clk_divider generic map (
		divider => 140
	) port map (reset => reset, i => clk100, o => clk1400ns);
	
	ov_sccb_i: entity ov_sccb port map (
		reset => reset,
		CLK100 => clk100,
		clk1400ns => clk1400ns,
		addr => ADDR,
		d => D,
		scl => scl,
		sda => sda,
		tx_ed => tx_ed,
		en => EN
	);
end architecture;
