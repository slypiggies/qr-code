library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity vga_wrapper is
	port (
		clk: in std_logic;
		addr: out vec_2_p.vec_2_t;
		px_i: in px_t;
		h_sync, v_sync: out std_logic;
		px_o: out px_t
	);
end entity;

architecture vga_wrapper of vga_wrapper is
	signal addr_2: vec_2_p.vec_2_t;
	signal h_sync_2, v_sync_2: std_logic;
begin
	addr <= addr_2;
	px_o <=
		px_i when vec_2_p.to_natural(addr_2) < H * V
		else 0;
	
	vga_i: entity vga port map (
		clk => clk,
		h_sync => h_sync_2, v_sync => v_sync_2,
		addr => addr_2
	);
	
	delayer_2_i: entity delayer_2 generic map (DELAY => BRAM_R_DELAY) port map (
		rst => '0', clk => clk,
		i => to_integer(h_sync_2), i_2 => to_integer(v_sync_2),
		to_std_logic(o) => h_sync, to_std_logic(o_2) => v_sync,
		we => open -- I don't know enough VGA to utilize this.
	);
end architecture;
