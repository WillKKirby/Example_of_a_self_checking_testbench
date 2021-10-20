-- Self checking testbench for the algorithm circuit  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity algorithm_TB is
end algorithm_TB;

architecture Behavioral of algorithm_TB is

-- Constants 
constant data_size : integer := 16;
constant clk_period : time := 120ns;
constant latency : natural := 2;  -- Change this for pipelining latency

-- Inputs
signal clk : std_logic;
signal rst : std_logic;

signal A : STD_LOGIC_VECTOR (data_size-1 downto 0);
signal B : STD_LOGIC_VECTOR (data_size-1 downto 0);
signal C : STD_LOGIC_VECTOR (data_size-1 downto 0);
signal D : STD_LOGIC_VECTOR (data_size-1 downto 0);

-- Outputs
signal O : STD_LOGIC_VECTOR (data_size*2-1 downto 0);

-- Record for the tests 
type test_vector is record
    A : std_logic_vector(data_size-1 downto 0);
    B : std_logic_vector(data_size-1 downto 0);
    C : std_logic_vector(data_size-1 downto 0);
    D : std_logic_vector(data_size-1 downto 0);
    O : std_logic_vector(data_size*2-1 downto 0);
end record;

-- Array of tests for the circuit. 

type test_vector_array is array
    (natural range <>) of test_vector;
constant test_vectors : test_vector_array := (
    -- A, B, C, D, O
    (X"5000", X"0300", X"0020", X"0040", X"00000565"),
    (X"0300", X"5000", X"0020", X"0030", X"000035aa"),
    (X"0020", X"0000", X"5000", X"0020", X"00005008"),
    (X"0001", X"0020", X"0300", X"5000", X"00000306"),
    (X"5001", X"5001", X"0202", X"0010", X"000a1b27"));
        
begin
-- UUT - Algorithm
UUT: entity work.algorithm
    port map (
        clk => clk,
        rst => rst,
        A => A,
        B => B,
        C => C,
        D => D,
        O => O );

-- Clock Process
clkProcess : process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1'; 
    wait for clk_period/2;
end process;

-- Input Process
set_inputs: process
begin
    -- Specified wait time
    wait for 500ns; 
    wait until falling_edge(clk);
    
    -- Initalise Inputs
    rst <= '0';
    A <= X"0000";
    B <= X"0000";
    C <= X"0000";
    D <= (0 => '1', others => '0');
    
    -- Inital Reset
    wait for clk_period/2;
    rst <= '1';
    wait for clk_period/2;
    rst <= '0';

    
    -- Using a loop to check all record values
    for i in test_vectors'range loop
        -- Init Inputs
        A <= test_vectors(i).A;
        B <= test_vectors(i).B;
        C <= test_vectors(i).C;
        D <= test_vectors(i).D;
        wait for clk_period; 
    end loop;
    wait;
end process;

-- Check Process
check_outputs: process
begin
    -- Again specified wait time
    wait for 500ns; 
    wait until falling_edge(clk);
    
    -- Wait for the latency 
    wait for clk_period*latency; 

    -- Waiting for the same clock period as the input process
    wait for clk_period/2;
    wait for clk_period/2;
    
    -- The testing stratagy is to push the inputs from the above array,
    --   into the circuit and check the outputs against the known-good values.
    -- The testing isn't exhaustive however each line is tested with at least one 
    --   larger value. The cascading value I used is '20480' which is "5000" in hex.
    
    -- Test patterns 
    for i in test_vectors'range loop
        -- If there is an error...
        assert (O = test_vectors(i).O)
        report "Test Vector " & integer'image(i) & " failed,  Output: O = " & integer'image(to_integer(unsigned(O))) &
         " ,Intended Output: " &  integer'image(to_integer(unsigned(test_vectors(i).O)))
        severity error;
        -- When it is sucessful...
        assert (not (O = test_vectors(i).O))
        report "Test Vector " & integer'image(i) & " Passed,  Output: O = " & integer'image(to_integer(unsigned(O))) & 
         " ,Intended Output: " &  integer'image(to_integer(unsigned(test_vectors(i).O)))
        severity note;
        wait for clk_period; 
    end loop;
    wait;
end process;

end Behavioral;











