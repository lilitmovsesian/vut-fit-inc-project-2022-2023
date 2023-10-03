-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author: Lilit Movsesian (xmovse00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
     port(
        CLK         : in std_logic;
        RST         : in std_logic;
        DIN         : in std_logic;
        COUNT       : in std_logic_vector(4 downto 0);
        COUNT_BIT   : in std_logic_vector(3 downto 0);
        VALID       : out std_logic;
        READ_CNTRL  : out std_logic;
        COUNT_CNTRL : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type states is (WAIT_FALLING, START_BIT, RECEIVE_WORD, STOP_BIT, VALIDATE);
    signal state : states := WAIT_FALLING;
    begin
        READ_CNTRL    <= '1' when state = RECEIVE_WORD else '0';
	COUNT_CNTRL   <= '1' when state = START_BIT or state = RECEIVE_WORD or state = STOP_BIT else '0';
	VALID         <= '1' when state = VALIDATE else '0';

	state_case : process (CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				state <= WAIT_FALLING;
			else	
				case state is
					when WAIT_FALLING =>
						if DIN = '0' then
							state <= START_BIT;
						end if;
						
					when START_BIT =>
						if COUNT = "11000" then
							state <= RECEIVE_WORD;
						end if;
						
					when RECEIVE_WORD => 
						if COUNT_BIT = "1000" then
							state <= STOP_BIT;
						end if;
						
					when STOP_BIT =>
						if COUNT = "11000" then
							state <= VALIDATE;
						end if;
						
					when VALIDATE =>
						state <= WAIT_FALLING;

					when others => null;
				end case;
				
			end if;
		end if;
	end process state_case;
end architecture;
