----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 11:36:39
-- Design Name: 
-- Module Name: DISPLAY_CONTROL - Behavioral
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

entity DISPLAY_CONTROL is
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
end DISPLAY_CONTROL;

architecture Behavioral of DISPLAY_CONTROL is

    constant CHAR_0 : std_logic_vector(4 downto 0) := "00000";
    constant CHAR_1 : std_logic_vector(4 downto 0) := "00001";
    constant CHAR_2 : std_logic_vector(4 downto 0) := "00010";
    constant CHAR_P : std_logic_vector(4 downto 0) := "10110"; 
    constant CHAR_R : std_logic_vector(4 downto 0) := "10111";
    constant CHAR_O : std_logic_vector(4 downto 0) := "10101";
    constant CHAR_D : std_logic_vector(4 downto 0) := "10001";
    constant CHAR_U : std_logic_vector(4 downto 0) := "11001";
    constant CHAR_T : std_logic_vector(4 downto 0) := "11000";
    constant CHAR_L : std_logic_vector(4 downto 0) := "10100";
    constant CHAR_I : std_logic_vector(4 downto 0) := "00001";
    constant CHAR_A : std_logic_vector(4 downto 0) := "10000";
    constant CHAR_F : std_logic_vector(4 downto 0) := "10011";
    constant CHAR_PARPADEO : std_logic_vector(4 downto 0) := "11111";

    type T_CONTROL_ARRAY is array (0 to NUM_ESTADOS - 1) of std_logic_vector(NUM_DISPLAYS - 1 downto 0);
    type T_CODE_ARRAY is array(0 to NUM_ESTADOS - 1) of std_logic_vector(TAM_CODE - 1 downto 0);

    signal s_control : T_CONTROL_ARRAY := (others => (others => '1'));
    signal s_code    : T_CODE_ARRAY := (others => (others => '0'));

    signal s_precio_actual : unsigned(TAM_CUENTA - 1 downto 0);
    signal s_cuenta_uns    : unsigned(TAM_CUENTA - 1 downto 0);
    signal s_restante      : unsigned(TAM_CUENTA - 1 downto 0);

    signal s_parpadeo_counter : unsigned(24 downto 0) := (others => '0');
    signal s_parpadeo_enable  : std_logic;

begin

    s_cuenta_uns <= unsigned(cuenta);
    
    s_precio_actual <= unsigned(precio((TAM_CUENTA*2) - 1 downto TAM_CUENTA)) when tipo_refrescos = "10" else
                       unsigned(precio(TAM_CUENTA - 1 downto 0));

    s_restante <= s_precio_actual - s_cuenta_uns when s_precio_actual > s_cuenta_uns else 
                  (others => '0');

    process(clk)
    begin
        if rising_edge (clk) then 

            s_parpadeo_counter <= s_parpadeo_counter + 1;
            s_parpadeo_enable <= s_parpadeo_counter(s_parpadeo_counter'high); 

            case s_control(0) is 
                when "111101111" => 
                    s_control(0) <= "111011111"; s_code(0) <= CHAR_D;
                when "111011111" => 
                    s_control(0) <= "110111111"; s_code(0) <= CHAR_O;
                when "110111111" => 
                    s_control(0) <= "101111111"; s_code(0) <= CHAR_R;
                when "101111111" => 
                    s_control(0) <= "011111111"; s_code(0) <= CHAR_P;
                when others =>     
                    s_control(0) <= "111101111";
                    if tipo_refrescos = "01" then s_code(0) <= CHAR_1;
                    elsif tipo_refrescos = "10" then s_code(0) <= CHAR_2;
                    else s_code(0) <= CHAR_PARPADEO;
                    end if;       
            end case;

            case s_control(1) is 
                when "111111101" => -- Primer decimal
                    s_control(1) <= "111111011";
                    if s_restante >= 10 then 
                        s_code(1) <= std_logic_vector(s_restante - 10);
                    else
                        s_code(1) <= std_logic_vector(s_restante);
                    end if;
                    
                when "111111011" =>
                    s_control(1) <= "111110110";
                    if s_restante >= 10 then s_code(1) <= CHAR_1;
                    else s_code(1) <= CHAR_0;
                    end if;

                when "111110110" =>
                    s_control(1) <= "111011111";
                    s_code(1) <= CHAR_0;

                when "111011111" => 
                    s_control(1) <= "110111111";
                    if s_restante >= 10 then s_code(1) <= std_logic_vector(s_precio_actual - 10);
                    else s_code(1) <= std_logic_vector(s_precio_actual);
                    end if;
                    
                when "110111111" =>
                    s_control(1) <= "101111110";
                    s_code(1) <= CHAR_1; 

                when others =>
                    s_control(1) <= "111111101";
                    s_code(1) <= CHAR_0;
            end case;

            if s_parpadeo_enable = '1' then 
                case s_control(2) is 
                    when "111011111" => 
                        s_control(2) <= "110111111"; s_code(2) <= CHAR_T;
                    when "110111111" => 
                        s_control(2) <= "101111111"; s_code(2) <= CHAR_U;
                    when "101111111" => 
                        s_control(2) <= "011111111"; s_code(2) <= CHAR_O;
                    when others => 
                        s_control(2) <= "111011111";
                        if tipo_refrescos = "01" then s_code(2) <= CHAR_1;
                        elsif tipo_refrescos = "10" then s_code(2) <= CHAR_2;
                        else s_code(2) <= CHAR_PARPADEO;
                        end if; 
                end case;
            else
                 s_code(2) <= CHAR_PARPADEO;
            end if;

            if s_parpadeo_enable = '1' then
                case s_control(3) is 
                    when "111011111" => 
                         s_control(3) <= "110111111"; s_code(3) <= CHAR_I;
                    when "110111111" => 
                         s_control(3) <= "101111111"; s_code(3) <= CHAR_A;
                    when "101111111" => 
                         s_control(3) <= "011111111"; s_code(3) <= CHAR_F;
                    when others =>      
                         s_control(3) <= "111011111"; s_code(3) <= CHAR_L;
                end case;
            else
                 s_code(3) <= CHAR_PARPADEO;
            end if;
        
        end if; 
    end process;

    control_salida <= s_control(3) & s_control(2) & s_control(1) & s_control(0);  
    code_salida    <= s_code(3)    & s_code(2)    & s_code(1)    & s_code(0);   

end Behavioral;
