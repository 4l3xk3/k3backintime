RU

Программа для отката установленных обновлений для AstraLinux, Debian, Ubuntu

Программа сама ничего не откатывает а создает файл сценарий по которому будет предложен пользователю сценарий отката.

в /etc/apt/sources.list должны быть подключены 2 источника: 

репозиторий который использовался до обновлений и репозиторий с которого были установлены обновления (например stable и testing, или stable и sid)

для Смоленска:
это диск из поставки и диск с обновлениями 
(если использовался диск со средствами разработки то + еще 2 диска со средствами разработки, оригинальный диск со средствами разработки и диск со средствами разработки для апдейта)

EN

Program for uninstall unsuccesfull upgrades for Astra, Debian and Ubuntu based systems

Program doesn't do any uninstall by itself, but only creates script which when run ask user to check and agree with changes.

in /etc/apt/sources.list must be connected 2 sources:

repository used before updates and repository used for updates
for example stable and testing repository, or stable and sid

Minsk SE Edition:
You must connect original disk and update disk


If devel disk used on system, you must connect also 2 devel disks:

original devel disk and devel disk from update


Author: 

Alexey Kovin <4l3xk3@gmail.com>
Alexey Kovin <akovin@astralinux.ru>

All rights reserved

Russia, Electrostal, 2019

