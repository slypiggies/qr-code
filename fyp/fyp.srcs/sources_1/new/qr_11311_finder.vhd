library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_11311_finder is
	generic (UNIT_VEC: vec_2_p.vec_2_t);
	port (
		rst, clk: in std_logic;
		pb: in vec_2_p.vec_2_t; -- Point Begin.
		cnt: in positive;
		re: in std_logic;
		ed_i: in std_logic; -- End of frame. Assumption: if this and `re` are both `'1'`s, `re` will be ignored.
		p13, p31: out vec_2_p.vec_2_t; -- Point 13 and 31.
		we: out std_logic;
		ed_o: out std_logic
	);
end entity;

architecture qr_11311_finder of qr_11311_finder is
	signal shift_reg_pb: vec_2_p.vec_2_t_array_t(0 to 4 - 1);
	signal shift_reg_cnt: integer_vector(0 to 4 - 1);
	signal shift_reg_re: std_logic_vector(0 to 4 - 1);
	subtype cnt_t is positive range 1 to H * V; -- So that `minimum` and `maximum` are more efficient, hopefully.
	type cnt_t_array_t is array(natural range <>) of cnt_t;
	signal cnts: cnt_t_array_t(0 to 5 - 1);
	signal min, max: cnt_t;
	signal res: std_logic_vector(0 to 5 - 1); -- Read enables.
begin
	cnts <= (
		mul_3(shift_reg_cnt(0)),
		mul_3(shift_reg_cnt(1)),
		shift_reg_cnt(2),
		mul_3(shift_reg_cnt(3)),
		mul_3(cnt)
	);
	min <= minimum(minimum(minimum(cnts(0), cnts(1)), minimum(cnts(2), cnts(3))), cnts(4));
	max <= maximum(maximum(maximum(cnts(0), cnts(1)), maximum(cnts(2), cnts(3))), cnts(4));
	res <= shift_reg_re & re;
	
	process (all) is
		variable flag: boolean;
	begin
		if rising_edge(clk) then
			we <= '0'; -- Default value.
			ed_o <= ed_i;
			if rst = '1' or ed_i = '1' then
				shift_reg_re <= (others => '0');
			elsif re = '1' then
				flag := mul_2(max - min) < min; -- (max - min) / min < 0.5
				for i in 0 to 5 - 1 loop
					flag := flag and cnts(i) >= UNIT_MIN * 3 and cnts(i) <= UNIT_MAX * 3 and res(i) = '1';
				end loop;
				if flag then
					p13 <= shift_reg_pb(2);
					p31 <= vec_2_p."-"(shift_reg_pb(3), UNIT_VEC);
					we <= '1';
				end if;
--				shift_reg_pb <= vec_2_p."&"(shift_reg_pb(shift_reg_pb'left + 1 to shift_reg_pb'right), pb); -- Vivado sucks!
				shift_reg_pb(shift_reg_pb'left to shift_reg_pb'right - 1) <= shift_reg_pb(shift_reg_pb'left + 1 to shift_reg_pb'right);
				shift_reg_pb(shift_reg_pb'right) <= pb;
				shift_reg_cnt <= shift_reg_cnt(shift_reg_cnt'left + 1 to shift_reg_cnt'right) & cnt;
				shift_reg_re <= shift_reg_re(shift_reg_re'left + 1 to shift_reg_re'right) & '1';
			end if;
		end if;
	end process;
end architecture;
