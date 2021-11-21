library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity ov_controller is
	generic (
		OV_ADDR: std_logic_vector(7 downto 0);
		USE_RGB565: boolean;
		NO_CONFIG: boolean
	);
	port (
		reset: in std_logic;
		CLK100, clk25, clk1400ns: in std_logic;
		OV_SIOC: out std_logic;
		OV_SIOD: inout std_logic;
		OV_PWDN: out std_logic;
		OV_RESET: out std_logic;
		OV_XCLK: out std_logic
	);
end entity;

architecture ov_controller_a of ov_controller is
	signal tx_ed, en: std_logic;
	signal config: std_logic_vector(15 downto 0);
begin
	OV_PWDN <= reset;
	OV_RESET <= not reset;
	OV_XCLK <= clk25;
	
	ov_sccb_i: entity ov_sccb port map (
		reset => reset,
		CLK100 => CLK100,
		clk1400ns => clk1400ns,
		addr => OV_ADDR,
		d => config,
		scl => OV_SIOC,
		sda => OV_SIOD,
		tx_ed => tx_ed,
		en => en
	);
	
	ov_config_i: entity ov_config generic map (
		USE_RGB565 => USE_RGB565,
		NO_CONFIG => NO_CONFIG
	) port map (
		reset => reset,
		CLK100 => CLK100,
		tx_ed => tx_ed,
		config => config,
		en => en
	);
end architecture;
