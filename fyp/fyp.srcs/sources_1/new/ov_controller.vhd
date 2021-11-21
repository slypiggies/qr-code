library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
	component ov_config is
		generic (
			USE_RGB565: boolean;
			NO_CONFIG: boolean
		);
		port (
			reset: in std_logic;
			CLK100: in std_logic;
			tx_ed: in std_logic;
			config: out std_logic_vector(15 downto 0);
			en: out std_logic
		);
	end component;
	
	signal tx_ed, en: std_logic;
	signal config: std_logic_vector(15 downto 0);
begin
	OV_PWDN <= reset;
	OV_RESET <= not reset;
	OV_XCLK <= clk25;
	
	ov_sccb_i: ov_sccb port map (
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
	
	ov_config_i: ov_config generic map (
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
