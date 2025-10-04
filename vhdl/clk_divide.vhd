library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity clk_divider is
    generic (
        Freq_in :     INTEGER := 48000000;
        N       :     INTEGER := 10 -- speed divider, equates to the number of bits (BITS)
    );
    port (
        clk_in  : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end entity clk_divider;

architecture Behave of clk_divider is
    signal temp    : STD_LOGIC;
    signal counter : INTEGER;

begin
    frequency_divider: process (reset, clk_in) is
    begin
        if (reset = '0') then
            temp        <= '0';
            counter     <= 0;
        elsif rising_edge(clk_in) then
            if (counter = N) then
                temp    <= not (temp);
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process frequency_divider;
    clk_out             <= temp;
end architecture Behave;
