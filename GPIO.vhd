						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;


ENTITY gpio IS
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			gpio_out_LED		: OUT 	STD_LOGIC_VECTOR( 15 downto 0 );
			gpio_out_HEX 		: OUT 	STD_LOGIC_VECTOR( 27 downto 0 );
			gpio_switch 		: IN 	STD_LOGIC_VECTOR(7 downto 0);
        	address 			: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		IoRead, Iowrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END gpio;

ARCHITECTURE gpio_arch OF gpio IS

COMPONENT MyRegister IS
	GENERIC(n : INTEGER := 8);
	PORT ( 	  	rst, ena, clk : IN STD_LOGIC;
				din : in std_logic_vector(n-1 downto 0);
				d: OUT std_logic_vector(n-1 downto 0));
END COMPONENT;

COMPONENT LED7SEG IS
	PORT ( 	  	LED_BCD : in std_logic_vector(3 downto 0);
				LED_HEX: OUT std_logic_vector(6 downto 0));
END COMPONENT;

Signal ena0, ena1, ena2, ena3, ena4, ena5, enaIn : STD_LOGIC;
signal Hex0, Hex1, Hex2, Hex3 : STD_LOGIC_VECTOR(3 downto 0);
signal gpio_switch_reg : STD_LOGIC_VECTOR(7 downto 0);
BEGIN
	ena0 <= '1' when Iowrite='1' AND address=X"800"	--LEDG
			else '0';
	ena1 <= '1' when Iowrite='1' AND address=X"804" --LEDR
			else '0';
	ena2 <= '1' when Iowrite='1' AND address=X"808"	--HEX0
		else '0';
	ena3 <= '1' when Iowrite='1' AND address=X"80C"	--HEX1
		else '0';
	ena4 <= '1' when Iowrite='1' AND address=X"810"	--HEX2
		else '0';
	ena5 <= '1' when Iowrite='1' AND address=X"814"	--HEX3
		else '0';
	enaIn <= '1' when IoRead='1' AND address=X"818" --Input switch
		else '0';
	--ena3 <= IoRead; --read register.
	r0: MyRegister generic map (8) port map(reset, ena0, clock, write_data(7 downto 0), gpio_out_LED(7 downto 0));
	r1: MyRegister generic map (8) port map(reset, ena1, clock, write_data(15 downto 8), gpio_out_LED(15 downto 8));
	r2: MyRegister generic map (4) port map(reset, ena2, clock, write_data(3 downto 0), HEX0);
	r3: MyRegister generic map (4) port map (reset, ena3, clock, write_data(7 downto 4), HEX1);
	r4: MyRegister generic map (4) port map(reset, ena4, clock, write_data(11 downto 8), HEX2);
	r5: MyRegister generic map (4) port map(reset, ena5, clock, write_data(15 downto 12), HEX3);
	
	hex00: LED7SEG port map(Hex0, gpio_out_HEX(6 downto 0));
	hex01: LED7SEG port map(Hex1, gpio_out_HEX(13 downto 7));
	hex02: LED7SEG port map(Hex2, gpio_out_HEX(20 downto 14));
	hex03: LED7SEG port map(Hex3, gpio_out_HEX(27 downto 21));
	
	switch: MyRegister generic map (8) port map(reset, enaIn, clock, gpio_switch, gpio_switch_reg);
	read_data(7 downto 0) <= gpio_switch_reg when enaIn='1' else "00000000";
	
	
	--r3: MyRegister port map(reset, ena3, clock, gpio_in, read_Reg);
	read_data(31 downto 8) <= X"000000";
	
END gpio_arch;

