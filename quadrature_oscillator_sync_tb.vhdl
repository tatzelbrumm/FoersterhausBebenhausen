library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity quadrature_oscillator_sync_tb is
end quadrature_oscillator_sync_tb;

architecture Behavioral of quadrature_oscillator_sync_tb is
    -- Testbench signals
    signal clk            : STD_LOGIC := '0';
    signal load           : STD_LOGIC;
    signal re_coeff       : STD_LOGIC_VECTOR(15 downto 0);
    signal im_coeff       : STD_LOGIC_VECTOR(15 downto 0);
    signal power          : STD_LOGIC_VECTOR(15 downto 0);
    signal accu_re_init   : STD_LOGIC_VECTOR(15 downto 0);
    signal accu_im_init   : STD_LOGIC_VECTOR(15 downto 0);
    signal accu_re        : STD_LOGIC_VECTOR(15 downto 0);
    signal accu_im        : STD_LOGIC_VECTOR(15 downto 0);

    -- Number of iterations
    constant num_iterations : integer := 10;
begin
    -- Instantiate the quadrature oscillator
    uut: entity work.quadrature_oscillator_sync
        Port map (
            clk => clk,
            load => load,
            re_coeff => re_coeff,
            im_coeff => im_coeff,
            power => power,
            accu_re_init => accu_re_init,
            accu_im_init => accu_im_init,
            accu_re => accu_re,
            accu_im => accu_im
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Test procedure
    test_process: process
    begin
        -- Initialize parameters
        re_coeff <= X"4000";        -- Example real coefficient
        im_coeff <= X"2000";        -- Example imaginary coefficient
        power <= X"1000";           -- Target power level
        accu_re_init <= X"3000";    -- Initial accumulator real part
        accu_im_init <= X"1000";    -- Initial accumulator imaginary part

        -- Preload the oscillator with initial values
        load <= '1';
        wait for 10 ns; -- Wait for 1 clock cycle to load initial values
        load <= '0';

        -- Run for the specified number of iterations
        for i in 0 to num_iterations - 1 loop
            wait for 10 ns;  -- Wait for 1 clock cycle per iteration
            report "Iteration " & integer'image(i) & 
                   ": accu_re = " & integer'image(to_integer(signed(accu_re))) &
                   ", accu_im = " & integer'image(to_integer(signed(accu_im)));
        end loop;

        -- End simulation
        wait;
    end process;
end Behavioral;

