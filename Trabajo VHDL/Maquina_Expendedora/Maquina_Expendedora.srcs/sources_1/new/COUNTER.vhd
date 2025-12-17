----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2025 12:16:47
-- Design Name: 
-- Module Name: COUNTER - Behavioral
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

entity COUNTER is 
    generic(
        NUM_MONEDAS: positive:= 4;
        NUM_REFRESCOS: positive:= 2;
        TAM_CUENTA: positive:= 5       
    );
    port(
        clk: in std_logic;
        ce: in std_logic;
        reset: in std_logic;
        moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0);
        tipo_refrescos: in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
        error: out std_logic;
        ok_pago: out std_logic;
        cuenta: out std_logic_vector(TAM_CUENTA - 1 downto 0);
        precio: out std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);
        actual_refresco: out std_logic_vector(NUM_REFRESCOS - 1 downto 0)
   );
end COUNTER;

architecture Behavioral of COUNTER is

    constant PRECIO_1 : integer := 10;
    constant PRECIO_2 : integer := 13; 
    
    signal s_cuenta: unsigned(TAM_CUENTA - 1 downto 0) := (others => '0');
    signal s_precio_requerido: unsigned(TAM_CUENTA - 1 downto 0);
    
    signal s_precios: std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);

begin

    s_precios(TAM_CUENTA - 1 downto 0) <= std_logic_vector(to_unsigned(PRECIO_1, TAM_CUENTA));
    s_precios((TAM_CUENTA*2) - 1 downto TAM_CUENTA) <= std_logic_vector(to_unsigned(PRECIO_2, TAM_CUENTA));
    precio <= s_precios;

    process(clk, reset)
    begin
        if reset = '0' then
            actual_refresco <= (others => '0');
        elsif rising_edge(clk) then
             if s_cuenta = 0 then 
                actual_refresco <= tipo_refrescos;
             end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '0' then
            s_cuenta <= (others => '0');
        elsif rising_edge(clk) then
            if ce = '1' then
                case moneda is
                    when "0001" => s_cuenta <= s_cuenta + 1;
                    when "0010" => s_cuenta <= s_cuenta + 2;
                    when "0100" => s_cuenta <= s_cuenta + 5;
                    when "1000" => s_cuenta <= s_cuenta + 10;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    cuenta <= std_logic_vector(s_cuenta);

    process(s_cuenta, tipo_refrescos)
    begin
        if tipo_refrescos = "10" then
            s_precio_requerido <= to_unsigned(PRECIO_2, TAM_CUENTA);
        else
            s_precio_requerido <= to_unsigned(PRECIO_1, TAM_CUENTA);
        end if;

        error <= '0';   
        ok_pago <= '0';

        if tipo_refrescos /= "00" then
            if s_cuenta >= s_precio_requerido then
                ok_pago <= '1';
                error <= '0';
            elsif s_cuenta < s_precio_requerido then
                ok_pago <= '0';
                error <= '0';
            end if;
        else
            ok_pago <= '0';
            error <= '0';
        end if;
    end process;

end Behavioral;
