library ieee;
use ieee.all;
use std_logic_1164.all;

package qr is
	constant N_MAX: positive := 33;
	type qr_t is array(0 to N_MAX - 1) of std_logic_vector(0 to N_MAX - 1);
end package;
