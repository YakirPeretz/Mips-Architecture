						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			gpio_out_LED		: OUT 	STD_LOGIC_VECTOR( 15 downto 0 );
			gpio_out_HEX 		: OUT 	STD_LOGIC_VECTOR( 27 downto 0 );
			gpio_switch 		: IN 	STD_LOGIC_VECTOR(7 downto 0);
			address 			: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS

COMPONENT gpio IS
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			gpio_out_LED		: OUT 	STD_LOGIC_VECTOR( 15 downto 0 );
			gpio_out_HEX 		: OUT 	STD_LOGIC_VECTOR( 27 downto 0 );
			gpio_switch 		: IN 	STD_LOGIC_VECTOR(7 downto 0);
        	address 			: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		IoRead, Iowrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END COMPONENT;

SIGNAL write_clock : STD_LOGIC;
SIGNAL mem_write, io_write, io_read : STD_LOGIC;
SIGNAL mem_read_data, io_read_data : STD_LOGIC_VECTOR( 31 downto 0);
BEGIN

	mem_write <= '1' when (address(11)='0' AND Memwrite='1') else '0';
	
	--Dmemory addres 0x000 to 0x1fc
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => 10,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "dmemory.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => mem_write,
		clock0 => write_clock,
		address_a => address(9 downto 0),
		data_a => write_data,
		q_a => mem_read_data);
-- Load memory address register with write clock
		write_clock <= NOT clock;
	
	-- Io address 0x200 (half of mem address of 10 bits)
	-- 			to 0x3fc
	io_write <= '1' when address(11)='1' AND Memwrite='1' else '0';
	io_read <= '1' when address(11)='1' AND MemRead='1' else '0';
	gpio_arch : gpio port map(
				io_read_data, 
				gpio_out_LED, 
				gpio_out_HEX, 
				gpio_switch,
				address(11 downto 0), 
				write_data, 
				io_read, 
				io_write,
				clock,
				reset);
	
	--choose output according to address.				
	read_data<= mem_read_data when address(11)='0' 
					else io_read_data;
	
		
	
		
END behavior;

