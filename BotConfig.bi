Const IrcServer = "chat.freenode.net"
Const Port = "6667"

' Const IrcServer = "rechat.cloudapp.net"
' Const Port = "6665"
' Const AdminNick = "mabu"
' Const Channels = "#pikabu"
' Const MainChannel = "#pikabu"

Const LocalAddress = "0.0.0.0"
Const LocalPort = ""

Const ServerPassword = ""

#if __FB_DEBUG__ <> 0
Const BotNick = "Station922_mkv"
#else
Const BotNick = "Qubick"
#endif

Const UserString = "Qubick"
Const Description = "Irc bot written in FreeBASIC"

Const AdminNick1 = "writed"
Const AdminNick2 = "PERDOLIKS"
#if __FB_DEBUG__ <> 0
Const Channels = "#freebasic-ru"
#else
Const Channels = "#freebasic-ru,#s2ch,#reactos-ru"
#endif
Const MainChannel = "#freebasic-ru"

Const AdminRealName = "Эрик Замабувараев‐Ёмолкуу"
' Версия бота \ Версия ОС \ Процессор \ Физическая память всего
Const BotVersion = "IrcBot version 0.9.3.0 written in FreeBASIC \ Microsoft Windows "
