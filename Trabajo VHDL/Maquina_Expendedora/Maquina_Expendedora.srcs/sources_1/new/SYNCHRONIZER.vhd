----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 16:14:05
-- Design Name: 
-- Module Name: SYNCHRONIZER - Behavioral
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

entity SYNCHRONIZER is
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
end SYNCHRONIZER;

architecture Behavioral of SYNCHRONIZER is

    signal ff1_monedas, ff2_monedas: std_logic_vector(NUM_MONEDAS - 1 downto 0);
    signal ff1_pago, ff2_pago: std_logic;
    signal ff1_refrescos, ff2_refrescos: std_logic_vector(NUM_REFRESCOS - 1 downto 0);

begin
    p_synchronization: process(clk, rst)
    begin
        if rst = '1' then
            ff1_monedas <= (others => '0');
            ff2_monedas <= (others => '0');
            ff1_pago <= '0';
            ff2_pago <= '0';
            ff1_refrescos <= (others => '0');
            ff2_refrescos <= (others => '0');
            
        elsif rising_edge(clk) then
            ff1_monedas <= asinc_monedas;
            ff1_pago <= asinc_pago;
            ff1_refrescos <= asinc_refresco;
            
            ff2_monedas <= ff1_monedas;
            ff2_pago <= ff1_pago;
            ff2_refrescos <= ff1_refrescos;
        end if;
    end process;

    sinc_monedas <= ff2_monedas;
    sinc_pago <= ff2_pago;
    sinc_refresco <= ff2_refrescos;

end Behavioral;