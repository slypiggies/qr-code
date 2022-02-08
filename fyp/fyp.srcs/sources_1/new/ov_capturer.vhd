library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity ov_capturer is
	generic (
		ADDR_LENGTH: natural
	);
	port (
		reset: in std_logic;
		OV_PCLK, OV_HREF, OV_VSYNC: in std_logic;
		OV_D: in std_logic_vector(7 downto 0);
		we: out std_logic;
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: out unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture ov_capturer_a of ov_capturer is
	signal we_2: std_logic;
	signal addr_2: unsigned(addr'range);
	signal pixel_2: std_logic_vector(pixel'range);
	signal shift_reg: std_logic_vector(15 downto 0);
begin
	we <= we_2;
	addr <= addr_2;
	pixel_2 <=
		shift_reg(15 downto 15 - COLOR_LENGTH + 1) & shift_reg(10 downto 10 - COLOR_LENGTH + 1) & shift_reg(4 downto 4 - COLOR_LENGTH + 1) when USE_RGB565
		else shift_reg(7 downto 7 - COLOR_LENGTH + 1) when NO_CONFIG
		else shift_reg(15 downto 15 - COLOR_LENGTH + 1);
	pixel <= unsigned(pixel_2);
	
	process (all) begin
		if reset = '1' or OV_VSYNC = '1' then
			we_2 <= '1';
			addr_2 <= (others => '1');
		elsif rising_edge(OV_PCLK) and OV_HREF = '1' then
			we_2 <= not we_2;
			shift_reg <= shift_reg(7 downto 0) & OV_D;
			if we_2 = '0' then
				addr_2 <= addr_2 + 1;
			end if;
		end if;
	end process;
end architecture;
