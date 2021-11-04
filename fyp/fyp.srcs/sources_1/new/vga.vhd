library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		
		ADDR_DEPTH: natural
	);
	port (
		reset: in std_logic;
		clk25: in std_logic;
		VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
		VGA_HS, VGA_VS: out std_logic;
		addr: out std_logic_vector(ADDR_DEPTH - 1 downto 0);
		pixel: in std_logic_vector(11 downto 0)
	);
end entity;

architecture vga_a of vga is
	signal addr2: unsigned(addr'range);
	signal h_cnt, v_cnt: unsigned(addr'range);
begin
	addr <= std_logic_vector(addr2);
	
	VGA_HS <= H_POLARITY when h_cnt >= H + H_FRONT_PORCH and h_cnt < H + H_FRONT_PORCH + H_SYNC_PULSE
		else not H_POLARITY;
	VGA_VS <= V_POLARITY when v_cnt >= V + V_FRONT_PORCH and v_cnt < V + V_FRONT_PORCH + V_SYNC_PULSE
		else not V_POLARITY;
	
	process (all) begin
		if reset = '1' then
			addr2 <= (others => '0');
			h_cnt <= (others => '0');
			v_cnt <= (others => '0');
		elsif rising_edge(clk25) then
			if h_cnt < H + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH - 1 then
				h_cnt <= h_cnt + 1;
			else
				h_cnt <= (others => '0');
				if v_cnt < V + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH - 1 then
					v_cnt <= v_cnt + 1;
				else
					v_cnt <= (others => '0');
				end if;
			end if;
			
			if h_cnt < H and v_cnt < V then
				VGA_R <= pixel(11 downto 8);
				VGA_G <= pixel(7 downto 4);
				VGA_B <= pixel(3 downto 0);
				addr2 <= addr2 + 1;
			else
				VGA_R <= (others => '0');
				VGA_G <= (others => '0');
				VGA_B <= (others => '0');
				if v_cnt = V then
					addr2 <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end architecture;
