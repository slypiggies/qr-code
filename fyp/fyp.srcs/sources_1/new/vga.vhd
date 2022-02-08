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
		clk25: in std_logic;
		VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
		VGA_HS, VGA_VS: out std_logic;
		addr: out unsigned(ADDR_LENGTH - 1 downto 0);
		pixel: in unsigned(PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture vga_a of vga is
	signal VGA_R_2: unsigned(VGA_R'range);
	signal VGA_G_2: unsigned(VGA_G'range);
	signal VGA_B_2: unsigned(VGA_B'range);
	signal addr_2: unsigned(addr'range);
	signal h_cnt, v_cnt: unsigned(addr'range);
begin
	VGA_R <= std_logic_vector(VGA_R_2);
	VGA_G <= std_logic_vector(VGA_G_2);
	VGA_B <= std_logic_vector(VGA_B_2);
	addr <= addr_2;
	process (all) begin
		if reset = '1' then
			addr_2 <= (others => '0');
			h_cnt <= (others => '0');
			v_cnt <= (others => '0');
		elsif rising_edge(clk25) then
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
				VGA_HS <= H_POLARITY;
			else
				VGA_HS <= not H_POLARITY;
			end if;
			if v_cnt >= to_unsigned(V + V_FRONT_PORCH, v_cnt'length) and v_cnt < to_unsigned(V + V_FRONT_PORCH + V_SYNC_PULSE, v_cnt'length) then
				VGA_VS <= V_POLARITY;
			else
				VGA_VS <= not V_POLARITY;
			end if;
			
			if h_cnt < to_unsigned(H, h_cnt'length) and v_cnt < to_unsigned(V, v_cnt'length) then
				if USE_RGB565 then
					VGA_R_2 <= pixel(pixel'left downto pixel'left - COLOR_LENGTH + 1);
					VGA_G_2 <= pixel(pixel'left - COLOR_LENGTH downto pixel'right + COLOR_LENGTH);
					VGA_B_2 <= pixel(pixel'right + COLOR_LENGTH - 1 downto pixel'right);
				else
					if VGA_R_2'length = pixel'length then
						VGA_R_2 <= pixel;
						VGA_G_2 <= pixel;
						VGA_B_2 <= pixel;
					else
						VGA_R_2 <= pixel & (VGA_R_2'length - pixel'length downto 1 => '0');
						VGA_G_2 <= pixel & (VGA_G_2'length - pixel'length downto 1 => '0');
						VGA_B_2 <= pixel & (VGA_B_2'length - pixel'length downto 1 => '0');
					end if;
				end if;
				addr_2 <= addr_2 + 1;
			else
				VGA_R_2 <= (others => '0');
				VGA_G_2 <= (others => '0');
				VGA_B_2 <= (others => '0');
				if v_cnt = to_unsigned(V, v_cnt'length) then
					addr_2 <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end architecture;
