library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package pkgTYPEDEF is
    --###########################################
    --ベクター配列
    --###########################################
    type typBit32array  is array (integer range <>) of std_logic_vector(31 downto 0);
    type typBit16array  is array (integer range <>) of std_logic_vector(15 downto 0);
    type typBit8array   is array (integer range <>) of std_logic_vector(7 downto 0);
    type typBit4array   is array (integer range <>) of std_logic_vector(3 downto 0);
    type typBit2array   is array (integer range <>) of std_logic_vector(1 downto 0);
    --###########################################
    --モーター制御
    --###########################################
    --エンコーダ信号(A相/B相)
    type typEncoder is record
        A   :std_logic;
        B   :std_logic;
    end record;
    type typEncoderArray   is array (integer range <>) of typEncoder;

    --motor drive信号(1pulse + Direction)
    type typMotorDrive is record
        CLK :std_logic;
        DIR :std_logic;
    end record;
    type typMotorDriveArray   is array (integer range <>) of typMotorDrive;
    --###########################################
    --ローカルバス
    --###########################################
    constant BUS_ADR_WIDTH : integer := 8;
    constant BUS_DAT_WIDTH : integer := 32;
    --bus master to register signals
    type typBusCommand is record
        Wr_Ena   :std_logic;
        Rd_Ena   :std_logic;
        Address  :std_logic_vector(BUS_ADR_WIDTH - 1 downto 0);
        Data     :std_logic_vector(BUS_DAT_WIDTH - 1 downto 0);
    end record;
    --データバス幅のベクターをさらに配列化
    type typRegisterArray  is array (integer range <>)
        of std_logic_vector(BUS_DAT_WIDTH - 1 downto 0);

end package;
