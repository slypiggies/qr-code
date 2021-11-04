library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity main is
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

architecture main_a of main is
	constant H: natural := 640;
	constant H_FRONT_PORCH: natural := 16;
	constant H_SYNC_PULSE: natural := 96;
	constant H_BACK_PORCH: natural := 48;
	constant H_POLARITY: std_logic := '0';
	
	constant V: natural := 480;
	constant V_FRONT_PORCH: natural := 11;
	constant V_SYNC_PULSE: natural := 2;
	constant V_BACK_PORCH: natural := 31;
	constant V_POLARITY: std_logic := '1';
	
	constant ADDR_DEPTH: natural := natural(ceil(log2(real(H * V))));
	
	signal BTNC2: std_logic;
	signal clk50, clk25: std_logic;
	signal we: std_logic_vector(0 downto 0);
	signal addr_w, addr_r: std_logic_vector(ADDR_DEPTH - 1 downto 0);
	signal pixel_w, pixel_r: std_logic_vector(11 downto 0);
	
	component debouncer is
		port (
			CLK100: in std_logic;
			i: in std_logic;
			o: out std_logic
		);
	end component;
	component clk_wizard is
		port (
			reset: in std_logic;
			CLK100: in std_logic;
			clk50, clk25: out std_logic
		);
	end component;
	component ov_controller is
		port (
			reset: in std_logic;
			clk25, clk50: in std_logic;
			OV_SIOC: out std_logic;
			OV_SIOD: inout std_logic;
			OV_PWDN: out std_logic;
			OV_RESET: out std_logic;
			OV_XCLK: out std_logic
		);
	end component;
	component ov_capturer_rgb565 is
		generic (
			ADDR_DEPTH: natural
		);
		port (
			reset: in std_logic;
			OV_PCLK, OV_HREF, OV_VSYNC: in std_logic;
			OV_D: in std_logic_vector(7 downto 0);
			we: out std_logic;
			addr: out std_logic_vector(ADDR_DEPTH - 1 downto 0);
			pixel: out std_logic_vector(11 downto 0)
		);
	end component;
	component frame_buffer is
		port (
			addra, addrb: in std_logic_vector(ADDR_DEPTH - 1 downto 0);
			clka, clkb: in std_logic;
			dina: in std_logic_vector(11 downto 0);
			wea: in std_logic_vector(0 downto 0);
			doutb: out std_logic_vector(11 downto 0)
		);
	end component;
	component vga is
		generic (
			H: natural;
			H_FRONT_PORCH: natural;
			H_SYNC_PULSE: natural;
			H_BACK_PORCH: natural;
			H_POLARITY: std_logic;
			
			V: natural;
			V_FRONT_PORCH: natural;
			V_SYNC_PULSE: natural;
			V_BACK_PORCH: natural;
			V_POLARITY: std_logic;
			
			ADDR_DEPTH: natural
		);
		port (
			reset: in std_logic;
			clk25: in std_logic;
			VGA_R, VGA_G, VGA_B: out std_logic_vector(3 downto 0);
			VGA_HS, VGA_VS: out std_logic;
			addr: out std_logic_vector(ADDR_DEPTH - 1 downto 0);
			pixel: in std_logic_vector(11 downto 0)
		);
	end component;
begin
	debouncer_i: debouncer port map (CLK100 => CLK100, i => BTNC, o => BTNC2);
	
	clk_wizard_i: clk_wizard port map (
		reset => BTNC2,
		CLK100 => CLK100,
		clk50 => clk50,
		clk25 => clk25
	);
	
	ov_controller_i: ov_controller port map (
		reset => BTNC2,
		clk25 => clk25,
		clk50 => clk50,
		OV_SIOC => OV_SIOC,
		OV_SIOD => OV_SIOD,
		OV_PWDN => OV_PWDN,
		OV_RESET => OV_RESET,
		OV_XCLK => OV_XCLK
	);
	
	ov_capturer_rgb565_i: ov_capturer_rgb565 generic map (
		ADDR_DEPTH => ADDR_DEPTH
	) port map (
		reset => BTNC2,
		OV_PCLK => OV_PCLK,
		OV_HREF => OV_HREF,
		OV_VSYNC => OV_VSYNC,
		OV_D => OV_D,
		we => we(0),
		addr => addr_w,
		pixel => pixel_w
	);
	
	frame_buffer_i: frame_buffer port map (
		addra => addr_w,
		clka => OV_PCLK,
		dina => pixel_w,
		wea => we,
		addrb => addr_r,
		clkb => clk25,
		doutb => pixel_r
	);
	
	vga_i: vga generic map (
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
		ADDR_DEPTH => ADDR_DEPTH
	) port map (
		reset => BTNC2,
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
