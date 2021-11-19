library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_capturer is
	generic (
		ADDR_DEPTH: natural;
		USE_RGB565: boolean;
		PIXEL_LENGTH: natural;
		NO_CONFIG: boolean
	);
	port (
		reset: in std_logic;
		OV_PCLK, OV_HREF, OV_VSYNC: in std_logic;
		OV_D: in std_logic_vector(7 downto 0);
		we: out std_logic;
		addr: out std_logic_vector(ADDR_DEPTH - 1 downto 0);
		pixel: out std_logic_vector(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture ov_capturer_a of ov_capturer is
	signal we_2: std_logic;
	signal addr_2: unsigned(addr'range);
	signal shift_reg: std_logic_vector(15 downto 0);
begin
	we <= we_2;
	addr <= std_logic_vector(addr_2);
	pixel <=
		shift_reg(15 downto 12) & shift_reg(10 downto 7) & shift_reg(4 downto 1) when USE_RGB565
		else shift_reg(7 downto 4) when NO_CONFIG
		else shift_reg(15 downto 12);
	
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
