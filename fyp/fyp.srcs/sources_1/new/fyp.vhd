library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;
use helper_synth.all;

entity fyp is
	port (
		CLK100: in std_logic;
		LD: out std_logic_vector(7 downto 0);
		BTNC, BTND, BTNL, BTNR, BTNU: in std_logic;
		SW: in std_logic_vector(7 downto 0);
		
		OV_SIOC: out std_logic;
		OV_SIOD: inout std_logic;
		OV_VSYNC, OV_HREF: in std_logic;
		OV_PCLK: in std_logic;
		OV_XCLK: out std_logic;
		OV_D: in std_logic_vector(7 downto 0);
		OV_RESET: out std_logic;
		OV_PWDN: out std_logic;
		
		VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
		VGA_HS, VGA_VS: out std_logic
	);
end entity;

architecture fyp_a of fyp is
	signal reset: std_logic;
	signal clk25: std_logic;
	signal we, we_2: std_logic;
	signal addr_w, addr_r, addr_w_2, addr_r_2: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel_w, pixel_r, pixel_w_2, pixel_r_2: unsigned(PIXEL_LENGTH - 1 downto 0);
	
	COMPONENT frame_buffer_rgb565
	  PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	  );
	END COMPONENT;
	COMPONENT frame_buffer_y
	  PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	  );
	END COMPONENT;
begin
	check_assertions;
	
	debouncer_i: entity debouncer port map (clk => CLK100, i => BTNC, o => reset);
	
	OV_PWDN <= reset;
	OV_RESET <= not reset;
	
	clk_divider_i: entity clk_divider generic map (
		DIVIDER => 4
	) port map (reset => reset, i => CLK100, o => clk25);
	
	ov_controller_i: entity ov_controller port map (
		reset => reset,
		clk => CLK100,
		clk100 => CLK100,
		scl => OV_SIOC,
		sda => OV_SIOD,
		xclk => OV_XCLK
	);
	
	ov_capturer_i: entity ov_capturer generic map (
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => OV_PCLK,
		h_sync => OV_HREF,
		v_sync => OV_VSYNC,
		d => OV_D,
		we => we,
		addr => addr_w,
		pixel => pixel_w
	);
	
	ENABLE_PROCESSING_if: if ENABLE_PROCESSING generate
		assert_synth(not USE_RGB565);
		
		frame_buffer_y_i: frame_buffer_y port map (
			clka => OV_PCLK,
			wea(0) => we,
			addra => std_logic_vector(addr_w),
			dina => std_logic_vector(pixel_w),
			clkb => CLK100,
			addrb => std_logic_vector(addr_r_2),
			unsigned(doutb) => pixel_r_2
		);
		
		sobel_i: entity sobel generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH
		) port map (
			reset => reset,
			clk => CLK100,
			addr_r => addr_r_2,
			addr_w => addr_w_2,
			pixel_r => pixel_r_2,
			pixel_w => pixel_w_2,
			we => we_2
		);
		
		frame_buffer_y_sobel_i: frame_buffer_y port map (
			clka => CLK100,
			wea(0) => we_2,
			addra => std_logic_vector(addr_w_2),
			dina => std_logic_vector(pixel_w_2),
			clkb => clk25,
			addrb => std_logic_vector(addr_r),
			unsigned(doutb) => pixel_r
		);
	end generate;
	
	not_ENABLE_PROCESSING_if: if not ENABLE_PROCESSING generate
		USE_RGB565_if: if USE_RGB565 generate
			frame_buffer_rgb565_i: frame_buffer_rgb565 port map (
				clka => OV_PCLK,
				wea(0) => we,
				addra => std_logic_vector(addr_w),
				dina => std_logic_vector(pixel_w),
				clkb => clk25,
				addrb => std_logic_vector(addr_r),
				unsigned(doutb) => pixel_r
			);
		end generate;
		not_USE_RGB565_if: if not USE_RGB565 generate
			frame_buffer_y_i: frame_buffer_y port map (
				clka => OV_PCLK,
				wea(0) => we,
				addra => std_logic_vector(addr_w),
				dina => std_logic_vector(pixel_w),
				clkb => clk25,
				addrb => std_logic_vector(addr_r),
				unsigned(doutb) => pixel_r
			);
		end generate;
	end generate;
	
	vga_i: entity vga generic map (
		H => H,
		H_FRONT_PORCH => H_FRONT_PORCH,
		H_SYNC_PULSE => H_SYNC_PULSE,
		H_BACK_PORCH => H_BACK_PORCH,
		H_POLARITY => H_POLARITY,
		V => V,
		V_FRONT_PORCH => V_FRONT_PORCH,
		V_SYNC_PULSE => V_SYNC_PULSE,
		V_BACK_PORCH => V_BACK_PORCH,
		V_POLARITY => V_POLARITY,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk25,
		r => VGA_R,
		g => VGA_G,
		b => VGA_B,
		h_sync => VGA_HS,
		v_sync => VGA_VS,
		addr => addr_r,
		pixel => pixel_r
	);
end architecture;
