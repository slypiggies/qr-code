library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.all;

entity fyp_tb is end entity;

architecture fyp_tb_a of fyp_tb is
--	constant ENABLE_OV_SCCB_TB: boolean := false;
	constant ENABLE_OV_SCCB_TB: boolean := true;
	
--	constant ENABLE_KERNEL3_TB: boolean := false;
	constant ENABLE_KERNEL3_TB: boolean := true;
	
	constant ADDR: std_logic_vector(7 downto 0) := X"42";
	constant D: std_logic_vector(15 downto 0) := B"01010101_00110011";
	constant EN: std_logic := '1';
	
	constant H: natural := 4;
	constant V: natural := 3;
	constant ADDR_LENGTH: natural := natural(floor(log2(real(H * V)))) + 1;
	constant PIXEL_LENGTH: natural := 4;
	constant PIXEL_R: unsigned(PIXEL_LENGTH - 1 downto 0) := X"F";
	
	constant PERIOD100: time := 10 ns;
	signal clk100: std_logic := '1';
	signal reset: std_logic := '1';
	
	signal scl, sda, tx_ed: std_logic;
	signal addr_r, addr_w: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel_w: unsigned(PIXEL_LENGTH - 1 downto 0);
	signal we: std_logic;
begin
	process begin
		wait for PERIOD100 / 2;
		clk100 <= not clk100;
	end process;
	
	process begin
		wait until falling_edge(clk100);
		reset <= '0';
	end process;
	
	ENABLE_OV_SCCB_TB_if: if ENABLE_OV_SCCB_TB generate
		ov_sccb_tb_i: entity ov_sccb_tb port map (
			reset => reset,
			clk100 => clk100,
			addr => ADDR,
			d => D,
			scl => scl,
			sda => sda,
			tx_ed => tx_ed,
			en => EN
		);
	end generate;
	
	ENABLE_KERNEL3_TB_if: if ENABLE_KERNEL3_TB generate
		kernel3_tb_i: entity kernel3_tb generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH,
			PIXEL_LENGTH => PIXEL_LENGTH
		) port map (
			reset => reset,
			clk100 => clk100,
			addr_r => addr_r,
			addr_w => addr_w,
			pixel_r => PIXEL_R,
			pixel_w => pixel_w,
			we => we
		);
	end generate;
end architecture;
