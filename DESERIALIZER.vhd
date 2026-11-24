-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :デシリアライザ(シリパラ変換)
---------------------------------------------------------------------
--i_SHIFT_pのアサートでシフト。i_POP_pアサートでパラレル出力更新
library ieee;
use ieee.std_logic_1164.all;

entity DESERIALIZER is
generic(
    BIT_WIDTH :integer := 8;
    LSB_FIRST :boolean := true
    );
Port(
    i_CLK     :in  std_logic;
    i_RST_p   :in  std_logic;
    i_SERIAL  :in  std_logic;--シリアル入力
    i_SHIFT_p :in  std_logic;--シフト命令
    i_POP_p   :in  std_logic;--取得命令
    o_ENA_p   :out std_logic;--
    o_PARALLEL:out std_logic_vector(BIT_WIDTH-1 downto 0)
    );
end entity;

architecture RTL of DESERIALIZER is
    signal buf      :std_logic_vector(BIT_WIDTH-1 downto 0);
    signal parallel :std_logic_vector(BIT_WIDTH-1 downto 0);
    signal ena_p    :std_logic;
begin ---------------------------------------------------------------------
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        buf      <=(others=>'0');
        parallel <= (others=>'0');
        ena_p    <= '0';
    elsif(rising_edge(i_CLK))then
        if(i_POP_p='1')then
            ena_p    <='1';
            parallel <=buf;
        else
            ena_p <= '0';
            if(i_SHIFT_p='1')then
                if(LSB_FIRST)then
                    buf <= i_SERIAL & buf(BIT_WIDTH-1 downto 1);--LSBファースト
                else
                    buf <= buf(BIT_WIDTH-2 downto 0) & i_SERIAL;--MSBファースト
                end if;
            end if;
        end if;
    end if;
end process;

--出力
o_PARALLEL <= parallel;
o_ENA_p <= ena_p;

end architecture;
