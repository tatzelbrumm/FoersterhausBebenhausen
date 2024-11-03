library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity quadrature_oscillator_sync is
    Port (
        clk         : in  STD_LOGIC;
        load        : in  STD_LOGIC;
        re_coeff    : in  STD_LOGIC_VECTOR(15 downto 0);
        im_coeff    : in  STD_LOGIC_VECTOR(15 downto 0);
        power       : in  STD_LOGIC_VECTOR(15 downto 0);
        accu_re_init : in  STD_LOGIC_VECTOR(15 downto 0);
        accu_im_init : in  STD_LOGIC_VECTOR(15 downto 0);
        accu_re     : out STD_LOGIC_VECTOR(15 downto 0);
        accu_im     : out STD_LOGIC_VECTOR(15 downto 0)
    );
end quadrature_oscillator_sync;

architecture Behavioral of quadrature_oscillator_sync is
    signal accu_re_reg, accu_im_reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal temp_re, temp_im         : STD_LOGIC_VECTOR(31 downto 0);
    signal tmph_re, tmph_im, t0     : STD_LOGIC_VECTOR(15 downto 0);
    signal ac3                      : STD_LOGIC_VECTOR(31 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                accu_re_reg <= accu_re_init;
                accu_im_reg <= accu_im_init;
            else
                -- Compute next values for real and imaginary parts
                temp_re <= (signed(accu_re_reg) * signed(re_coeff)) - (signed(accu_im_reg) * signed(im_coeff));
                temp_im <= (signed(accu_re_reg) * signed(im_coeff)) + (signed(accu_im_reg) * signed(re_coeff));

                -- Scale down to fixed-point representation
                tmph_re <= temp_re(30 downto 15);
                tmph_im <= temp_im(30 downto 15);

                -- Compute the power adjustment
                ac3 <= (signed(power) sll 16) - (signed(tmph_re) * signed(tmph_re)) - (signed(tmph_im) * signed(tmph_im));
                t0 <= ac3(30 downto 15);

                -- Apply power correction
                temp_re <= temp_re + (signed(tmph_re) * signed(t0));
                temp_im <= temp_im + (signed(tmph_im) * signed(t0));

                -- Update the accumulators
                accu_re_reg <= temp_re(30 downto 15);
                accu_im_reg <= temp_im(30 downto 15);
            end if;
        end if;
    end process;

    -- Output assignment
    accu_re <= accu_re_reg;
    accu_im <= accu_im_reg;
end Behavioral;

