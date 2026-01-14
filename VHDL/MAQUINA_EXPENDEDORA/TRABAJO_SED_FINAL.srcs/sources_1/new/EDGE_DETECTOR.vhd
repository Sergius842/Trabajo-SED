----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 16:35:05
-- Design Name: 
-- Module Name: EDGE_DETECTOR - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EDGE_DETECTOR is
    Generic(
        NUM_MONEDAS: positive:= 4       
    );
    Port(
        clk: in std_logic;
        entrada_moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0); 
        flanco_monedas: out std_logic_vector(NUM_MONEDAS - 1 downto 0)
    );
end EDGE_DETECTOR;

architecture Behavioral of EDGE_DETECTOR is
    signal moneda_anterior: std_logic_vector(NUM_MONEDAS - 1 downto 0) := (others => '0');
begin
    
    process(clk)
    begin
        if rising_edge (clk) then
            moneda_anterior <= entrada_moneda;
        end if;
    end process;

    flanco_monedas <= entrada_moneda AND (NOT moneda_anterior); 
    
end Behavioral;