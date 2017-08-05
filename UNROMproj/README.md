# UNROMproj
## [RUS]
Данный проект представляет собой реализацию Dendy/Famicom картриджа использующего UNROM маппер, номер 002 согласно iNES.

### Структура проекта
Имя файла                                               | Содержание файла
--------------------------------------------------------|----------------------------------------------------------------------------
UNROM_quartus                                           | Откомпилированный Quartus проект
UNROMproj/UNROM_quartus/output_files/UNROM_mst.sof      | Файл конфигурации ПЛИС для загрузки по JTAG
UNROMproj/UNROM_quartus/output_files/UNROM_mstFlash.jic | Файл конфигурации ПЛИС для записи во Flash-память (чип EPCS16)
README.md                                               | Тот самый файл с описанием проекта, который вы сейчас и читаете

## [ENG]
It is implementation a Dendy/Famicom cartridge based on UNROM mapper, iNES number 002.

### The project structure
File name                                               | File description
--------------------------------------------------------|----------------------------------------------------------------------------
UNROM_quartus                                           | Compiled Qaurtus project
UNROMproj/UNROM_quartus/output_files/UNROM_mst.sof      | FPGA configuration for JTAG loading
UNROMproj/UNROM_quartus/output_files/UNROM_mstFlash.jic | FPGA configuration for FLASH loading (EPCS16 chip)
README.md                                               | Project documentation
