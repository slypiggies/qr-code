library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_controller is
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
	component ov_register is
		port (
			reset: in std_logic;
			CLK100: in std_logic;
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
	
	ov_sccb_i: ov_sccb port map (
		reset => reset,
		CLK100 => CLK100,
		clk1400ns => clk1400ns,
		addr => X"42",
		d => cmd,
		scl => OV_SIOC,
		sda => OV_SIOD,
		tx_ed => tx_ed,
		en => en
	);
	
	ov_registers_i: ov_register port map (
		reset => reset,
		CLK100 => CLK100,
		tx_ed => tx_ed,
		cmd => cmd,
		en => en
	);
end architecture;
