library ieee; use ieee.all;
use math_real.all, std_logic_1164.all, numeric_std.all;

package helper is
	constant USE_CONFIG: boolean := true;
	constant USE_RGB_565: boolean := false;
	constant USE_Y: boolean := false;
	constant USE_BW: boolean := true;
	constant EN_PROCESSING: boolean := true;
	
	constant COLOR_LEN: positive := 1; -- For each channel.
	constant PX_LEN: positive := COLOR_LEN * (boolean'pos(USE_RGB_565) * 2 + 1);
	subtype px_t is natural range 0 to 2 ** PX_LEN - 1;
	type px_t_array_t is array(natural range <>) of px_t;
	constant PX_T_BL: px_t := px_t'low; -- Black.
	constant PX_T_WH: px_t := px_t'high; -- White.
	constant OV_ADDR: std_logic_vector(7 downto 0) := X"42";
	constant BRAM_R_DELAY: positive := 2;
	function cnt_bit(i: positive) return positive;
	procedure assert_synth(i: boolean);
	constant ASSERTS: boolean_vector(0 to 9 - 1) := (
		-- `COLOR_LEN` must match block memory IP configuration.
		not USE_RGB_565 or (USE_RGB_565 and COLOR_LEN = 4),
		not USE_Y or (USE_Y and COLOR_LEN = 4),
		not USE_BW or (USE_BW and COLOR_LEN = 1),
		
		boolean'pos(USE_RGB_565) + boolean'pos(USE_Y) + boolean'pos(USE_BW) = 1,
		not USE_RGB_565 or (
			USE_RGB_565 and
			USE_CONFIG and
			COLOR_LEN <= 4 -- Limited by the DAC of VGA.
		),
		not USE_Y or (USE_Y and COLOR_LEN > 1),
		not USE_BW or (USE_BW and COLOR_LEN = 1),
		not EN_PROCESSING or (EN_PROCESSING and USE_BW),
		PX_LEN <= 31,
		others => true
	);
	procedure check_ASSERTS;
	constant UNIT_MIN: positive := 3; constant UNIT_MAX: positive := 25;
	constant FRAC_LEN: positive := 9;
	function to_integer(i: std_logic) return integer;
	function to_std_logic(i: integer) return std_logic;
	function to_std_logic_vector(i: px_t) return std_logic_vector;
	function to_px_t(i: std_logic_vector(PX_LEN - 1 downto 0)) return px_t;
	function mul_2(i: natural) return natural;
	function mul_3(i: natural) return natural;
	function mod_2(i: natural) return natural;
	
	constant H: positive := 640; constant V: positive := 480;
	constant H_FRONT_PORCH: positive := 16; constant V_FRONT_PORCH: positive := 10;
	constant H_SYNC_PULSE: positive := 96; constant V_SYNC_PULSE: positive := 2;
	constant H_BACK_PORCH: positive := 48; constant V_BACK_PORCH: positive := 33;
	constant H_POLARITY: std_logic := '0'; constant V_POLARITY: std_logic := '0';
	constant ADDR_LEN: positive := cnt_bit(H * V - 1);
	
	constant CONFIG_LEN: positive := 16;
	constant CONFIG_RGB_565: std_logic_vector(0 to CONFIG_LEN * 168 - 1) :=
		X"1100"
		& X"3A04"
		& X"1200"
		& X"1713"
		& X"1801"
		& X"32B6"
		& X"1902"
		& X"1A7A"
		& X"030A"
		& X"0C00"
		& X"3E00"
		& X"703A"
		& X"7135"
		& X"7211"
		& X"73F0"
		& X"A202"
		& X"1500"
		& X"7A20"
		& X"7B10"
		& X"7C1E"
		& X"7D35"
		& X"7E5A"
		& X"7F69"
		& X"8076"
		& X"8180"
		& X"8288"
		& X"838F"
		& X"8496"
		& X"85A3"
		& X"86AF"
		& X"87C4"
		& X"88D7"
		& X"89E8"
		& X"13E0"
		& X"0000"
		& X"1000"
		& X"0D40"
		& X"1418"
		& X"A505"
		& X"AB07"
		& X"2495"
		& X"2533"
		& X"26E3"
		& X"9F78"
		& X"A068"
		& X"A103"
		& X"A6D8"
		& X"A7D8"
		& X"A8F0"
		& X"A990"
		& X"AA94"
		& X"13E5"
		& X"0E61"
		& X"0F4B"
		& X"1602"
		& X"1E07"
		& X"2102"
		& X"2291"
		& X"2907"
		& X"330B"
		& X"350B"
		& X"371D"
		& X"3871"
		& X"392A"
		& X"3C78"
		& X"4D40"
		& X"4E20"
		& X"6900"
		& X"6B4A"
		& X"7410"
		& X"8D4F"
		& X"8E00"
		& X"8F00"
		& X"9000"
		& X"9100"
		& X"9600"
		& X"9A00"
		& X"B084"
		& X"B10C"
		& X"B20E"
		& X"B382"
		& X"B80A"
		& X"430A"
		& X"44F0"
		& X"4534"
		& X"4658"
		& X"4728"
		& X"483A"
		& X"5988"
		& X"5A88"
		& X"5B44"
		& X"5C67"
		& X"5D49"
		& X"5E0E"
		& X"6C0A"
		& X"6D55"
		& X"6E11"
		& X"6F9F"
		& X"6A40"
		& X"0140"
		& X"0260"
		& X"13E7"
		& X"4F80"
		& X"5080"
		& X"5100"
		& X"5222"
		& X"535E"
		& X"5480"
		& X"589E"
		& X"4108"
		& X"3F00"
		& X"7505"
		& X"76E1"
		& X"4C00"
		& X"7701"
		& X"3DC3"
		& X"4B09"
		& X"C960"
		& X"4138"
		& X"5640"
		& X"3411"
		& X"3B12"
		& X"A488"
		& X"9600"
		& X"9730"
		& X"9820"
		& X"9930"
		& X"9A84"
		& X"9B29"
		& X"9C03"
		& X"9D4C"
		& X"9E3F"
		& X"7804"
		& X"7901"
		& X"C8F0"
		& X"790F"
		& X"C800"
		& X"7910"
		& X"C87E"
		& X"790A"
		& X"C880"
		& X"790B"
		& X"C801"
		& X"790C"
		& X"C80F"
		& X"790D"
		& X"C820"
		& X"7909"
		& X"C880"
		& X"7902"
		& X"C8C0"
		& X"7903"
		& X"C840"
		& X"7905"
		& X"C830"
		& X"7926"
		& X"1204"
		& X"8C00"
		& X"0400"
		& X"4010"
		& X"1438"
		& X"4FB3"
		& X"50B3"
		& X"5100"
		& X"523D"
		& X"53A7"
		& X"54E4"
		& X"3DC0"
	;
	constant CONFIG_Y: std_logic_vector(0 to CONFIG_LEN * 168 - 1) :=
		X"1100"
		& X"3A04"
		& X"1200"
		& X"1713"
		& X"1801"
		& X"32B6"
		& X"1902"
		& X"1A7A"
		& X"030A"
		& X"0C00"
		& X"3E00"
		& X"703A"
		& X"7135"
		& X"7211"
		& X"73F0"
		& X"A202"
		& X"1500"
		& X"7A20"
		& X"7B10"
		& X"7C1E"
		& X"7D35"
		& X"7E5A"
		& X"7F69"
		& X"8076"
		& X"8180"
		& X"8288"
		& X"838F"
		& X"8496"
		& X"85A3"
		& X"86AF"
		& X"87C4"
		& X"88D7"
		& X"89E8"
		& X"13E0"
		& X"0000"
		& X"1000"
		& X"0D40"
		& X"1418"
		& X"A505"
		& X"AB07"
		& X"2495"
		& X"2533"
		& X"26E3"
		& X"9F78"
		& X"A068"
		& X"A103"
		& X"A6D8"
		& X"A7D8"
		& X"A8F0"
		& X"A990"
		& X"AA94"
		& X"13E5"
		& X"0E61"
		& X"0F4B"
		& X"1602"
		& X"1E07"
		& X"2102"
		& X"2291"
		& X"2907"
		& X"330B"
		& X"350B"
		& X"371D"
		& X"3871"
		& X"392A"
		& X"3C78"
		& X"4D40"
		& X"4E20"
		& X"6900"
		& X"6B4A"
		& X"7410"
		& X"8D4F"
		& X"8E00"
		& X"8F00"
		& X"9000"
		& X"9100"
		& X"9600"
		& X"9A00"
		& X"B084"
		& X"B10C"
		& X"B20E"
		& X"B382"
		& X"B80A"
		& X"430A"
		& X"44F0"
		& X"4534"
		& X"4658"
		& X"4728"
		& X"483A"
		& X"5988"
		& X"5A88"
		& X"5B44"
		& X"5C67"
		& X"5D49"
		& X"5E0E"
		& X"6C0A"
		& X"6D55"
		& X"6E11"
		& X"6F9F"
		& X"6A40"
		& X"0140"
		& X"0260"
		& X"13E7"
		& X"4F80"
		& X"5080"
		& X"5100"
		& X"5222"
		& X"535E"
		& X"5480"
		& X"589E"
		& X"4108"
		& X"3F00"
		& X"7505"
		& X"76E1"
		& X"4C00"
		& X"7701"
		& X"3DC3"
		& X"4B09"
		& X"C960"
		& X"4138"
		& X"5640"
		& X"3411"
		& X"3B12"
		& X"A488"
		& X"9600"
		& X"9730"
		& X"9820"
		& X"9930"
		& X"9A84"
		& X"9B29"
		& X"9C03"
		& X"9D4C"
		& X"9E3F"
		& X"7804"
		& X"7901"
		& X"C8F0"
		& X"790F"
		& X"C800"
		& X"7910"
		& X"C87E"
		& X"790A"
		& X"C880"
		& X"790B"
		& X"C801"
		& X"790C"
		& X"C80F"
		& X"790D"
		& X"C820"
		& X"7909"
		& X"C880"
		& X"7902"
		& X"C8C0"
		& X"7903"
		& X"C840"
		& X"7905"
		& X"C830"
		& X"7926"
		& X"1200"
		& X"8C00"
		& X"0400"
		& X"40C0"
		& X"1448"
		& X"4F80"
		& X"5080"
		& X"5100"
		& X"5222"
		& X"535E"
		& X"5480"
		& X"3DC0"
	;
end package;

package body helper is
	function cnt_bit(i: positive) return positive is begin
		return positive(floor(log2(real(i)))) + 1;
	end function;
	
	procedure assert_synth_2(i: positive) is begin end procedure;
	procedure assert_synth(i: boolean) is begin
		assert_synth_2(boolean'pos(i));
	end procedure;
	procedure check_ASSERTS is begin
		for i in ASSERTS'range loop
			assert ASSERTS(i) report natural'image(i) severity failure; -- To have a more readable error in simulation.
			assert_synth(ASSERTS(i));
		end loop;
	end procedure;
	
	function to_integer(i: std_logic) return integer is begin
		if i = '1' then return 1; else return 0; end if;
	end function;
	
	function to_std_logic(i: integer) return std_logic is begin
		if i = 0 then return '0'; else return '1'; end if;
	end function;
	
	function to_std_logic_vector(i: px_t) return std_logic_vector is begin
		return std_logic_vector(to_unsigned(i, PX_LEN));
	end function;
	
	function to_px_t(i: std_logic_vector(PX_LEN - 1 downto 0)) return px_t is begin
		return to_integer(unsigned(i));
	end function;
	
	function mul_2(i: natural) return natural is begin
		return to_integer(shift_left(to_unsigned(i, cnt_bit(natural'high)), 1));
	end function;
	
	function mul_3(i: natural) return natural is begin
		return mul_2(i) + i;
	end function;
	
	function mod_2(i: natural) return natural is
		variable i_2: unsigned(cnt_bit(natural'high) - 1 downto 0);
	begin
		i_2 := to_unsigned(i, i_2'length);
		return to_integer(i_2(0));
	end function;
end package body;
