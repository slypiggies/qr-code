library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity vga is
	generic (
		H: natural;
		H_FRONT_PORCH: natural;
		H_SYNC_PULSE: natural;
		H_BACK_PORCH: natural;
		H_POLARITY: std_logic;
		V: natural;
		V_FRONT_PORCH: natural;
		V_SYNC_PULSE: natural;
		V_BACK_PORCH: natural;
		V_POLARITY: std_logic;
		ADDR_LENGTH: natural
	);
	port (
		reset: in std_logic;
		clk: in std_logic;
		r, g, b: out std_logic_vector(3 downto 0);
		h_sync, v_sync: out std_logic;
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: in unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture vga_a of vga is
	signal r_2: unsigned(r'range);
	signal g_2: unsigned(g'range);
	signal b_2: unsigned(b'range);
	signal addr_2: unsigned(addr'range);
	signal h_cnt, v_cnt: unsigned(addr'range);
begin
	r <= std_logic_vector(r_2);
	g <= std_logic_vector(g_2);
	b <= std_logic_vector(b_2);
	addr <= addr_2;
	process (all) begin
		if reset = '1' then
			addr_2 <= (others => '0');
			h_cnt <= (others => '0');
			v_cnt <= (others => '0');
		elsif rising_edge(clk) then
			if h_cnt < to_unsigned(H + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH - 1, h_cnt'length) then
				h_cnt <= h_cnt + 1;
			else
				h_cnt <= (others => '0');
				if v_cnt < to_unsigned(V + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH - 1, v_cnt'length) then
					v_cnt <= v_cnt + 1;
				else
					v_cnt <= (others => '0');
				end if;
			end if;
			
			if h_cnt >= to_unsigned(H + H_FRONT_PORCH, h_cnt'length) and h_cnt < to_unsigned(H + H_FRONT_PORCH + H_SYNC_PULSE, h_cnt'length) then
				h_sync <= H_POLARITY;
			else
				h_sync <= not H_POLARITY;
			end if;
			if v_cnt >= to_unsigned(V + V_FRONT_PORCH, v_cnt'length) and v_cnt < to_unsigned(V + V_FRONT_PORCH + V_SYNC_PULSE, v_cnt'length) then
				v_sync <= V_POLARITY;
			else
				v_sync <= not V_POLARITY;
			end if;
			
			if h_cnt < to_unsigned(H, h_cnt'length) and v_cnt < to_unsigned(V, v_cnt'length) then
				if USE_RGB565 then
					r_2 <= pixel(pixel'left downto pixel'left - COLOR_LENGTH + 1);
					g_2 <= pixel(pixel'left - COLOR_LENGTH downto pixel'right + COLOR_LENGTH);
					b_2 <= pixel(pixel'right + COLOR_LENGTH - 1 downto pixel'right);
				else
					if r_2'length = pixel'length then
						r_2 <= pixel;
						g_2 <= pixel;
						b_2 <= pixel;
					else
						r_2 <= pixel & (r_2'length - pixel'length downto 1 => '0');
						g_2 <= pixel & (g_2'length - pixel'length downto 1 => '0');
						b_2 <= pixel & (b_2'length - pixel'length downto 1 => '0');
					end if;
				end if;
				addr_2 <= addr_2 + 1;
			else
				r_2 <= (others => '0');
				g_2 <= (others => '0');
				b_2 <= (others => '0');
				if v_cnt = to_unsigned(V, v_cnt'length) then
					addr_2 <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end architecture;
