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
        rst_fsm: in std_logic;      
        
        moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0);
        tipo_refrescos: in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
        error: out std_logic;
        ok_pago: out std_logic;
        cuenta: out std_logic_vector(TAM_CUENTA - 1 downto 0);
        
        cambio_es_cero: out std_logic;
        
        cambio: out std_logic_vector(TAM_CUENTA - 1 downto 0); 
        precio: out std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);
        actual_refresco: out std_logic_vector(NUM_REFRESCOS - 1 downto 0)
   );
end COUNTER;

architecture Behavioral of COUNTER is

    type ARRAY_PRECIOS_TYPE is ARRAY (0 to NUM_REFRESCOS - 1) of unsigned(TAM_CUENTA - 1 downto 0);
    constant LISTA_PRECIOS_VAL: ARRAY_PRECIOS_TYPE := (to_unsigned(10, TAM_CUENTA), to_unsigned(13, TAM_CUENTA)); 

    signal r_cuenta: unsigned(TAM_CUENTA - 1 downto 0) := (others => '0');
    signal r_error: std_logic := '0';
    signal r_ok_pago: std_logic := '0';
    signal r_cambio: unsigned(TAM_CUENTA - 1 downto 0) := (others => '0');

    signal r_refresco_sel: std_logic_vector(NUM_REFRESCOS - 1 downto 0) := (others => '0');
    signal moneda_prev: std_logic_vector(NUM_MONEDAS - 1 downto 0) := (others => '0');
    signal precio_objetivo: unsigned(TAM_CUENTA - 1 downto 0);

begin
    process(clk, reset)
    begin 
        if reset = '0' then 
            r_cuenta <= (others => '0');
            r_refresco_sel <= (others => '0');
            r_error <= '0';
            r_ok_pago <= '0';
            r_cambio <= (others => '0'); 
            moneda_prev <= (others => '0');
            
        elsif rising_edge(clk) then
            if ce = '1' then
                
                moneda_prev <= moneda;
                
                if rst_fsm = '1' then
                    r_cuenta <= (others => '0');
                    r_refresco_sel <= (others => '0');
                    r_error <= '0';
                    r_ok_pago <= '0';
                    r_cambio <= (others => '0'); 
                
                else
                    r_refresco_sel <= tipo_refrescos;
                    
                    if (moneda(0) = '1' and moneda_prev(0) = '0') then 
                        if r_cuenta <= 30 then r_cuenta <= r_cuenta + 1; end if;
                    end if;
                    if (moneda(1) = '1' and moneda_prev(1) = '0') then
                        if r_cuenta <= 29 then r_cuenta <= r_cuenta + 2; end if;
                    end if;
                    if (moneda(2) = '1' and moneda_prev(2) = '0') then
                        if r_cuenta <= 26 then r_cuenta <= r_cuenta + 5; end if;
                    end if;
                    if (moneda(3) = '1' and moneda_prev(3) = '0') then
                        if r_cuenta <= 21 then r_cuenta <= r_cuenta + 10; end if;
                    end if;

                    if precio_objetivo > 0 then
                        if r_cuenta >= precio_objetivo then
                            r_ok_pago <= '1';
                            r_error <= '0';
                            r_cambio <= r_cuenta - precio_objetivo;
                        else
                            r_ok_pago <= '0';
                            r_error <= '0';
                            r_cambio <= (others => '0');
                        end if;
                    else
                        r_ok_pago <= '0';
                        r_error <= '0';
                    end if;
                end if; 
            end if; 
        end if; 
    end process;

    process(r_refresco_sel)
    begin
        precio_objetivo <= (others => '0'); 
        if r_refresco_sel = "01" then precio_objetivo <= LISTA_PRECIOS_VAL(0);
        elsif r_refresco_sel = "10" then precio_objetivo <= LISTA_PRECIOS_VAL(1);
        end if;
    end process;

    error <= r_error;
    ok_pago <= r_ok_pago;
    cuenta <= std_logic_vector(r_cuenta);
    actual_refresco <= r_refresco_sel;
    precio <= std_logic_vector(LISTA_PRECIOS_VAL(1)) & std_logic_vector(LISTA_PRECIOS_VAL(0));
    cambio <= std_logic_vector(r_cambio);

    cambio_es_cero <= '1' when (r_cambio = 0) else '0';

end Behavioral;