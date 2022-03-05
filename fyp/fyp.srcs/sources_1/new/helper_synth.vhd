library ieee;
use ieee.all;
use std_logic_1164.all;
use work.all;
use helper.all;

package helper_synth is
	constant H: positive := 640;
	constant H_FRONT_PORCH: positive := 16;
	constant H_SYNC_PULSE: positive := 96;
	constant H_BACK_PORCH: positive := 48;
	constant H_POLARITY: std_logic := '0';
	constant V: positive := 480;
	constant V_FRONT_PORCH: positive := 10;
	constant V_SYNC_PULSE: positive := 2;
	constant V_BACK_PORCH: positive := 33;
	constant V_POLARITY: std_logic := '0';
	constant ADDR_LENGTH: positive := cnt_bit(H * V);
end package;
