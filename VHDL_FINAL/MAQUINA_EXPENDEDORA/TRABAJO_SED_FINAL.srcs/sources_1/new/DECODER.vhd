----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 11:55:14
-- Design Name: 
-- Module Name: DECODER - Behavioral
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

entity DECODER is
    generic(
        TAM_CODE      : POSITIVE := 5;
        NUM_SEGMENTOS : POSITIVE := 7        
    );
    port(
        code_entrada      : in std_logic_vector(TAM_CODE - 1 downto 0);
        segments_salida : out std_logic_vector(NUM_SEGMENTOS - 1 downto 0)
    );
end DECODER;

architecture Behavioral of DECODER is
begin

    process(code_entrada)
    begin
        case code_entrada is

            when "00000" => segments_salida <= "0000001"; 
            when "00001" => segments_salida <= "1001111"; 
            when "00010" => segments_salida <= "0010010";
            when "00011" => segments_salida <= "0000110"; 
            when "00100" => segments_salida <= "1001100"; 
            when "00101" => segments_salida <= "0100100"; 
            when "00110" => segments_salida <= "0100000"; 
            when "00111" => segments_salida <= "0001111"; 
            when "01000" => segments_salida <= "0000000"; 
            when "01001" => segments_salida <= "0000100"; 

            when "01100" => segments_salida <= "0110001"; 

            when "11100" => segments_salida <= "1001000"; 
            when "11101" => segments_salida <= "0100000";

            when "10000" => segments_salida <= "0001000"; 
            when "10001" => segments_salida <= "1000010"; 
            when "10010" => segments_salida <= "0110000"; 
            when "10011" => segments_salida <= "0111000"; 
            when "10100" => segments_salida <= "1110001"; 
            when "10101" => segments_salida <= "1100010"; 
            when "10110" => segments_salida <= "0011000"; 
            when "10111" => segments_salida <= "1111010"; 
            when "11000" => segments_salida <= "1110000"; 
            when "11001" => segments_salida <= "1100011"; 

            when others  => segments_salida <= "1111110"; 
        end case;
    end process;

end Behavioral;