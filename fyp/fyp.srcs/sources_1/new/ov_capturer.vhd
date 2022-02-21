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
		clk, h_sync, v_sync: in std_logic;
		d: in std_logic_vector(7 downto 0);
		we: out std_logic;
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: out unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture ov_capturer_a of ov_capturer is
	signal we_2: std_logic;
	signal addr_2: unsigned(addr'range);
	signal pixel_2: std_logic_vector(pixel'range);
	signal d_2: std_logic_vector(15 downto 0);
begin
	we <= we_2;
	addr <= addr_2;
	pixel_2 <=
		d_2(15 downto 15 - COLOR_LENGTH + 1) & d_2(10 downto 10 - COLOR_LENGTH + 1) & d_2(4 downto 4 - COLOR_LENGTH + 1) when USE_RGB565
		else d_2(7 downto 7 - COLOR_LENGTH + 1) when not USE_CONFIG
		else d_2(15 downto 15 - COLOR_LENGTH + 1);
	pixel <= unsigned(pixel_2);
	
	process (all) begin
		if reset = '1' or v_sync = '1' then
			we_2 <= '1';
			addr_2 <= (others => '1');
		elsif rising_edge(clk) and h_sync = '1' then
			we_2 <= not we_2;
			d_2 <= d_2(7 downto 0) & d;
			if we_2 = '0' then
				addr_2 <= addr_2 + 1;
			end if;
		end if;
	end process;
end architecture;
