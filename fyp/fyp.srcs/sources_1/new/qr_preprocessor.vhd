library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity qr_preprocessor is
	generic (UNIT_VEC: vec_2_p.vec_2_t);
	port (
		rst, clk: in std_logic;
		addr: in vec_2_p.vec_2_t;
		px: in px_t;
		re: in std_logic;
		ed: in std_logic; -- End of frame. Assumption: if this and `re` are both `'1'`s, `re` will be ignored.
		ep: out vec_2_p.ep_t; -- Extreme points.
		we: out std_logic
	);
end entity;

architecture qr_preprocessor of qr_preprocessor is
	signal pb, p13, p31: vec_2_p.vec_2_t;
	signal cnt: positive;
	signal we_qr_aggregator, we_qr_11311_finder: std_logic;
	signal ed_qr_aggregator, ed_qr_11311_finder: std_logic;
begin
	qr_aggregator_i: entity qr_aggregator port map (
		rst => rst, clk => clk,
		addr => addr,
		px => px,
		re => re,
		ed_i => ed,
		pb => pb,
		cnt => cnt,
		we => we_qr_aggregator,
		ed_o => ed_qr_aggregator
	);
	
	qr_11311_finder_i: entity qr_11311_finder generic map (UNIT_VEC => UNIT_VEC) port map (
		rst => rst, clk => clk,
		pb => pb,
		cnt => cnt,
		re => we_qr_aggregator,
		ed_i => ed_qr_aggregator,
		p13 => p13, p31 => p31,
		we => we_qr_11311_finder,
		ed_o => ed_qr_11311_finder
	);
	
	qr_extreme_points_finder_i: entity qr_extreme_points_finder port map (
		rst => rst, clk => clk,
		p13 => p13, p31 => p31,
		re => we_qr_11311_finder,
		ed => ed_qr_11311_finder,
		ep => ep,
		we => we
	);
end architecture;
