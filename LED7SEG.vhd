library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-----------------------------------------
Entity LED7SEG IS
	PORT ( 	  	LED_BCD : in std_logic_vector(3 downto 0);
				LED_HEX: OUT std_logic_vector(6 downto 0));
END LED7SEG;

ARCHITECTURE LED7SEGArch OF LED7SEG IS
BEGIN
	process(LED_BCD)
begin
    case LED_BCD is
    when "0000" => LED_HEX <= "0000001"; -- "0"     
    when "0001" => LED_HEX <= "1001111"; -- "1" 
    when "0010" => LED_HEX <= "0010010"; -- "2" 
    when "0011" => LED_HEX <= "0000110"; -- "3" 
    when "0100" => LED_HEX <= "1001100"; -- "4" 
    when "0101" => LED_HEX <= "0100100"; -- "5" 
    when "0110" => LED_HEX <= "0100000"; -- "6" 
    when "0111" => LED_HEX <= "0001111"; -- "7" 
    when "1000" => LED_HEX <= "0000000"; -- "8"     
    when "1001" => LED_HEX <= "0000100"; -- "9" 
    when "1010" => LED_HEX <= "0000010"; -- a
    when "1011" => LED_HEX <= "1100000"; -- b
    when "1100" => LED_HEX <= "0110001"; -- C
    when "1101" => LED_HEX <= "1000010"; -- d
    when "1110" => LED_HEX <= "0110000"; -- E
    when "1111" => LED_HEX <= "0111000"; -- F
    end case;
end process;

END LED7SEGArch;