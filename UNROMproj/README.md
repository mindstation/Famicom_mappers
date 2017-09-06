# UNROMproj
## [RUS]

Данный проект представляет собой реализацию Dendy/Famicom картриджа использующего UNROM маппер, номер 002 согласно iNES.

Принципиальная схема картриджа также доступна в EasyEDA: [UNROM cart scheme](https://easyeda.com/editor#id=b25b2193f7914e0da3a9895ea4b576b6)

### Структура проекта

Имя файла                                               | Содержание файла
--------------------------------------------------------|----------------------------------------------------------------------------
UNROM_quartus                                           | Откомпилированный Quartus проект
UNROMproj/UNROM_quartus/output_files/UNROM_mst.sof      | Файл конфигурации ПЛИС для загрузки по JTAG
UNROMproj/UNROM_quartus/output_files/UNROM_mstFlash.jic | Файл конфигурации ПЛИС для записи во Flash-память (чип EPCS16)
README.md                                               | Тот самый файл с описанием проекта, который вы сейчас и читаете
UNROM-cart-scheme.pdf                                   | Принципиальная схема картриджа

### Список компонентов

PRG_ROM AM29F010B-90                 1шт

Logic Level Converter SN74LVC244ADBR 1шт

CHR_RAM 6264A-12                     1шт

Керамический конденсатор 0,1 мкФ     3шт

P2 Mirroring HDR-3X1/2.54            1шт

## [ENG]

It is implementation a Dendy/Famicom cartridge based on UNROM mapper, iNES number 002.

The cartridge scheme also available at EasyEDA: [UNROM cart scheme](https://easyeda.com/editor#id=b25b2193f7914e0da3a9895ea4b576b6)

### The project structure

File name                                               | File description
--------------------------------------------------------|----------------------------------------------------------------------------
UNROM_quartus                                           | Compiled Qaurtus project
UNROMproj/UNROM_quartus/output_files/UNROM_mst.sof      | FPGA configuration for JTAG loading
UNROMproj/UNROM_quartus/output_files/UNROM_mstFlash.jic | FPGA configuration for FLASH loading (EPCS16 chip)
README.md                                               | Project documentation
UNROM-cart-scheme.pdf                                   | The cartridge scheme

### BOM

PRG_ROM AM29F010B-90                 1 piece

Logic Level Converter SN74LVC244ADBR 1 piece

CHR_RAM 6264A-12                     1 piece

Capacitor 0,1u                       3 pieces

P2 Mirroring HDR-3X1/2.54            1 piece
