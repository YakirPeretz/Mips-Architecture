		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC;
	Jump 		: OUT 	STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	i_opc		: OUT	STD_LOGIC_VECTOR( 1 downto 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq, Bne,i_format	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0'; --addu, sll
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bne	        <=  '1'  WHEN  Opcode = "000101"  ELSE '0'; ---+
	i_format    <=  '1'  WHEN  (Opcode = "001000" or Opcode = "001100" or Opcode = "001101" or Opcode = "001110") ELSE '0';
	i_opc		<= 	"00" WHEN  Opcode = "001000" or Lw='1' or Sw='1'  ELSE --addi
					"01" WHEN  Opcode = "001100"  ELSE --andi
					"10" WHEN  Opcode = "001101"  ELSE --ori
					"11";--xori
	Jump        <=  '1'  WHEN  Opcode = "000010"  ELSE '0';
  	RegDst    	<=  R_format;
 	ALUSrc  	<=  Lw OR Sw or i_format;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw OR i_format;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq OR Bne;
	ALUOp( 2 )  <=  Bne;         ---+
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq;

   END behavior;


