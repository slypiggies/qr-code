library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.all;

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
--	constant USE_RGB565: boolean := true;
--	constant PIXEL_LENGTH: natural := 12;
--	constant NO_CONFIG: boolean := false;
	
--	constant USE_RGB565: boolean := false;
--	constant PIXEL_LENGTH: natural := 4;
--	constant NO_CONFIG: boolean := true;
	
	constant USE_RGB565: boolean := false;
	constant PIXEL_LENGTH: natural := 4;
	constant NO_CONFIG: boolean := false;
	
	constant OV_ADDR: std_logic_vector(7 downto 0) := X"42";

	constant H: natural := 640;
	constant H_FRONT_PORCH: natural := 16;
	constant H_SYNC_PULSE: natural := 96;
	constant H_BACK_PORCH: natural := 48;
	constant H_POLARITY: std_logic := '0';
	
	constant V: natural := 480;
	constant V_FRONT_PORCH: natural := 10;
	constant V_SYNC_PULSE: natural := 2;
	constant V_BACK_PORCH: natural := 33;
	constant V_POLARITY: std_logic := '0';
	
	constant ADDR_DEPTH: natural := natural(floor(log2(real(H * V)))) + 1;
	
	signal BTNC_2: std_logic;
	signal clk25, clk1400ns: std_logic;
	signal we: std_logic_vector(0 downto 0);
	signal addr_w, addr_r: std_logic_vector(ADDR_DEPTH - 1 downto 0);
	signal pixel_w, pixel_r: std_logic_vector(PIXEL_LENGTH - 1 downto 0);
	
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
	debouncer_i: entity debouncer port map (CLK100 => CLK100, i => BTNC, o => BTNC_2);
	
	clk_divider_25_i: entity clk_divider generic map (
		divider => 4
	) port map (reset => BTNC_2, i => CLK100, o => clk25);
	
	clk_divider_1400ns_i: entity clk_divider generic map (
		divider => 140
	) port map (reset => BTNC_2, i => CLK100, o => clk1400ns);
	
	ov_controller_i: entity ov_controller generic map (
		OV_ADDR => OV_ADDR,
		USE_RGB565 => USE_RGB565,
		NO_CONFIG => NO_CONFIG
	) port map (
		reset => BTNC_2,
		CLK100 => CLK100,
		clk25 => clk25,
		clk1400ns => clk1400ns,
		OV_SIOC => OV_SIOC,
		OV_SIOD => OV_SIOD,
		OV_PWDN => OV_PWDN,
		OV_RESET => OV_RESET,
		OV_XCLK => OV_XCLK
	);
	
	ov_capturer_i: entity ov_capturer generic map (
		ADDR_DEPTH => ADDR_DEPTH,
		USE_RGB565 => USE_RGB565,
		PIXEL_LENGTH => PIXEL_LENGTH,
		NO_CONFIG => NO_CONFIG
	) port map (
		reset => BTNC_2,
		OV_PCLK => OV_PCLK,
		OV_HREF => OV_HREF,
		OV_VSYNC => OV_VSYNC,
		OV_D => OV_D,
		we => we(0),
		addr => addr_w,
		pixel => pixel_w
	);
	
	USE_RGB565_if: if USE_RGB565 generate
		frame_buffer_rgb565_i: frame_buffer_rgb565 port map (
			clka => OV_PCLK,
			wea => we,
			addra => addr_w,
			dina => pixel_w,
			clkb => clk25,
			addrb => addr_r,
			doutb => pixel_r
		);
	end generate;
	not_USE_RGB565_if: if not USE_RGB565 generate
		frame_buffer_y_i: frame_buffer_y port map (
			clka => OV_PCLK,
			wea => we,
			addra => addr_w,
			dina => pixel_w,
			clkb => clk25,
			addrb => addr_r,
			doutb => pixel_r
		);
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
		ADDR_DEPTH => ADDR_DEPTH,
		USE_RGB565 => USE_RGB565,
		PIXEL_LENGTH => PIXEL_LENGTH
	) port map (
		reset => BTNC_2,
		clk25 => clk25,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,
		VGA_HS => VGA_HS,
		VGA_VS => VGA_VS,
		addr => addr_r,
		pixel => pixel_r
	);
end architecture;