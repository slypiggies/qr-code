library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity fb_controller is
	port (
		clk_w, clk_r: in std_logic;
		
		addr_w: in vec_2_p.vec_2_t;
		px_w: in px_t;
		we: in std_logic;
		
		addr_r_i: in vec_2_p.vec_2_t;
		re_i: in std_logic;
		addr_r_o: out vec_2_p.vec_2_t;
		px_r: out px_t;
		re_o: out std_logic
	);
end entity;

architecture fb_controller of fb_controller is
	-- Vivado sucks!
	component frame_buffer_rgb_565 is
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(ADDR_LEN - 1 downto 0);
			dina: in std_logic_vector(PX_LEN - 1 downto 0);
			clkb: in std_logic;
			addrb: in std_logic_vector(ADDR_LEN - 1 downto 0);
			doutb: out std_logic_vector(PX_LEN - 1 downto 0)
		);
	end component;
	component frame_buffer_y is
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(ADDR_LEN - 1 downto 0);
			dina: in std_logic_vector(PX_LEN - 1 downto 0);
			clkb: in std_logic;
			addrb: in std_logic_vector(ADDR_LEN - 1 downto 0);
			doutb: out std_logic_vector(PX_LEN - 1 downto 0)
		);
	end component;
	component frame_buffer_bw is
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(ADDR_LEN - 1 downto 0);
			dina: in std_logic_vector(PX_LEN - 1 downto 0);
			clkb: in std_logic;
			addrb: in std_logic_vector(ADDR_LEN - 1 downto 0);
			doutb: out std_logic_vector(PX_LEN - 1 downto 0)
		);
	end component;
begin
	-- Can't use `delayer` and `vec_2_p.to_natural`, because `natural` can't be converted back to `vec_2_p.vec_2_t`.
	delayer_2_i: entity delayer_2 generic map (DELAY => BRAM_R_DELAY) port map (
		rst => '0', clk => clk_r,
		i => vec_2_p.to_integer(addr_r_i.h), i_2 => vec_2_p.to_integer(addr_r_i.v),
		vec_2_p.to_tp_t(o) => addr_r_o.h, vec_2_p.to_tp_t(o_2) => addr_r_o.v,
		we => open
	);
	delayer_i: entity delayer generic map (DELAY => BRAM_R_DELAY) port map (
		rst => '0', clk => clk_r,
		i => to_integer(re_i), to_std_logic(o) => re_o,
		we => open
	);
	
	USE_RGB_565_if: if USE_RGB_565 generate
		frame_buffer_rgb_565_i: frame_buffer_rgb_565 port map (
			clka => clk_w,
			wea(0) => we,
			addra => vec_2_p.to_std_logic_vector(addr_w),
			dina => to_std_logic_vector(px_w),
			clkb => clk_r,
			addrb => vec_2_p.to_std_logic_vector(addr_r_i),
			to_px_t(doutb) => px_r
		);
	end generate;
	USE_Y_if: if USE_Y generate
		frame_buffer_y_i: frame_buffer_y port map (
			clka => clk_w,
			wea(0) => we,
			addra => vec_2_p.to_std_logic_vector(addr_w),
			dina => to_std_logic_vector(px_w),
			clkb => clk_r,
			addrb => vec_2_p.to_std_logic_vector(addr_r_i),
			to_px_t(doutb) => px_r
		);
	end generate;
	USE_BW_if: if USE_BW generate
		frame_buffer_bw_i: frame_buffer_bw port map (
			clka => clk_w,
			wea(0) => we,
			addra => vec_2_p.to_std_logic_vector(addr_w),
			dina => to_std_logic_vector(px_w),
			clkb => clk_r,
			addrb => vec_2_p.to_std_logic_vector(addr_r_i),
			to_px_t(doutb) => px_r
		);
	end generate;
end architecture;
