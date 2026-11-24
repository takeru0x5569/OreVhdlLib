-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :UART送信
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is
generic(
    TICK_CYCLE : integer := 434; --1bit当たりのサイクル数（50MHz）115200bps
    BYTE_NUM   : integer := 4    --送信バイト数
);
port(
    i_CLK       : in std_logic; --50MHz clock
    i_RST_p     : in std_logic;
    i_DATA_SET_p: in std_logic;
    i_DATA      : in std_logic_vector(BYTE_NUM*8-1 downto 0);
    o_BUSY_h    : out std_logic;
    o_UART_TX   : out std_logic
);
end entity;

architecture RTL of UART_TX is
    signal start_p    : std_logic;
    signal busy       : std_logic;
    signal frame      : std_logic_vector(BYTE_NUM*(8+2)-1 downto 0);
    signal send_tick  : std_logic;
begin

--送信dataにstart/stopビットを付加してシリアライザに渡すframeに格納
process(i_DATA)begin
for i in 0 to BYTE_NUM-1 loop
    frame(i*10+0)   <= '0';--Start bit
    frame(i*10+1)   <= i_DATA(i*8+0);
    frame(i*10+2)   <= i_DATA(i*8+1);
    frame(i*10+3)   <= i_DATA(i*8+2);
    frame(i*10+4)   <= i_DATA(i*8+3);
    frame(i*10+5)   <= i_DATA(i*8+4);
    frame(i*10+6)   <= i_DATA(i*8+5);
    frame(i*10+7)   <= i_DATA(i*8+6);
    frame(i*10+8)   <= i_DATA(i*8+7);
    frame(i*10+9)   <= '1';--Stop bit
end loop;
end process;

start_p <= i_DATA_SET_p when (busy='0') else '0';
------------------------------------------------
--ボーレートに合わせたタイミングトリガ生成
-------------------------------------------------
u_BURST_FIX_TRG_GEN:entity work.BURST_FIX_TRG_GEN
generic map
(TICK_CYCLE     =>TICK_CYCLE
,BURST_COUNT    =>BYTE_NUM*(8+2)   --(start1bit + 8bit + stop1bit)×バイト数
)port map
(i_CLK           =>i_CLK
,i_RST_p         =>i_RST_p
,i_START_p       =>start_p
,o_BUSY_h        =>busy
,o_TICK_TRG_p    =>send_tick
,o_FINISH_p      =>open
);
------------------------------------------------
-- シリアライザ
------------------------------------------------
u_SERIALIZER: entity work.SERIALIZER
generic map
(BIT_LENGTH => BYTE_NUM*(8+2)
,LSB_FIRST  => true
,INIT_VAL   => '1'
)port map
(i_CLK      => i_CLK
,i_RST_p    => i_RST_p
,i_SET_p    => start_p
,i_DATA     => frame
,i_SHIFT_p  => send_tick
,o_SHIFT_OUT=> o_UART_TX
);
--ビジー
o_BUSY_h <= busy;
end architecture;