library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_capturer_rgb565 is
	generic (
		ADDR_DEPTH: natural
	);
	port (
		reset: in std_logic;
		OV_PCLK, OV_HREF, OV_VSYNC: in std_logic;
		OV_D: in std_logic_vector(7 downto 0);
		we: out std_logic;
		addr: out std_logic_vector(ADDR_DEPTH - 1 downto 0);
		pixel: out std_logic_vector(11 downto 0)
	);
end entity;

architecture ov_capturer_rgb565_a of ov_capturer_rgb565 is
	signal we2: std_logic;
	signal addr2: unsigned(addr'range);
	signal shift_reg: std_logic_vector(15 downto 0);
begin
	we <= we2;
	addr <= std_logic_vector(addr2);
	pixel <= shift_reg(15 downto 12) & shift_reg(10 downto 7) & shift_reg(4 downto 1); 
	
	process (all) begin
		if reset = '1' or OV_VSYNC = '1' then
			we2 <= '1';
			addr2 <= (others => '0');
		elsif rising_edge(OV_PCLK) and OV_HREF = '1' then
			we2 <= not we2;
			shift_reg <= shift_reg(7 downto 0) & OV_D;
			if we2 = '0' then
				addr2 <= addr2 + 1;
			end if;
		end if;
	end process;
end architecture;
