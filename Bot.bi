#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "win\shlwapi.bi"
#include once "Irc.bi"
#include once "WriteLine.bi"

Declare Function itow cdecl Alias "_itow" (ByVal Value As Integer, ByVal src As WString Ptr, ByVal radix As Integer)As WString Ptr
Declare Function ltow cdecl Alias "_ltow" (ByVal Value As Long, ByVal src As WString Ptr, ByVal radix As Integer)As WString Ptr
Declare Function wtoi cdecl Alias "_wtoi" (ByVal src As WString Ptr)As Integer
Declare Function wtol cdecl Alias "_wtol" (ByVal src As WString Ptr)As Long

REM имя_екзешника сервер порт пароль ник пользователь описание ник_админа каналы
Const ServerIndex As Integer = 1
Const PortIndex As Integer = 2
Const LocalServerIndex As Integer = 3
Const LocalPortIndex As Integer = 4
Const PasswordIndex As Integer = 5
Const NickIndex As Integer = 6
Const UserIndex As Integer = 7
Const DescriptionIndex As Integer = 8
Const AdminNickIndex As Integer = 9
' Индекс, с которого начинается отсчёт каналов в параметрах программы
Const StartChannelIndex As Integer = 10

' Константы команд
Const AllCommand = "ник зайди выйди сгинь тема скажи ну делай справка память процессы"
Const QuitCommand = "!сгинь"
Const NickCommand = "!ник"
Const JoinCommand = "!зайди"
Const PartCommand = "!выйди"
Const TopicCommand = "!тема"
Const SayCommand = "!скажи"
Const RawCommand = "!ну"
Const ExecuteCommand = "!делай"
Const HelpCommand = "!справка"
Const JuickCommand = "!жуйк"
Const ProcessInfoCommand = "!память"
Const ProcessesListCommand = "!процессы"
Const CalculateCommand = "!считай"

' Задержка между сообщениями, чтобы не выгнали за флуд
Const MessageTimeWait As Integer = 5000

' Создать файл, который можно компилировать
' Добавить в него текст
' скомпилировать
' вывести результат компиляции в чат
' запустить и вывести результат в чат

' Не реализовано
Const CharCommand = "символ"
Const PingCommand = "пинг"

' Добавляет в исходник текст для компиляции
Const StartSourceCommand = "исходник"
' Компилирует исходник и выводит результат в чат
Const EndSourceCommand = "компилируй"
' Запускает исходник и выводит результат в чат
Const DoSourceCommand = "запускай"
' Очищает исходник
Const ClearSourceCommand = "чисть"

' Команда выполнена
Const CommandDone = "Команда выполнена"
Const JuickCommandDone = "Отправляю на жуйкочан"

Const AdminRealName = "Эрик Замабувараев‐Ёмолкуу"
Const OSVersion = "Bot version 20 written in FreeBASIC / Microsoft Windows Server 2003 R2 Standard x64 Edition Service Pack 2 Intel Xeon CPU 2.20GHz 512 RAM"

Declare Function ThreadFunction(ByVal lpParam As LPVOID)As DWORD
Declare Function EntryPoint Alias "EntryPoint"()As Integer

' Фраза в чате по пингу
Type PingChatAnswers
	Dim Answer As WString * (IrcClient.MaxBytesCount + 1)
End Type

' Дополнительные данные, связанные с клиентом
' Будут передаваться в каждом событии
Type AdvancedData
	Const StaticBufferSize As Integer = 32000
	' Клиент
	Dim objClient As IrcClient
	
	' Консольные указатели
	Dim InHandle As Handle
	Dim OutHandle As Handle
	Dim ErrorHandle As Handle
	
	' Параметры командной строки
	Dim Args As WString Ptr Ptr
	Dim ArgsCount As Long ' Количество
	
End Type

' Количество фраз в чате по пингу
Const MaxPingChatAnswers As Integer = 2048

' Размер базы данных
Const DataBaseLength As Integer = SizeOf(Integer) + MaxPingChatAnswers * SizeOf(PingChatAnswers) + SizeOf(Integer) + SizeOf(Integer)

' Обработка команды администратора
Declare Sub ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)

' Ответить на сообщение
Declare Sub AnswerToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
