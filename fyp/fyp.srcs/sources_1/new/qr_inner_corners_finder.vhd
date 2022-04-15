library ieee, vivado_sucks; use ieee.all, work.all;
use std_logic_1164.all;

entity qr_inner_corners_finder is
	port (
		rst, clk: in std_logic;
		ep: in vec_2_p.ep_t; -- Extreme points.
		re: in std_logic;
		pa, po, po2: out vec_2_p.vec_2_t; -- Point A (upper-left), O (lower-left) and O2 (upper-right). A2 is discarded.
		we: out std_logic
	);
end entity;

architecture qr_inner_corners_finder of qr_inner_corners_finder is
	signal pa_2, pa2_2, po_2, po2_2: vec_2_p.vec_2_t;
	type state_t is (Q_0, Q_1, Q_2, Q_3, Q_4, Q_5, Q_6, Q_7, Q_8, Q_9, Q_10); -- 11-stage pipeline.
	signal state: state_t;
	signal dh, dv, doa, doa2, do2a, do2a2: vec_2_p.vec_2_t; -- The sign doesn't matter, because they will be squared.
	signal dh_ns, dv_ns, doa_ns, doa2_ns, do2a_ns, do2a2_ns: vec_2_p.tp_t; -- Norm squared.
	signal vaor, vao2r: vec_2_p.vec_2_t; -- Vector AO and AO2, 90-degree-rotated around point A. Sign matters.
	signal por, po2r: vec_2_p.vec_2_t; -- Point O and O2, rotated.
	signal doro2, do2ro: vec_2_p.vec_2_t; -- The sign doesn't matter, because they will be squared.
	signal doro2_ns, do2ro_ns: vec_2_p.tp_t; -- Norm squared.
begin
	pa <= pa_2; po <= po_2; po2 <= po2_2;
	process (all) is begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			if rst = '1' then
				state <= Q_0;
			elsif re = '1' and state = Q_0 then -- No interrupt other than `rst`.
				state <= Q_1;
				dh <= vec_2_p."-"(ep.min_h, ep.max_h);
				dv <= vec_2_p."-"(ep.min_v, ep.max_v);
			elsif state = Q_1 then
				state <= Q_2;
				dh_ns <= vec_2_p.norm_sqr(dh);
				dv_ns <= vec_2_p.norm_sqr(dv);
			elsif state = Q_2 then
				state <= Q_3;
				if vivado_sucks.fixed_pkg.">"(dh_ns, dv_ns) then
					po_2 <= ep.min_h; po2_2 <= ep.max_h;
					pa_2 <= ep.min_v; pa2_2 <= ep.max_v;
				else
					po_2 <= ep.min_v; po2_2 <= ep.max_v;
					pa_2 <= ep.min_h; pa2_2 <= ep.max_h;
				end if;
			elsif state = Q_3 then
				state <= Q_4;
				doa <= vec_2_p."-"(po_2, pa_2);
				doa2 <= vec_2_p."-"(po_2, pa2_2);
				do2a <= vec_2_p."-"(po2_2, pa_2);
				do2a2 <= vec_2_p."-"(po2_2, pa2_2);
			elsif state = Q_4 then
				state <= Q_5;
				doa_ns <= vec_2_p.norm_sqr(doa);
				doa2_ns <= vec_2_p.norm_sqr(doa2);
				do2a_ns <= vec_2_p.norm_sqr(do2a);
				do2a2_ns <= vec_2_p.norm_sqr(do2a2);
			elsif state = Q_5 then
				state <= Q_6;
				if vivado_sucks.fixed_pkg.">"(
					vivado_sucks.fixed_pkg.minimum(doa2_ns, do2a2_ns),
					vivado_sucks.fixed_pkg.minimum(doa_ns, do2a_ns)
				) then
					-- Swap point A and A2.
					-- `doa`, `doa2`, `do2a` and `do2a2`, and their `_ns` counterparts are no longer valid from now on.
					pa_2 <= pa2_2;
					pa2_2 <= pa_2;
				end if;
			elsif state = Q_6 then
				state <= Q_7;
				vaor <= vec_2_p.rot_90(vec_2_p."-"(po_2, pa_2));
				vao2r <= vec_2_p.rot_90(vec_2_p."-"(po2_2, pa_2));
			elsif state = Q_7 then
				state <= Q_8;
				por <= vec_2_p."+"(pa_2, vaor);
				po2r <= vec_2_p."+"(pa_2, vao2r);
			elsif state = Q_8 then
				state <= Q_9;
				doro2 <= vec_2_p."-"(por, po2_2);
				do2ro <= vec_2_p."-"(po2r, po_2);
			elsif state = Q_9 then
				state <= Q_10;
				doro2_ns <= vec_2_p.norm_sqr(doro2);
				do2ro_ns <= vec_2_p.norm_sqr(do2ro);
			elsif state = Q_10 then
				state <= Q_0;
				if vivado_sucks.fixed_pkg."<"(do2ro_ns, doro2_ns) then
					-- Swap point O and O2.
					-- All signals related to the rotations are no longer valid from now on.
					po_2 <= po2_2;
					po2_2 <= po_2;
				end if;
				we <= '1';
			end if;
		end if;
	end process;
end architecture;
