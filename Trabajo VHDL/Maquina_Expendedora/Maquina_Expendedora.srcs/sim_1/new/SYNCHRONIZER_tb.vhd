----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 17:16:03
-- Design Name: 
-- Module Name: SYNCHRONIZER_tb - Behavioral
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

entity SYNCHRONIZER_tb is

end SYNCHRONIZER_tb;

architecture Behavioral of SYNCHRONIZER_tb is

  
    component SYNCHRONIZER
        generic(
            NUM_MONEDAS: positive := 4;
            NUM_REFRESCOS: positive := 2
        );
        port(
            clk: in std_logic;
            rst: in std_logic;
            asinc_pago: in std_logic;
            asinc_monedas: in std_logic_vector(NUM_MONEDAS - 1 downto 0); 
            asinc_refresco: in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
            
            sinc_pago: out std_logic;
            sinc_monedas: out std_logic_vector(NUM_MONEDAS - 1 downto 0);
            sinc_refresco: out std_logic_vector(NUM_REFRESCOS - 1 downto 0)
        );        
    end component;

   
    constant c_NUM_MONEDAS   : positive := 4;
    constant c_NUM_REFRESCOS : positive := 2;
    constant c_CLK_PERIOD    : time := 10 ns; 

 
    signal clk             : std_logic := '0';
    signal rst             : std_logic := '0';
    signal tb_asinc_pago   : std_logic := '0';
    signal tb_asinc_monedas: std_logic_vector(c_NUM_MONEDAS - 1 downto 0) := (others => '0');
    signal tb_asinc_refresco: std_logic_vector(c_NUM_REFRESCOS - 1 downto 0) := (others => '0');

   
    signal tb_sinc_pago    : std_logic;
    signal tb_sinc_monedas : std_logic_vector(c_NUM_MONEDAS - 1 downto 0);
    signal tb_sinc_refresco: std_logic_vector(c_NUM_REFRESCOS - 1 downto 0);

begin

    
    uut: SYNCHRONIZER
        generic map (
            NUM_MONEDAS   => c_NUM_MONEDAS,
            NUM_REFRESCOS => c_NUM_REFRESCOS
        )
        port map (
            clk            => clk,
            rst            => rst,
            asinc_pago     => tb_asinc_pago,
            asinc_monedas  => tb_asinc_monedas,
            asinc_refresco => tb_asinc_refresco,
            sinc_pago      => tb_sinc_pago,
            sinc_monedas   => tb_sinc_monedas,
            sinc_refresco  => tb_sinc_refresco
        );

    
    p_reloj: process
    begin
        clk <= '0';
        wait for c_CLK_PERIOD / 2;
        clk <= '1';
        wait for c_CLK_PERIOD / 2;
    end process;

    p_stimulus: process
    begin
        
        wait for 100 ns;

        
        rst <= '1';
        
        
        tb_asinc_pago <= '1';
        tb_asinc_monedas <= "1111";
        wait for c_CLK_PERIOD * 2;
        
        
        assert tb_sinc_pago = '0' 
            report "FALLO: El Reset no ha limpiado la señal de pago" severity error;
        assert tb_sinc_monedas = "0000" 
            report "FALLO: El Reset no ha limpiado las monedas" severity error;

        rst <= '0';
     
        tb_asinc_pago <= '0';
        tb_asinc_monedas <= "0000";
        wait for c_CLK_PERIOD * 2;

        wait until falling_edge(clk); 
        tb_asinc_monedas <= "0010";
        
    
        wait until rising_edge(clk); 
        wait for 1 ns; 
        assert tb_sinc_monedas = "0000" 
            report "INFO: Correcto, primer ciclo de retardo cumplido" severity note;

        wait until rising_edge(clk);
        wait for 1 ns;
        
        assert tb_sinc_monedas = "0010"
            report "FALLO: La señal no se ha sincronizado tras 2 ciclos" severity error;

        wait for c_CLK_PERIOD * 5;
        assert false report "EXITO: Simulación terminada correctamente." severity failure;
        
    end process;

end Behavioral;