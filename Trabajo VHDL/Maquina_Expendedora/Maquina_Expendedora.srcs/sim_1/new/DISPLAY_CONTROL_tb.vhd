----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 17:39:45
-- Design Name: 
-- Module Name: DISPLAY_CONTROL_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity DISPLAY_CONTROL_tb is

end DISPLAY_CONTROL_tb;

architecture Behavioral of DISPLAY_CONTROL_tb is

    component DISPLAY_CONTROL
        Generic(
            TAM_CUENTA: positive := 5;
            NUM_REFRESCOS: positive := 2;
            TAM_CODE: positive := 5;
            NUM_ESTADOS: positive := 4;
            NUM_DISPLAYS: positive := 9
        );
        Port(
            clk : in std_logic;
            cuenta : in std_logic_vector (TAM_CUENTA - 1 downto 0);
            tipo_refrescos: in std_logic_vector (NUM_REFRESCOS - 1 downto 0);
            precio: in std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);
            
            code_salida : out std_logic_vector (TAM_CODE * NUM_ESTADOS - 1 downto 0);
            control_salida : out std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0)
        );
    end component;

    constant TAM_CUENTA    : positive := 5;
    constant NUM_REFRESCOS : positive := 2;
    constant TAM_CODE      : positive := 5;
    constant NUM_ESTADOS   : positive := 4;
    constant NUM_DISPLAYS  : positive := 9;
    constant CLOCK_PERIOD  : time := 10 ns; 

    
    signal clk            : std_logic := '0';
    signal cuenta         : std_logic_vector(TAM_CUENTA - 1 downto 0) := (others => '0');
    signal tipo_refrescos : std_logic_vector(NUM_REFRESCOS - 1 downto 0) := (others => '0');
    signal precio         : std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0) := (others => '0');

    signal code_salida    : std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 downto 0);
    signal control_salida : std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0);

    constant PRECIO_REF_1 : std_logic_vector(4 downto 0) := "01010"; -- 10 (1.00 Eur)
    constant PRECIO_REF_2 : std_logic_vector(4 downto 0) := "01101"; -- 13 (1.30 Eur)

begin

    uut: DISPLAY_CONTROL
        generic map (
            TAM_CUENTA => TAM_CUENTA,
            NUM_REFRESCOS => NUM_REFRESCOS,
            TAM_CODE => TAM_CODE,
            NUM_ESTADOS => NUM_ESTADOS,
            NUM_DISPLAYS => NUM_DISPLAYS
        )
        port map (
            clk => clk,
            cuenta => cuenta,
            tipo_refrescos => tipo_refrescos,
            precio => precio,
            code_salida => code_salida,
            control_salida => control_salida
        );

    p_clk: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    p_stim: process
    begin
       
        precio <= PRECIO_REF_2 & PRECIO_REF_1;
        
        wait for 100 ns;

        
        tipo_refrescos <= "01";
        cuenta <= "00000";
        
        
        wait for CLOCK_PERIOD * 20;

        
        tipo_refrescos <= "10";
        cuenta <= "00101"; 
        
        
        wait for CLOCK_PERIOD * 20;

        
        cuenta <= "01111"; 
        
        wait for CLOCK_PERIOD * 20;
        
        assert false report "FIN DE SIMULACION: Verifica las ondas." severity failure;
        wait;
    end process;

end Behavioral;