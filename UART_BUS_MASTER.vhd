library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.pkgTYPEDEF.all;

entity UART_BUS_MASTER is
generic(
    TICK_CYCLE :integer := 434; --1bit分のクロックサイクル数
    BIT_WIDTH  :integer := 8
    );
port(
    i_CLK           : in    std_logic;
    i_RST_p         : in    std_logic;
    i_UART_RX       : in    std_logic;
    o_UART_TX       : out   std_logic;
    o_BUS_CMD       : out   typBusCommand;
    i_BUS_ACK       : in    std_logic_vector(BUS_DAT_WIDTH-1 downto 0)
    );
end entity;

architecture RTL of UART_BUS_MASTER is
    type tMODE  is (WR,RD,NONE);
    type tSTATE is (CMD,ADR,D3,D2,D1,D0,EXE,ACK);
    signal state        :tSTATE;
    signal mode         :tMODE;
    -- signal rx_bit       :std_logic;
    -- signal rx_fall      :std_logic;
    -- signal rx_begin     :std_logic;
    -- signal rx_start     :std_logic;
    -- signal rx_tick      :std_logic;
    -- signal rx_end       :std_logic;
    signal rx_char    :std_logic_vector(7 downto 0);
    signal rx_ena     :std_logic;
    signal busy       :std_logic_vector(0 to 1);
    signal address    :std_logic_vector(BUS_ADR_WIDTH-1 downto 0);
    signal wr_data    :std_logic_vector(BUS_DAT_WIDTH-1 downto 0);
    signal wr_ena     :std_logic;
    signal rd_ena     :std_logic;
    constant WAIT_COUNT_END : integer := 10;
    signal wait_count :integer range 0 to WAIT_COUNT_END; 
    signal ack_data   :std_logic_vector(BUS_DAT_WIDTH+8-1 downto 0);
    signal tx_start_p :std_logic;
begin
------------------------------------------------
--UART受信処理
------------------------------------------------
u_UART_RX: entity work.UART_RX
generic map
(TICK_CYCLE => TICK_CYCLE
)
port map
(i_CLK      =>i_CLK
,i_RST_p    =>i_RST_p
,i_UART_RX  =>i_UART_RX
,o_DATA     =>rx_char
,o_ENABLE_p =>rx_ena
);
------------------------------------------------
--UART送信処理
------------------------------------------------
u_UART_TX: entity work.UART_TX
generic map
(TICK_CYCLE => TICK_CYCLE
,BYTE_NUM   => (BUS_DAT_WIDTH/8)+1
)
port map
(i_CLK          =>i_CLK
,i_RST_p        =>i_RST_p
,i_DATA_SET_p   =>tx_start_p
,i_DATA         =>ack_data
,o_BUSY         =>open
,o_UART_TX      =>o_UART_TX
);
tx_start_p <= rx_ena;
ack_data <= x"0A" & i_BUS_ACK;--最後に改行コード0x0Aを付ける
------------------------------------------------
--
------------------------------------------------
process(i_CLK,i_RST_p)begin
    if i_RST_p='1' then
        state   <= CMD;
        mode    <= NONE;
        address <= x"00";
        wr_data <= (others=>'0');
        wr_ena <= '0';
        rd_ena <= '0';
        wait_count <= 0;
    elsif rising_edge(i_CLK) then
        if(rx_ena='0')then
            wr_ena <= '0';
            rd_ena <= '0';
        else
            case state is
                when CMD =>
                    if rx_char = x"77" then
                        mode  <= WR;
                        state <= ADR;
                    elsif rx_char = x"72" then
                        mode <= RD;
                        state <= ADR;
                    end if;
                    wait_count <= 0;
                --▼アドレス受信
                when ADR =>
                    address <= rx_char;
                    if mode = WR then
                        state <= D0;
                    elsif mode = RD then
                        state <= EXE;
                    end if;
                --▼データ受信
                when D0 =>
                    wr_data(7 downto 0) <= rx_char;
                    state <= D1;
                when D1 =>
                    wr_data(15 downto 8) <= rx_char;
                    state <= D2;
                when D2 =>
                    wr_data(23 downto 16) <= rx_char;
                    state <= D3;
                when D3 =>
                    wr_data(31 downto 24) <= rx_char;
                    state <= EXE;
            --▼実行
            when EXE =>
                if rx_char = x"0A" then --LF改行(0x0A)
                    if mode = WR then
                        wr_ena <= '1';--書き込みはアサート一発投げて終了
                        state <= CMD;
                    elsif mode = RD then
                        rd_ena <= '1';
                        state <= ACK;
                    else
                        state <= CMD;
                    end if ;
                end if;
            --▼読み出し応答待ち
            when ACK =>
                wait_count <= wait_count+1;
                if(wait_count = WAIT_COUNT_END)then
                    state <= CMD;
                    rd_ena <= '0';
                end if;
            when others =>
                null;
            end case;
        end if;
    end if;
end process;

o_BUS_CMD.Wr_Ena    <= wr_ena;
o_BUS_CMD.Rd_Ena    <= rd_ena;
o_BUS_CMD.Address   <= address;
o_BUS_CMD.Data      <= wr_data;


end architecture;