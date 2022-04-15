library ieee; use ieee.all, work.all;
use std_logic_1164.all;

entity bresenham is
	generic (DIR_MUL: integer := 1);
	port (
		rst, clk: in std_logic;
		pb, pe: in vec_2_p.vec_2_t; -- Point Begin, end.
		pi_offset: in vec_2_p.vec_2_t := vec_2_p.VEC_2_T_ZERO; -- Optional offset applied to the output.
		re: in std_logic;
		pi: out vec_2_p.vec_2_t; -- One of the intermediate points.
		we: out std_logic
	);
end entity;

architecture bresenham of bresenham is
	type state_t is (Q_0, Q_1);
	signal state: state_t;
	signal pe_save, pi_offset_save, pi_2, pi_ext: vec_2_p.vec_2_t;
	signal dh, dv, dh_ext, dv_ext: vec_2_p.vec_2_t;
	signal dbe: vec_2_p.vec_2_t; -- Assumed to be reflected to the first quadrant.
	signal diff: vec_2_p.vec_2_t;
begin
	pi <= vec_2_p."+"(pi_ext, pi_offset_save);
	process (all) is
		variable dh_ext_tmp, dv_ext_tmp: vec_2_p.vec_2_t;
		variable pi_new, pi_ext_new, diff_new, err: vec_2_p.vec_2_t;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state <= Q_0;
				we <= '0'; -- Not walking.
			elsif re = '1' then -- Interruptable
				state <= Q_1;
				pe_save <= pe;
				pi_offset_save <= pi_offset;
				pi_2 <= pb;
				pi_ext <= pb;
				
				dh_ext_tmp := vec_2_p."*"(vec_2_p.H_CAP, DIR_MUL);
				dv_ext_tmp := vec_2_p."*"(vec_2_p.V_CAP, DIR_MUL);
				if vec_2_p.">"(pe.h, pb.h) then
					dh <= vec_2_p.H_CAP;
					dh_ext <= dh_ext_tmp;
				else
					dh <= vec_2_p."-"(vec_2_p.H_CAP);
					dh_ext <= vec_2_p."-"(dh_ext_tmp);
				end if;
				if vec_2_p.">"(pe.v, pb.v) then
					dv <= vec_2_p.V_CAP;
					dv_ext <= dv_ext_tmp;
				else
					dv <= vec_2_p."-"(vec_2_p.V_CAP);
					dv_ext <= vec_2_p."-"(dv_ext_tmp);
				end if;
				
				dbe <= vec_2_p."abs"(vec_2_p."-"(pe, pb));
				diff <= vec_2_p.VEC_2_T_ZERO;
				we <= '1'; -- Start walking.
			elsif state = Q_1 then -- Walking.
				if vec_2_p.to_natural(pi_2) = vec_2_p.to_natural(pe_save) then
					state <= Q_0;
					we <= '0'; -- Stop walking.
				else
					pi_new := pi_2;
					pi_ext_new := pi_ext;
					diff_new := diff;
					err := vec_2_p."+"(diff, dbe);
					if vec_2_p.">="(vec_2_p.shift_left(err.h, 1), dbe.v) then
						pi_new := vec_2_p."+"(pi_new, dh);
						pi_ext_new := vec_2_p."+"(pi_ext_new, dh_ext);
						diff_new.v := vec_2_p."+"(diff_new.v, dbe.v);
						diff_new.h := vec_2_p."-"(diff_new.h, dbe.v);
					end if;
					if vec_2_p.">="(vec_2_p.shift_left(err.v, 1), dbe.h) then
						pi_new := vec_2_p."+"(pi_new, dv);
						pi_ext_new := vec_2_p."+"(pi_ext_new, dv_ext);
						diff_new.h := vec_2_p."+"(diff_new.h, dbe.h);
						diff_new.v := vec_2_p."-"(diff_new.v, dbe.h);
					end if;
					pi_2 <= pi_new;
					pi_ext <= pi_ext_new;
					diff <= diff_new;
				end if;
			end if;
		end if;
	end process;
end architecture;
