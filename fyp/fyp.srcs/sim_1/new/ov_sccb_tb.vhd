library ieee;
use ieee.all;
use std_logic_1164.all;
use work.all;
use helper_tb.all;

entity ov_sccb_tb is
	port (
		reset, clk100: in std_logic
	);
end entity;

architecture ov_sccb_tb_a of ov_sccb_tb is
	signal clk1400ns: std_logic;
	signal scl, sda, ed: std_logic;
begin
	clk_divider_i: entity clk_divider generic map (
		DIVIDER => 140
	) port map (reset => reset, i => clk100, o => clk1400ns);
	
	ov_sccb_i: entity ov_sccb port map (
		reset => reset,
		clk100 => clk100,
		clk1400ns => clk1400ns,
		addr => ADDR_S,
		d => D_S,
		scl => scl,
		sda => sda,
		ed => ed,
		en => '1'
	);
end architecture;
