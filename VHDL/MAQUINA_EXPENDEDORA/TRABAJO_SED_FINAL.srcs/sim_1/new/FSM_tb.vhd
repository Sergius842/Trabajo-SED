library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_tb is
end FSM_tb;

architecture Behavioral of FSM_tb is

    component FSM
    generic(
        NUM_REFRESCOS : POSITIVE := 2;
        NUM_ESTADOS   : POSITIVE := 4;
        NUM_DISPLAYS  : POSITIVE := 9;
        TAM_CODE      : POSITIVE := 5             
    );
    port( 
        clk             : in std_logic;
        reset           : in std_logic;
        btn_pagar       : in std_logic;
        ok_pago         : in std_logic;
        cambio_es_cero  : in std_logic; 
        tipo_refrescos  : in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
        bus_control_entrada : in std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0);
        bus_code_entrada    : in std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 downto 0);
        led_refresco    : out std_logic;
        cmd_reset       : out std_logic; 
        estado_debug    : out std_logic_vector(NUM_ESTADOS - 1 downto 0);
        control_salida  : out std_logic_vector(NUM_DISPLAYS - 1 downto 0);
        code_salida     : out std_logic_vector(TAM_CODE - 1 downto 0)
    );
    end component;

    constant NUM_REFRESCOS_TB : POSITIVE := 2;
    constant NUM_ESTADOS_TB   : POSITIVE := 4;
    constant NUM_DISPLAYS_TB  : POSITIVE := 9;
    constant TAM_CODE_TB      : POSITIVE := 5;
    constant CLK_PERIOD       : time := 10 ns;

    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal btn_pagar       : std_logic := '0';
    signal ok_pago         : std_logic := '0';
    signal cambio_es_cero  : std_logic := '0';
    signal tipo_refrescos  : std_logic_vector(NUM_REFRESCOS_TB - 1 downto 0) := (others => '0');
    signal bus_control_entrada : std_logic_vector(NUM_DISPLAYS_TB * NUM_ESTADOS_TB - 1 downto 0) := (others => '0');
    signal bus_code_entrada    : std_logic_vector(TAM_CODE_TB * NUM_ESTADOS_TB - 1 downto 0) := (others => '0');

    signal led_refresco    : std_logic;
    signal cmd_reset       : std_logic;
    signal estado_debug    : std_logic_vector(NUM_ESTADOS_TB - 1 downto 0);
    signal control_salida  : std_logic_vector(NUM_DISPLAYS_TB - 1 downto 0);
    signal code_salida     : std_logic_vector(TAM_CODE_TB - 1 downto 0);

begin

    uut: FSM
    generic map(
        NUM_REFRESCOS => NUM_REFRESCOS_TB,
        NUM_ESTADOS   => NUM_ESTADOS_TB,
        NUM_DISPLAYS  => NUM_DISPLAYS_TB,
        TAM_CODE      => TAM_CODE_TB
    )
    port map(
        clk             => clk,
        reset           => reset,
        btn_pagar       => btn_pagar,
        ok_pago         => ok_pago,
        cambio_es_cero  => cambio_es_cero,
        tipo_refrescos  => tipo_refrescos,
        bus_control_entrada => bus_control_entrada,
        bus_code_entrada    => bus_code_entrada,
        led_refresco    => led_refresco,
        cmd_reset       => cmd_reset,
        estado_debug    => estado_debug,
        control_salida  => control_salida,
        code_salida     => code_salida
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
        reset <= '0';
        btn_pagar <= '0';
        ok_pago <= '0';
        tipo_refrescos <= (others => '0');
        bus_control_entrada <= (others => '0'); 
        bus_code_entrada <= (others => '0');
        
        wait for 100 ns;
        reset <= '1';
        wait for CLK_PERIOD * 2;

        tipo_refrescos <= "01";
        btn_pagar <= '1';
        wait for CLK_PERIOD;
        btn_pagar <= '0';

        wait for CLK_PERIOD * 5;

        ok_pago <= '1';
        wait for CLK_PERIOD;
        ok_pago <= '0';
        
        cambio_es_cero <= '1';

        wait for CLK_PERIOD * 20;

        wait;
    end process;

end Behavioral;