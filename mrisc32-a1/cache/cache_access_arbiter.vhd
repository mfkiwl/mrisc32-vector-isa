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
use work.common.all;


----------------------------------------------------------------------------------------------------
-- This entity arbitrates memory access requests from the ICache and the DCache.
----------------------------------------------------------------------------------------------------

entity cache_access_arbiter is
  port(
      -- (ignored)
      i_clk : in std_logic;
      i_rst : in std_logic;

      -- ICache interface.
      i_icache_req : in std_logic;
      i_icache_addr : in T_CACHE_LINE_ADDR;
      o_icache_read_addr : out T_CACHE_LINE_ADDR;
      o_icache_read_data : out T_CACHE_LINE_DATA;
      o_icache_read_data_ready : out std_logic;

      -- DCache interface.
      i_dcache_req : in std_logic;
      i_dcache_we : in std_logic;
      i_dcache_addr : in T_CACHE_LINE_ADDR;
      i_dcache_write_data : in T_CACHE_LINE_DATA;
      o_dcache_read_addr : out T_CACHE_LINE_ADDR;
      o_dcache_read_data : out T_CACHE_LINE_DATA;
      o_dcache_read_data_ready : out std_logic;

      -- Memory interface.
      -- TODO(m): This should be a DRAM controller or something.
      o_mem_req : out std_logic;
      o_mem_we : out std_logic;
      o_mem_addr : out T_CACHE_LINE_ADDR;
      o_mem_write_data : out T_CACHE_LINE_DATA;
      i_mem_read_addr : in T_CACHE_LINE_ADDR;
      i_mem_read_data : in T_CACHE_LINE_DATA;
      i_mem_read_data_ready : in std_logic
    );
end cache_access_arbiter;

architecture rtl of cache_access_arbiter is
  signal s_service_dcache : std_logic;
begin
  -- The DCache has priority over the ICache.
  s_service_dcache <= i_dcache_req;

  -- Send the request to the RAM from either the ICache or DCache.
  o_mem_req <= i_icache_req or i_dcache_req;
  o_mem_we <= i_dcache_we and s_service_dcache;
  o_mem_addr <= i_dcache_addr when s_service_dcache = '1' else i_icache_addr;
  o_mem_write_data <= i_dcache_write_data;

  -- Send the result to the relevant cache, and optionally stall the cache(s) when waiting for read data.
  o_icache_read_addr <= i_mem_read_addr;
  o_icache_read_data <= i_mem_read_data;
  o_icache_read_data_ready <= i_mem_read_data_ready and i_icache_req and not s_service_dcache;
  o_dcache_read_addr <= i_mem_read_addr;
  o_dcache_read_data <= i_mem_read_data;
  o_dcache_read_data_ready <= i_mem_read_data_ready and i_dcache_req and (not i_dcache_we) and s_service_dcache;
end rtl;
