--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			i_opc			: IN	STD_LOGIC_VECTOR( 1 downto 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
----+
SIGNAL Sll_Srl_ctrl				: STD_LOGIC; 
SIGNAL Sll_Srl, AND_XOR, Imm_Result		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
BEGIN
	Ainput <= Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 
		WHEN ( ALUSrc = '0' ) 
  		ELSE  Sign_extend( 31 DOWNTO 0 );
	
	-------++++
	Sll_Srl_ctrl <= '1' when (ALUOp(1)='1' AND (Function_opcode = "000000")) 
								or (ALUOp(1)='1' AND (Function_opcode = "000010"))
	---+ goes to ctl=101  
	--(before changing - "010")
				ELSE '0';
	------++++++
	
	Sll_Srl <= to_stdlogicvector(to_bitvector(std_logic_vector(Binput)) 
						SLL to_integer(unsigned(Sign_extend(10 downto 6)))) WHEN Function_opcode = "000000" 
				ELSE
				to_stdlogicvector(to_bitvector(std_logic_vector(Binput)) 
						SRL to_integer(unsigned(Sign_extend(10 downto 6))));
						
						
						-- Generate ALU control bits
						---+ Added the sll ctl computation
	ALU_ctl( 0 ) <= (( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 )) OR Sll_Srl_ctrl;
	ALU_ctl( 1 ) <= (( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) ))AND (NOT Sll_Srl_ctrl);
	ALU_ctl( 2 ) <= (( Function_opcode( 1 ) AND ALUOp( 1 )) OR (ALUOp( 0 )) OR ALUOp(2)) OR Sll_Srl_ctrl;
						-- Generate Zero Flag
	-- imm -> ALU_ctl="010"
	-- ADD -> ALU_ctl="010"
	-- ADDU-> ALU_ctl="011"
	-- Or  -> ALU_ctl="001"
	-- Sub -> ALU_ctl="110"
	-- Xor -> ALU_ctl="100"
	-- lw/sw -> ALU_ctl="010"
	Zero <= '1' ----+
		WHEN (( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )AND ALUOp(0)='1' )OR 
		(( ALU_output_mux( 31 DOWNTO 0 ) /= X"00000000"  )AND ALUOp(2)='1')
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );
				
	Imm_Result  <= Ainput + Binput WHEN (i_opc="00" or (Function_opcode="100000"AND ALUOp(1)='1')) ELSE
				   Ainput AND Binput WHEN i_opc="01" ELSE
				   Ainput OR Binput WHEN i_opc="10" ELSE
				   Ainput XOR Binput;
	
PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs immediate
	 	WHEN "010" 	=>	ALU_output_mux 	<= Imm_Result;
						-- ALU performs ADDU
 	 	WHEN "011" 	=>	ALU_output_mux <= Ainput + Binput;
						-- ALU performs ?
 	 	WHEN "100" 	=>	ALU_output_mux 	<= Ainput XOR Binput;
						-- ALU performs SLL or SRL
 	 	WHEN "101" 	=>	ALU_output_mux 	<= Sll_Srl;
						-- ALU performs Bne / Beq
 	 	WHEN "110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

