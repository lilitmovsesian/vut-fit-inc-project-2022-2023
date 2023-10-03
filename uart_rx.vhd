-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author: Lilit Movsesian (xmovse00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Entity declaration
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;

-- Architecture implementation
architecture behavioral of UART_RX is
    signal count       : std_logic_vector(4 downto 0);
    signal count_bit   : std_logic_vector(3 downto 0);
    signal valid       : std_logic := '0';
    signal read_cntrl  : std_logic := '0';
    signal count_cntrl : std_logic := '0';
begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK         => CLK,
        RST         => RST,
        DIN         => DIN,
        COUNT       => count,
        COUNT_BIT   => count_bit,
        VALID       => valid,
        READ_CNTRL  => read_cntrl,
        COUNT_CNTRL => count_cntrl
    );


    main_proc : process (CLK)
    begin
        DOUT_VLD <= valid;
	if rising_edge(CLK) then
            if count_cntrl = '0' then
                count <= "00000";
        	if read_cntrl = '0' then
            	    count_bit <= "0000";
        	end if;
            elsif count_cntrl = '1' then
                count <= count + 1;
                if (count(4) = '1' or count(3 downto 0)= "1111") and read_cntrl = '1' then
                    count <= "00000";
                    count_bit <= count_bit + 1;
                    DOUT(to_integer(unsigned(count_bit))) <= DIN;
                end if;
            end if;
        end if;
    end process main_proc;
end architecture;




