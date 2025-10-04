library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LT_controller is
    port (
        fsm_clk      : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        -- Indicators from other blocks to trigger states
        tx_ready     : in  STD_LOGIC; -- indication from EC to start reading TX_RAM and transmit
        -- rx_received : IN STD_LOGIC; -- indication from the RX line that a light message is incoming
        -- host_align : IN STD_LOGIC;
        -- device_align : IN STD_LOGIC;
        -- Add error signals that suggest to go to idle state?
        -- rx_error : OUT STD_LOGIC;
        -- tx_error : OUT STD_LOGIC;
        -- host : IN STD_LOGIC;
        ena_t        : out std_logic;
        message_sent : in  std_logic
        -- rx_done : in std_logic;
        -- aligned : in std_logic
    );
end entity LT_controller;

architecture rtl of LT_controller is

    type fsm_states is (RT, ID, TX); --, RX, RE, TE, HF, HA, DA); -- reset, idle, transmitting, receiving, receive error, transmit error, hard fault, host align, device align
    signal ps, ns  : fsm_states := ID;
    signal ena_t_s : STD_LOGIC  := '0';
    -- SIGNAL RE_count : INTEGER := 0;
    -- SIGNAL TE_count : INTEGER := 0;
    -- count number of error signals


begin
    ena_t                   <= ena_t_s;

    sync_proc: process (fsm_clk, rst) is
    begin
        if rst = '0' then
            ps              <= RT;
            -- RE_count <= 0;
            -- TE_count <= 0;
        elsif rising_edge(fsm_clk) then
            ps              <= ns;
        end if;
    end process sync_proc;

    comb_proc: process (ps, tx_ready, message_sent) is
    begin
        ena_t_s             <= '0';
        case ps is

            when RT =>
                -- Reset all light variables
                -- Go to idle state
                ns          <= ID;

            when ID =>
                -- idle timer if in run state? usb should be running frequently enough that the system should not be in idle long? => tx_error/ hard fault
                if (tx_ready = '1') then
                    ns      <= TX;
                    ena_t_s <= '1';
                    -- transition variable changes
                    -- elsif (rx_received = '1') then
                    -- 	ns <= RX;
                    -- 	-- transition variable changes
                else
                    ns      <= ID;
                end if;
            when TX =>
                if (message_sent = '1') then
                    ns      <= ID;
                    ena_t_s <= '0';
                else
                    ns      <= TX;
                    ena_t_s <= '1';
                end if;


                -- WHEN RX =>
                -- 	if (rx_error = '1') then
                -- 		ns <= RE;
                -- 		RE_count <= RE_count + 1;
                -- 		-- turn off rx_error somehow
                -- 	elsif (tx_error = '1') then
                -- 		ns <= TE;
                -- 		TE_count <= TE_count + 1;
                --     ELSIF (rx_done = '1') THEN
                --         ns <= ID;
                -- 		RE_count <= 0;
                -- 		TE_count <= 0;
                -- 		-- transition variable changes

                --     ELSE
                --         ns <= RX;
                --     END IF;	
                -- WHEN RE =>
                --     IF (RE_count <3) THEN
                -- 		-- transition variable changes
                -- 		-- make message the TX_error message
                -- 		-- setup for transmit
                -- 		-- turn off rx_error signal

                --         ns <= TX;
                --     ELSE
                --         ns <= HF;
                --     END IF;
                -- WHEN TE =>

                --     IF (TE_count < 3) THEN
                -- 		-- transition variable changes
                -- 		-- enable TX for a retransmit
                -- 		-- indicate to other controllers TX retransmit in action
                -- 		-- Turn tx_error off

                --         ns <= TX;
                --     ELSE

                --         ns <= HF;
                --     END IF;
                --  WHEN HF =>
                -- 		-- tell higher level controller in hard fault then send to align state?
                --     IF (host = '1') THEN
                --         ns <= HA;
                --     ELSE
                --         ns <= DA;
                --     END IF;
                -- WHEN HA =>
                --     IF (aligned = '1') THEN
                --         ns <= ID;
                --     ELSE
                --         ns <= HA;
                --     END IF;

                -- WHEN DA =>
                --     IF (aligned = '1') THEN
                --         ns <= ID;
                --     ELSE
                --         ns <= DA;
                --     END IF;

            when others =>
                ns          <= RT;


        end case;
    end process comb_proc;

end architecture rtl;
