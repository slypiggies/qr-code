library ieee, vivado_sucks; use ieee.all, work.all;
use helper.all, numeric_std.all, std_logic_1164.all;

package vec_2_p is
	subtype tp_t is vivado_sucks.fixed_pkg.sfixed(cnt_bit(2 * H * H + 2 * V * V) + 1 - 1 downto -FRAC_LEN);
	function to_tp_t(i: real) return tp_t;
	function to_tp_t(i: integer) return tp_t;
	function to_integer(i: tp_t) return integer;
	function "<"(l, r: tp_t) return boolean;
	function ">"(l, r: tp_t) return boolean;
	function "="(l, r: tp_t) return boolean;
	function "<="(l, r: tp_t) return boolean;
	function ">="(l, r: tp_t) return boolean;
	function minimum(l, r: tp_t) return tp_t;
	function maximum(l, r: tp_t) return tp_t;
	function "+"(l, r: tp_t) return tp_t;
	function "-"(i: tp_t) return tp_t;
	function "-"(l, r: tp_t) return tp_t;
	function "*"(l, r: tp_t) return tp_t;
	function "not"(i: tp_t) return tp_t;
	function "abs"(i: tp_t) return tp_t;
	function shift_left(i: tp_t; j: natural) return tp_t;
	function shift_right(i: tp_t; j: natural) return tp_t;
	constant TP_T_LOW: tp_t := vivado_sucks.fixed_pkg."&"("1", (tp_t'left - 1 downto tp_t'right => '0'));
	constant TP_T_HIGH: tp_t := not TP_T_LOW;
	constant TP_T_ZERO: tp_t := to_tp_t(0);
	
	type vec_2_t is record
		h, v: tp_t;
	end record;
	type vec_2_t_array_t is array(natural range <>) of vec_2_t;
	function to_vec_2_t(h, v: tp_t) return vec_2_t;
	function to_vec_2_t(h, v: integer) return vec_2_t;
	function to_natural(i: vec_2_t) return natural;
	function to_std_logic_vector(i: vec_2_t) return std_logic_vector;
	function "<"(l, r: vec_2_t) return boolean;
	function ">"(l, r: vec_2_t) return boolean;
	function "="(l, r: vec_2_t) return boolean;
	function "<="(l, r: vec_2_t) return boolean;
	function ">="(l, r: vec_2_t) return boolean;
	function minimum(l, r: vec_2_t) return vec_2_t;
	function maximum(l, r: vec_2_t) return vec_2_t;
	function "+"(l, r: vec_2_t) return vec_2_t;
	function "-"(i: vec_2_t) return vec_2_t;
	function "-"(l, r: vec_2_t) return vec_2_t;
	function "*"(l: vec_2_t; r: tp_t) return vec_2_t;
	function "*"(l: tp_t; r: vec_2_t) return vec_2_t;
	function "*"(l: vec_2_t; r: real) return vec_2_t;
	function "*"(l: real; r: vec_2_t) return vec_2_t;
	function "*"(l: vec_2_t; r: integer) return vec_2_t;
	function "*"(l: integer; r: vec_2_t) return vec_2_t;
	function "abs"(i: vec_2_t) return vec_2_t;
	function shift_left(i: vec_2_t; j: natural) return vec_2_t;
	function shift_right(i: vec_2_t; j: natural) return vec_2_t;
	function swap(i: vec_2_t) return vec_2_t;
	function norm_sqr(i: vec_2_t) return tp_t;
	function rot_90(i: vec_2_t) return vec_2_t;
--	function can_inc(i, j, lim: vec_2_t) return boolean;
	function inc_h(i, lim: vec_2_t) return vec_2_t;
	function inc_v(i, lim: vec_2_t) return vec_2_t;
	constant VEC_2_T_LOW: vec_2_t := to_vec_2_t(TP_T_LOW, TP_T_LOW);
	constant VEC_2_T_HIGH: vec_2_t := to_vec_2_t(TP_T_HIGH, TP_T_HIGH);
	constant VEC_2_T_ZERO: vec_2_t := to_vec_2_t(0, 0);
	constant H_CAP: vec_2_t := to_vec_2_t(1, 0);
	constant V_CAP: vec_2_t := to_vec_2_t(0, 1);
	
	type ep_t is record -- Extreme points.
		min_h, max_h, min_v, max_v: vec_2_t;
	end record;
	function to_ep_t(i: vec_2_t) return ep_t;
	function to_ep_t(min_h, max_h, min_v, max_v: vec_2_t) return ep_t;
	function arb(i, j: ep_t) return ep_t;
	function arb(i: ep_t; j: vec_2_t) return ep_t;
	function arb(i, j: vec_2_t) return ep_t;
	constant EP_T_INIT: ep_t := to_ep_t(VEC_2_T_HIGH, VEC_2_T_LOW, VEC_2_T_HIGH, VEC_2_T_LOW);
