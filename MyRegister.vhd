library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-----------------------------------------
ENTITY MyRegister IS
	GENERIC(n : INTEGER );
	PORT ( 	  	rst, ena, clk : IN STD_LOGIC;
				din : in std_logic_vector(n-1 downto 0);
				d: OUT std_logic_vector(n-1 downto 0));
END MyRegister;
-----------------------------------------
ARCHITECTURE RegisterArch OF MyRegister IS
		Signal reg : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF (rst='1')THEN
			reg <= (others => '0');
		ELSIF (clk'EVENT AND clk='1') THEN
			if ena = '1' then
				reg <= din;
			end if;
		END IF;	
		
	END PROCESS;
	d <= reg;

END RegisterArch;
