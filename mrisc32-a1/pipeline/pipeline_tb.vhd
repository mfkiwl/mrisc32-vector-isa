----------------------------------------------------------------------------------------------------
-- Copyright (c) 2018 Marcus Geelnard
--
-- This software is provided 'as-is', without any express or implied warranty. In no event will the
-- authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose, including commercial
-- applications, and to alter it and redistribute it freely, subject to the following restrictions:
--
--  1. The origin of this software must not be misrepresented; you must not claim that you wrote
--     the original software. If you use this software in a product, an acknowledgment in the
--     product documentation would be appreciated but is not required.
--
--  2. Altered source versions must be plainly marked as such, and must not be misrepresented as
--     being the original software.
--
--  3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.common.all;

entity pipeline_tb is
end pipeline_tb;

architecture behavioral of pipeline_tb is
  signal s_clk : std_logic;
  signal s_rst : std_logic;

  -- Memory interface.
  signal s_mem_req : std_logic;
  signal s_mem_we : std_logic;
  signal s_mem_addr : T_CACHE_LINE_ADDR;
  signal s_mem_write_data : T_CACHE_LINE_DATA;
  signal s_mem_read_addr : T_CACHE_LINE_ADDR;
  signal s_mem_read_data : T_CACHE_LINE_DATA;
  signal s_mem_read_data_ready : std_logic;
begin
  pipeline_0: entity work.pipeline
    port map (
      i_clk => s_clk,
      i_rst => s_rst,

      -- Memory interface.
      o_mem_req => s_mem_req,
      o_mem_we => s_mem_we,
      o_mem_byte_mask => s_mem_byte_mask,
      o_mem_addr => s_mem_addr,
      o_mem_write_data => s_mem_write_data,
      i_mem_read_data => s_mem_read_data,
      i_mem_read_data_ready => s_mem_read_data_ready
    );

  process
    -- We have a memory array that represents 128KB or RAM (for program and data).
    constant C_MEM_NUM_WORDS : integer := 2**15;
    type T_MEM_ARRAY is array (0 to C_MEM_NUM_WORDS-1) of std_logic_vector(C_WORD_SIZE-1 downto 0);
    variable v_mem_array : T_MEM_ARRAY;

    -- File I/O.
    type T_CHAR_FILE is file of character;
    file f_char_file : T_CHAR_FILE;

    -- Variables for the memory interface.
    variable v_mem_idx : integer;
    variable v_data : std_logic_vector(C_WORD_SIZE-1 downto 0);
    variable v_write_mask : std_logic_vector(C_WORD_SIZE-1 downto 0);

    -- How many CPU cycles should we simulate?
    constant C_TEST_CYCLES : integer := 20000000;

    -- Helper function for reading one word from a binary file.
    function read_word(file f : T_CHAR_FILE) return std_logic_vector is
      variable v_char : character;
      variable v_byte : std_logic_vector(7 downto 0);
      variable v_word : std_logic_vector(C_WORD_SIZE-1 downto 0);
    begin
      for i in 0 to (C_WORD_SIZE/8)-1 loop
        read(f, v_char);
        v_byte := std_logic_vector(to_unsigned(character'pos(v_char), 8));
        v_word(((i+1)*8)-1 downto i*8) := v_byte;
      end loop;
      return v_word;
    end function;

    -- Helper function for writing one word to a binary file.
    procedure write_word(file f : T_CHAR_FILE; word : std_logic_vector(C_WORD_SIZE-1 downto 0)) is
      variable v_char : character;
      variable v_byte : std_logic_vector(7 downto 0);
    begin
      for i in 0 to (C_WORD_SIZE/8)-1 loop
        v_byte := word(((i+1)*8)-1 downto i*8);
        v_char := character'val(to_integer(unsigned(v_byte)));
        write(f, v_char);
      end loop;
    end procedure;
  begin
    -- Clear the memory with zeros.
    for i in 0 to C_MEM_NUM_WORDS-1 loop
      v_mem_array(i) := to_word(0);
    end loop;

    -- Read the program to run from the binary file pipeline_tb_prg.bin.
    file_open(f_char_file, "pipeline/pipeline_tb_prg.bin");
    v_mem_idx := to_integer(unsigned(read_word(f_char_file)))/4;  -- Fist word = program start.
    while not endfile(f_char_file) loop
      v_mem_array(v_mem_idx) := read_word(f_char_file);
      v_mem_idx := v_mem_idx + 1;
    end loop;
    file_close(f_char_file);

    -- Reset the memory signals.
    s_mem_read_data <= (others => '0');
    s_mem_read_data_ready <= '0';

    -- Start by resetting the pipeline (to have defined signals).
    s_rst <= '1';
    s_clk <= '1';
    wait for 1 ns;
    s_clk <= '0';
    wait for 1 ns;
    s_clk <= '1';
    wait for 1 ns;
    s_rst <= '0';
    s_clk <= '0';
    wait for 1 ns;

    -- Run the program.
    for i in 0 to C_TEST_CYCLES-1 loop
      -- Positive clock flank -> we should get a PC address on the ICache interface.
      s_clk <= '1';
      wait for 0.5 ns;

      -- Read/write data to/from the memory.
      v_write_mask(31 downto 24) := (others => s_mem_byte_mask(3));
      v_write_mask(23 downto 16) := (others => s_mem_byte_mask(2));
      v_write_mask(15 downto 8) := (others => s_mem_byte_mask(1));
      v_write_mask(7 downto 0) := (others => s_mem_byte_mask(0));
      if s_mem_req = '1' then
        v_mem_idx := to_integer(unsigned(s_mem_addr));
        if v_mem_idx = 0 then
          report "Simulation finished after " & integer'image(i) & " cycles.";
          exit;
        elsif (v_mem_idx > 0) and (v_mem_idx < C_MEM_NUM_WORDS) then
          v_data := v_mem_array(v_mem_idx);
        else
          v_data := X"00000000";
        end if;
        if s_mem_we = '1' then
          v_data := (v_data and (not v_write_mask)) or (s_mem_write_data and v_write_mask);
          if (v_mem_idx >= 0) and (v_mem_idx < C_MEM_NUM_WORDS) then
            v_mem_array(v_mem_idx) := v_data;
          end if;
        else
          s_mem_read_data <= v_data;
          s_mem_read_data_ready <= '1';
        end if;
      end if;

      -- Tick the clock.
      wait for 0.5 ns;
      s_clk <= '0';
      wait for 1 ns;
    end loop;

    -- Dump the memory to the binary file /tmp/mrisc32_pipeline_tb_ram.bin.
    file_open(f_char_file, "/tmp/mrisc32_pipeline_tb_ram.bin", WRITE_MODE);
    for i in 0 to C_MEM_NUM_WORDS-1 loop
      write_word(f_char_file, v_mem_array(i));
    end loop;
    file_close(f_char_file);

    --  Wait forever; this will finish the simulation.
    assert false report "End of test" severity note;
    wait;
  end process;
end behavioral;
