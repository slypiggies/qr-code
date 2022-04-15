library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_edge_finder is
	generic (
		N: positive := 1; -- Find the N-th edge.
		DIR_MUL: integer := 1
	);
	port (
		rst, clk: in std_logic;
		pb, pe: in vec_2_p.vec_2_t; -- Point Begin, end.
		addr_offset: in vec_2_p.vec_2_t := vec_2_p.VEC_2_T_ZERO; -- Optional offset applied to the outputs.
		re_qr_edge_finder: in std_logic;
		addr_o: out vec_2_p.vec_2_t;
		addr_i: in vec_2_p.vec_2_t;
		px: in px_t;
		re_i_fb_controller: out std_logic;
		re_o_fb_controller: in std_logic;
		ped: out vec_2_p.vec_2_t; -- Point edge.
		we: out std_logic
	);
end entity;

architecture qr_edge_finder of qr_edge_finder is
	signal pi_2: vec_2_p.vec_2_t;
	signal we_qr_aggregator: std_logic;
	signal state: std_logic;
	signal cnt: natural;
begin
	addr_o <= vec_2_p."+"(pi_2, addr_offset);
	bresenham_i: entity bresenham generic map (DIR_MUL => DIR_MUL) port map (
		rst => rst, clk => clk,
		pb => pb, pe => pe,
		re => re_qr_edge_finder,
		pi => pi_2,
		we => re_i_fb_controller
	);
	
	qr_aggregator_i: entity qr_aggregator port map (
		rst => re_qr_edge_finder, clk => clk,
		addr => addr_i,
		px => px,
		re => re_o_fb_controller,
		ed_i => '0',
		pb => open,
		cnt => open,
		we => we_qr_aggregator,
		ed_o => open
	);
	-- Can't use `delayer` and `vec_2_p.to_natural`, because `natural` can't be converted back to `vec_2_p.vec_2_t`.
	delayer_2_i: entity delayer_2 generic map (
		DELAY =>
			2 -- After finishing a segment, `qr_aggregator` takes 1 clock to notice, 1 clock to set `we`.
			+ 1 -- Want the point just before `pb` from `qr_aggregator`.
	) port map (
		rst => '0', clk => clk,
		i => vec_2_p.to_integer(addr_i.h), i_2 => vec_2_p.to_integer(addr_i.v),
		vec_2_p.to_tp_t(o) => ped.h, vec_2_p.to_tp_t(o_2) => ped.v,
		we => open
	);
	
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			if rst = '1' then
				state <= '0';
			elsif re_qr_edge_finder = '1' then -- Interruptable
				state <= '1';
				cnt <= 0;
			elsif state = '1' and we_qr_aggregator = '1' then
				if cnt = N - 1 then
					state <= '0';
					we <= '1';
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
