library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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
        cambio: in std_logic_vector(TAM_CUENTA - 1 downto 0); 
        code_salida : out std_logic_vector (TAM_CODE * NUM_ESTADOS - 1 downto 0);
        control_salida : out std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0)
    );
    end component;

    constant TAM_CUENTA_TB : positive := 5;
    constant NUM_REFRESCOS_TB : positive := 2;
    constant TAM_CODE_TB : positive := 5;
    constant NUM_ESTADOS_TB : positive := 4;
    constant NUM_DISPLAYS_TB : positive := 9;
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal cuenta : std_logic_vector (TAM_CUENTA_TB - 1 downto 0) := (others => '0');
    signal tipo_refrescos: std_logic_vector (NUM_REFRESCOS_TB - 1 downto 0) := (others => '0');
    signal precio: std_logic_vector(NUM_REFRESCOS_TB * TAM_CUENTA_TB - 1 downto 0) := (others => '0');
    signal cambio: std_logic_vector(TAM_CUENTA_TB - 1 downto 0) := (others => '0');
    signal code_salida : std_logic_vector (TAM_CODE_TB * NUM_ESTADOS_TB - 1 downto 0);
    signal control_salida : std_logic_vector(NUM_DISPLAYS_TB * NUM_ESTADOS_TB - 1 downto 0);

begin

    uut: DISPLAY_CONTROL
    Generic map(
        TAM_CUENTA => TAM_CUENTA_TB,
        NUM_REFRESCOS => NUM_REFRESCOS_TB,
        TAM_CODE => TAM_CODE_TB,
        NUM_ESTADOS => NUM_ESTADOS_TB,
        NUM_DISPLAYS => NUM_DISPLAYS_TB
    )
    Port map(
        clk => clk,
        cuenta => cuenta,
        tipo_refrescos => tipo_refrescos,
        precio => precio,
        cambio => cambio,
        code_salida => code_salida,
        control_salida => control_salida
    );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        cuenta <= (others => '0');
        tipo_refrescos <= (others => '0');
        cambio <= (others => '0');
        precio <= std_logic_vector(to_unsigned(13, 5)) & std_logic_vector(to_unsigned(10, 5));
        wait for 100 ns;

        tipo_refrescos <= "01"; 
        cuenta <= "00000";      
        wait for CLK_PERIOD * 10;

        cuenta <= "00101"; 
        wait for CLK_PERIOD * 10;

        cuenta <= "01010"; 
        wait for CLK_PERIOD * 10;

        tipo_refrescos <= "10";
        cuenta <= "01111"; 
        cambio <= "00010"; 
        wait for CLK_PERIOD * 10;

        tipo_refrescos <= "00";
        cuenta <= "00000";
        cambio <= "00000";
        wait for CLK_PERIOD * 10;

        wait;
    end process;

end Behavioral;