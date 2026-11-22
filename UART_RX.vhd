--UARTの受信モジュール
--8bit,パリティなし、ストップ1bit、ボーレート115200
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity UART_RX is
generic(
    TICK_CYCLE :integer := 434; --1bit分のクロックサイクル数
    BIT_WIDTH  :integer := 8
    );
port(
    i_CLK           : in    std_logic;
    i_RST_p         : in    std_logic;
    i_UART_RX       : in    std_logic;
    o_DATA          : out   std_logic_vector(BIT_WIDTH-1 downto 0);
    o_ENABLE_p      : out   std_logic
    );
end entity;

architecture RTL of UART_RX is
    signal rx_bit       :std_logic;
    signal rx_fall      :std_logic;
    signal rx_start     :std_logic;
    signal rx_tick      :std_logic;
    signal rx_end       :std_logic;
    signal rx_frame     :std_logic_vector(BIT_WIDTH-1 downto 0);
    signal rx_ena       :std_logic;
    signal busy         :std_logic_vector(0 to 1);
begin
-------------------------------------------------
--同期化FF＆立下り検出
-------------------------------------------------
u_SYNCHRO_DFF:entity work.SYNCHRO_DFF
port map
(i_CLK     =>i_CLK
,i_RST_p   =>i_RST_p
,i_PORT    =>i_UART_RX
,o_SYNCHRO =>rx_bit
,o_RISE_p  =>open
,o_FALL_p  =>rx_fall
);
-------------------------------------------------
--ディレイライン
-------------------------------------------------
u_FIX_DELAY_LINE:entity work.FIX_DELAY_LINE
generic map
(DELAY_CYCLE => 217
)port map
(i_CLK     =>i_CLK
,i_RST_p   =>i_RST_p
,i_SOURCE_p=>rx_fall
,o_DELAY_p =>rx_start
,o_BUSY_h  =>busy(0)
);
------------------------------------------------
--サンプルタイミングトリガ生成
-------------------------------------------------
u_BURST_FIX_TRG_GEN:entity work.BURST_FIX_TRG_GEN
generic map
(TICK_CYCLE      =>TICK_CYCLE
,BURST_COUNT     =>BIT_WIDTH+2   --start 1[bit] + data 8[bit] + stop 1[bit]
)port map
(i_CLK           =>i_CLK
,i_RST_p         =>i_RST_p
,i_START_p       =>rx_start
,o_BUSY_h        =>busy(1)
,o_TICK_TRG_p    =>rx_tick
,o_FINISH_p      =>rx_end
);
------------------------------------------------
--デシリアライザ
------------------------------------------------
u_DESERIALIZER:entity work.DESERIALIZER
generic map
(BIT_WIDTH => BIT_WIDTH,
LSB_FIRST => true
)port map
(i_CLK      => i_CLK
,i_RST_p    => i_RST_p
,i_SERIAL   => rx_bit
,i_SHIFT_p  => rx_tick
,i_POP_p    => rx_end
,o_ENA_p    => rx_ena
,o_PARALLEL => rx_frame
);

o_DATA <= rx_frame;
o_ENABLE_p <= rx_ena;

end architecture;