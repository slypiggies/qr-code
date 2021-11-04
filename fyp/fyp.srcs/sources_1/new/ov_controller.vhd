library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_controller is
	port (
		reset: in std_logic;
		clk25, clk50: in std_logic;
		OV_SIOC: out std_logic;
		OV_SIOD: inout std_logic;
		OV_PWDN: out std_logic;
		OV_RESET: out std_logic;
		OV_XCLK: out std_logic
	);
end entity;

architecture ov_controller_a of ov_controller is
	component ov_i2c is
		port (
			reset: in std_logic;
			clk50: in std_logic;
			OV_SIOC: out std_logic;
			OV_SIOD: inout std_logic;
			tx_ed: out std_logic;
			en: in std_logic;
			cmd: in std_logic_vector(15 downto 0)
		);
	end component;
	component ov_register is
		port (
			reset: in std_logic;
			clk50: in std_logic;
			tx_ed: in std_logic;
			cmd: out std_logic_vector(15 downto 0);
			en: out std_logic
		);
	end component;
	
	signal tx_ed, en: std_logic;
	signal cmd: std_logic_vector(15 downto 0);
begin
	OV_PWDN <= '0';
	OV_RESET <= not reset;
	OV_XCLK <= clk25;
	
	ov_i2c_i: ov_i2c port map (
		reset => reset,
		clk50 => clk50,
		OV_SIOC => OV_SIOC,
		OV_SIOD => OV_SIOD,
		tx_ed => tx_ed,
		en => en,
		cmd => cmd
	);
	
	ov_registers_i: ov_register port map (
		reset => reset,
		clk50 => clk50,
		tx_ed => tx_ed,
		cmd => cmd,
		en => en
	);
end architecture;
