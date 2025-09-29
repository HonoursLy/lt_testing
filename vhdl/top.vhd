library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		a_i : in std_logic;
		b_i : in std_logic;
		c_i : in std_logic;
		d_o : out std_logic
	);
end top;

architecture rtl of top is
	component and2 
		port (
			a : in std_logic;
			b : in std_logic;
			y : out std_logic
		);
	end component;

	component or2 
		port (
			a : in std_logic;
			b : in std_logic;
			y : out std_logic
		);
	end component;

	signal and2_o : std_logic;
	signal or2_o : std_logic;

begin

	and_inst : and2
	port map (
		a => a_i, 
		b => b_i,
		y => and2_o
	);

	or_inst : or2
	port map (
		a => and2_o,
		b => c_i,
		y => or2_o
	);
	
	d_o <= or2_o;

end architecture;