end package;

package body vec_2_p is
	function to_tp_t(i: real) return tp_t is begin
		return vivado_sucks.fixed_pkg.to_sfixed(i, tp_t'left, tp_t'right);
	end function;
	function to_tp_t(i: integer) return tp_t is begin
		return to_tp_t(real(i));
	end function;
	function to_integer(i: tp_t) return integer is begin
		return vivado_sucks.fixed_pkg.to_integer(i);
	end function;
	
	function "<"(l, r: tp_t) return boolean is begin
		return vivado_sucks.fixed_pkg."<"(l, r);
	end function;
	function ">"(l, r: tp_t) return boolean is begin
		return vivado_sucks.fixed_pkg.">"(l, r);
	end function;
	function "="(l, r: tp_t) return boolean is begin
		return vivado_sucks.fixed_pkg."="(l, r);
	end function;
	function "<="(l, r: tp_t) return boolean is begin
		return vivado_sucks.fixed_pkg."<="(l, r);
	end function;
	function ">="(l, r: tp_t) return boolean is begin
		return vivado_sucks.fixed_pkg.">="(l, r);
	end function;
	function minimum(l, r: tp_t) return tp_t is begin
		return vivado_sucks.fixed_pkg.minimum(l, r);
	end function;
	function maximum(l, r: tp_t) return tp_t is begin
		return vivado_sucks.fixed_pkg.maximum(l, r);
	end function;
	function "+"(l, r: tp_t) return tp_t is
		subtype res_t is vivado_sucks.fixed_pkg.sfixed(tp_t'left + 1 downto tp_t'right);
		variable res: res_t;
	begin
		res := vivado_sucks.fixed_pkg."+"(l, r); return res(tp_t'range); 
	end function;
	function "-"(i: tp_t) return tp_t is
		subtype res_t is vivado_sucks.fixed_pkg.sfixed(tp_t'left + 1 downto tp_t'right);
		variable res: res_t;
	begin
		res := vivado_sucks.fixed_pkg."-"(i); return res(tp_t'range);
	end function;
	function "-"(l, r: tp_t) return tp_t is begin
		return l + (-r);
	end function;
	function "*"(l, r: tp_t) return tp_t is
		subtype res_t is vivado_sucks.fixed_pkg.sfixed(2 * tp_t'left + 1 downto 2 * tp_t'right);
		variable res: res_t;
	begin
		res := vivado_sucks.fixed_pkg."*"(l, r); return res(tp_t'range);
	end function;
	function "not"(i: tp_t) return tp_t is begin
		return vivado_sucks.fixed_pkg."not"(i);
	end function;
	function "abs"(i: tp_t) return tp_t is
		subtype res_t is vivado_sucks.fixed_pkg.sfixed(tp_t'left + 1 downto tp_t'right);
		variable res: res_t;
	begin
		res := vivado_sucks.fixed_pkg."abs"(i); return res(tp_t'range);
	end function;
	function shift_left(i: tp_t; j: natural) return tp_t is begin
		return vivado_sucks.fixed_pkg.shift_left(i, j);
	end function;
	function shift_right(i: tp_t; j: natural) return tp_t is begin
		return vivado_sucks.fixed_pkg.shift_right(i, j);
	end function;
	
	function to_vec_2_t(h, v: tp_t) return vec_2_t is begin
		return (h => h, v => v);
	end function;
	function to_vec_2_t(h, v: integer) return vec_2_t is begin
		return to_vec_2_t(to_tp_t(h), to_tp_t(v));
	end function;
	function to_natural(i: vec_2_t) return natural is begin
		return to_integer(i.v) * H + to_integer(i.h);
	end function;
	function to_std_logic_vector(i: vec_2_t) return std_logic_vector is begin
		return std_logic_vector(to_unsigned(to_natural(i), ADDR_LEN));
	end function;
	
	function "<"(l, r: vec_2_t) return boolean is begin
		return l.h < r.h or (l.h = r.h and l.v < r.v);
	end function;
	function ">"(l, r: vec_2_t) return boolean is begin
		return l.h > r.h or (l.h = r.h and l.v > r.v);
	end function;
	function "="(l, r: vec_2_t) return boolean is begin
		return not (l < r) and not (l > r);
	end function;
	function "<="(l, r: vec_2_t) return boolean is begin
		return not (l > r);
	end function;
	function ">="(l, r: vec_2_t) return boolean is begin
		return not (l < r);
	end function;
	
	function minimum(l, r: vec_2_t) return vec_2_t is begin
		if l < r then return l; else return r; end if;
	end function;
	function maximum(l, r: vec_2_t) return vec_2_t is begin
		if l > r then return l; else return r; end if;
	end function;
	
	function "+"(l, r: vec_2_t) return vec_2_t is begin
		return to_vec_2_t(l.h + r.h, l.v + r.v);
	end function;
	function "-"(i: vec_2_t) return vec_2_t is begin
		return to_vec_2_t(-i.h, -i.v);
	end function;
	function "-"(l, r: vec_2_t) return vec_2_t is begin
		return l + (-r);
	end function;
	function "*"(l: vec_2_t; r: tp_t) return vec_2_t is begin
		return to_vec_2_t(l.h * r, l.v * r);
	end function;
	function "*"(l: tp_t; r: vec_2_t) return vec_2_t is begin
		return r * l;
	end function;
	function "*"(l: vec_2_t; r: real) return vec_2_t is begin
		return l * to_tp_t(r);
	end function;
	function "*"(l: real; r: vec_2_t) return vec_2_t is begin
		return r * l;
	end function;
	function "*"(l: vec_2_t; r: integer) return vec_2_t is begin
		return l * to_tp_t(r);
	end function;
	function "*"(l: integer; r: vec_2_t) return vec_2_t is begin
		return r * l;
	end function;
	function "abs"(i: vec_2_t) return vec_2_t is begin
		return to_vec_2_t(abs i.h, abs i.v);
	end function;
	function shift_left(i: vec_2_t; j: natural) return vec_2_t is begin
		return to_vec_2_t(shift_left(i.h, j), shift_left(i.v, j));
	end function;
	function shift_right(i: vec_2_t; j: natural) return vec_2_t is begin
		return to_vec_2_t(shift_right(i.h, j), shift_right(i.v, j));
	end function;
	
	function swap(i: vec_2_t) return vec_2_t is begin
		return to_vec_2_t(i.v, i.h);
	end function;
	
	function norm_sqr(i: vec_2_t) return tp_t is begin
		return i.h * i.h + i.v * i.v;
	end function;
	
	function rot_90(i: vec_2_t) return vec_2_t is begin
		return to_vec_2_t(-i.v, i.h);
	end function;
	
--	function can_inc(i, j, lim: vec_2_t) return boolean is
--		variable lt_h, lt_v: boolean;
--		variable k: vec_2_t;
--		variable lt_h_2, lt_v_2: boolean;
--	begin
--		lt_h := vivado_sucks.fixed_pkg."<"(i.h, j.h);
--		lt_v := vivado_sucks.fixed_pkg."<"(i.v, j.v);
--		k := i + j;
--		lt_h_2 := vivado_sucks.fixed_pkg."<"(k.h, j.h);
--		lt_v_2 := vivado_sucks.fixed_pkg."<"(k.v, j.v);
--		return lt_h = lt_h_2 and lt_v = lt_v_2;
--	end function;
	
	function inc_h(i, lim: vec_2_t) return vec_2_t is
		variable res: vec_2_t;
	begin
		res := i + H_CAP;
		if res.h >= lim.h then
			res.h := to_tp_t(0);
			res := res + V_CAP;
			if res.v >= lim.v then
				res.v := to_tp_t(0);
			end if;
		end if;
		return res;
	end function;
	function inc_v(i, lim: vec_2_t) return vec_2_t is begin
		return swap(inc_h(swap(i), swap(lim)));
	end function;
	
	function to_ep_t(i: vec_2_t) return ep_t is begin
		return (min_h => i, max_h => i, min_v => i, max_v => i);
	end function;
	function to_ep_t(min_h, max_h, min_v, max_v: vec_2_t) return ep_t is begin
		return (min_h => min_h, max_h => max_h, min_v => min_v, max_v => max_v);
	end function;
	
	function arb(i, j: ep_t) return ep_t is begin
		return to_ep_t(
			minimum(i.min_h, j.min_h), maximum(i.max_h, j.max_h),
			swap(minimum(swap(i.min_v), swap(j.min_v))), swap(maximum(swap(i.max_v), swap(j.max_v)))
		);
	end function;
	function arb(i: ep_t; j: vec_2_t) return ep_t is begin
		return arb(i, to_ep_t(j));
	end function;
	function arb(i, j: vec_2_t) return ep_t is begin
		return arb(to_ep_t(i), j);
	end function;
end package body;
