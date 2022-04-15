library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity qr_extreme_points_finder is
	port (
		rst, clk: in std_logic;
		p13, p31: in vec_2_p.vec_2_t; -- Point 13 and 31.
		re: in std_logic;
		ed: in std_logic; -- End of frame. Assumption: if this and `re` are both `'1'`s, `re` will be ignored.
		ep: out vec_2_p.ep_t;
		we: out std_logic
	);
end entity;

architecture qr_extreme_points_finder of qr_extreme_points_finder is
	signal ep_save: vec_2_p.ep_t;
begin
	process (all) is begin
		if rising_edge(clk) then
			we <= ed;
			if rst = '1' or ed = '1' then
				ep <= ep_save;
				ep_save <= vec_2_p.EP_T_INIT;
			elsif re = '1' then
				ep_save <= vec_2_p.arb(ep_save, vec_2_p.arb(p13, p31));
			end if;
		end if;
	end process;
end architecture;
