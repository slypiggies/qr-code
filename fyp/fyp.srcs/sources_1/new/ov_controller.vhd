library ieee;
use ieee.all;
use std_logic_1164.all;
use work.all;
use helper.all;

entity ov_controller is
	port (
		reset_i: in std_logic;
		reset_o, pwdn: out std_logic;
		clk, clk100: in std_logic;
		scl: out std_logic;
		sda: inout std_logic;
		xclk: out std_logic
	);
end entity;

architecture ov_controller_a of ov_controller is
	signal clk25, clk1400ns, ed, en: std_logic;
	signal config: std_logic_vector(15 downto 0);
begin
	reset_o <= not reset_i;
	pwdn <= reset_i;
	xclk <= clk25;
	
	clk_divider_25_i: entity clk_divider generic map (
		DIVIDER => 4
	) port map (reset => reset_i, i => clk100, o => clk25);
	clk_divider_1400ns_i: entity clk_divider generic map (
		DIVIDER => 140
	) port map (reset => reset_i, i => clk100, o => clk1400ns);
	
	ov_sccb_i: entity ov_sccb port map (
		reset => reset_i,
		clk100 => clk100,
		clk1400ns => clk1400ns,
		addr => OV_ADDR,
		d => config,
		scl => scl,
		sda => sda,
		ed => ed,
		en => en
	);
	
	ov_config_i: entity ov_config port map (
		reset => reset_i,
		clk => clk,
		tx_ed => ed,
		config => config,
		en => en
	);
end architecture;
