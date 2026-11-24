-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :ローカルバスレジスタ
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.pkgTYPEDEF.all;

entity LOCAL_BUS_REGISTER is
    generic(
    REG_ADDRESS_BASE    :std_logic_vector(3 downto 0)  := x"0";
    REG_NUMBER          :integer := 16
    );
    port(
    i_CLK           :in  std_logic;
    i_RST_p         :in  std_logic;
    i_BUS_CMD       :in  typBusCommand;
    o_BUS_ACK       :out std_logic_vector(BUS_DAT_WIDTH-1 downto 0);
    o_BUS_REG       :typRegisterArray(0 to 1)
    );
end entity;

architecture RTL of LOCAL_BUS_REGISTER is
    signal fix_base_adr     :std_logic;
    signal adr_offset       :std_logic_vector(3 downto 0);
    signal ack_data         :std_logic_vector(BUS_DAT_WIDTH-1 downto 0);
    signal reg_array        :typRegisterArray(0 to 1);
begin----------------------------------------------------------------------
--ベースアドレス一致(上位4bitの一致確認)
fix_base_adr <= '1' when i_BUS_CMD.Address(7 downto 4) = REG_ADDRESS_BASE else '0';
--オフセットアドレス(下位4bit取り出し)
adr_offset  <= i_BUS_CMD.Address(3 downto 0);
--レジスタ書込み
process(i_CLK, i_RST_p)begin
    if(i_RST_p='1')then
        reg_array      <=(others=>(others=>'0'));
    elsif rising_edge(i_CLK) then
        if(i_BUS_CMD.Wr_Ena='1' and fix_base_adr='1')then
            case(adr_offset)is
                when x"0" =>--
                    reg_array(0)   <= i_BUS_CMD.Data;
                when others => null;
            end case;
        end if;
    end if;
end process;
--レジスタ読み出し応答：通常ハイインピーダンスでアドレス一致したら応答
process(i_CLK, i_RST_p)begin
    if(i_RST_p='1')then
        ack_data   <= (others => 'Z');
    elsif rising_edge(i_CLK) then
        if(i_BUS_CMD.Rd_Ena='1' and fix_base_adr='1')then
            case(adr_offset)is
                when x"0" => 
                    ack_data <= reg_array(0);
                when others =>
                    ack_data <= (others => 'Z');
            end case;
        else
            ack_data <= (others => 'Z');
        end if;
    end if;
end process;

o_BUS_ACK <= ack_data;
end architecture;
