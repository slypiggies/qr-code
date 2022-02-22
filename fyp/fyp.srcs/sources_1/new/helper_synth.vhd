library ieee;
use ieee.all;
use std_logic_1164.all;
use work.all;
use helper.all;

package helper_synth is
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
	
	constant ADDR_LENGTH: natural := cnt_bit(H * V);
end package;
