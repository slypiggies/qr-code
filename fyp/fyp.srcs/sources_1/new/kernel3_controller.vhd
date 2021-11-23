library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kernel3_controller is
	generic (
		H, V: natural;
		ADDR_LENGTH: natural
	);
	port (
		reset: in std_logic;
		CLK100: in std_logic;
		state: out unsigned(3 downto 0);
		addr_r, addr_w: out unsigned(ADDR_LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture kernel3_controller_a of kernel3_controller is
	signal state_2: unsigned(state'range);
	signal addr_w_2, addr_w_3: unsigned(addr_w'range);
	signal h_cnt, v_cnt: unsigned(ADDR_LENGTH - 1 downto 0);
	type dxy_array_t is array(0 to 8) of unsigned(addr_r'range);
	function dxy_t(x: integer) return unsigned is begin
		return unsigned(to_signed(x, addr_r'length));
	end function;
	constant DX: dxy_array_t := (
		dxy_t(-1),
		dxy_t(-1),
		dxy_t(-1),
		dxy_t(0),
		dxy_t(0),
		dxy_t(0),
		dxy_t(1),
		dxy_t(1),
		dxy_t(1)
	);
	constant DY: dxy_array_t := (
		dxy_t(-1),
		dxy_t(0),
		dxy_t(1),
		dxy_t(-1),
		dxy_t(0),
		dxy_t(1),
		dxy_t(-1),
		dxy_t(0),
		dxy_t(1)
	);
begin
	process (all)
		variable h_cnt_2: unsigned(h_cnt'range);
		variable v_cnt_2: unsigned(v_cnt'range);
		variable addr_r_2: unsigned(addr_r'length * 2 - 1 downto 0);
	begin
		h_cnt_2 := h_cnt + DY(to_integer(state_2));
		v_cnt_2 := v_cnt + DX(to_integer(state_2));
		if h_cnt_2 >= to_unsigned(H, h_cnt_2'length) then
			h_cnt_2 := h_cnt;
		end if;
		if v_cnt_2 >= to_unsigned(V, v_cnt_2'length) then
			v_cnt_2 := v_cnt;
		end if;
		addr_r_2 := v_cnt_2 * to_unsigned(H, v_cnt_2'length) + h_cnt_2;
		addr_r <= addr_r_2(addr_r'range);
	end process;
	state <= state_2;
	addr_w <= addr_w_3;
	
	process (all) begin
		if reset = '1' then
			state_2 <= X"0";
			addr_w_2 <= (others => '0');
			we <= '0';
			h_cnt <= (others => '0');
			v_cnt <= (others => '0');
		elsif rising_edge(CLK100) then
			addr_w_3 <= addr_w_2; -- 1 clock delay for kernel3_convolutor
			if state_2 < X"8" then
				state_2 <= state_2 + 1;
				we <= '0';
			else
				state_2 <= X"0";
				we <= '1';
				if h_cnt < to_unsigned(H - 1, h_cnt'length) then
					h_cnt <= h_cnt + 1;
					addr_w_2 <= addr_w_2 + 1;
				else
					h_cnt <= (others => '0');
					if v_cnt < to_unsigned(V - 1, v_cnt'length) then
						v_cnt <= v_cnt + 1;
						addr_w_2 <= addr_w_2 + 1;
					else
						v_cnt <= (others => '0');
						addr_w_2 <= (others => '0');
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;
