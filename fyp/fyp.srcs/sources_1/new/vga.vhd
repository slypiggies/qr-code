-- https://web.archive.org/web/20220329193558/https://web.mit.edu/6.111/www/s2004/NEWKIT/vga.shtml

library ieee, vivado_sucks; use ieee.all, work.all, vivado_sucks.all;
use std_logic_1164.all, helper.all, fixed_pkg.all;

entity vga is
	port (
		clk: in std_logic;
		h_sync, v_sync: out std_logic;
		addr: out vec_2_p.vec_2_t
	);
end entity;

architecture vga of vga is
	signal addr_2: vec_2_p.vec_2_t;
begin
	addr <= addr_2;
	process (all) is begin
		if rising_edge(clk) then
			addr_2 <= vec_2_p.inc_h(addr_2, vec_2_p.to_vec_2_t(
				H + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH,
				V + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH
			));
			if
				addr_2.h >= vec_2_p.to_tp_t(H + H_FRONT_PORCH)
				and addr_2.h < vec_2_p.to_tp_t(H + H_FRONT_PORCH + H_SYNC_PULSE)
			then
				h_sync <= H_POLARITY;
			else
				h_sync <= not H_POLARITY;
			end if;
			if
				addr_2.v >= vec_2_p.to_tp_t(V + V_FRONT_PORCH)
				and addr_2.v < vec_2_p.to_tp_t(V + V_FRONT_PORCH + V_SYNC_PULSE)
			then
				v_sync <= V_POLARITY;
			else
				v_sync <= not V_POLARITY;
			end if;
		end if;
	end process;
end architecture;
