#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "win\shlwapi.bi"
#include once "Irc.bi"
#include once "WriteLine.bi"

' Константы команд
Const AllUserCommands1 = "справка покажи жуйк . статистика кто з пенис"
Const AllUserCommands2 = "Описание можно почитать на сайте https://github.com/BatchedFiles/Qubick/blob/master/README.md"
Const AllAdminCommands = "справка покажи жуйк . статистика кто з пенис ник зайди выйди сгинь тема скажи ну пароль делай"

Const HelpCommand1 =        "!help"
Const HelpCommand2 =        "!справка"
Const HelpCommand3 =        "!помощь"
Const ASCIICommand =        "!покажи"
Const JuickCommand =        "!жуйк"
Const ChatSayTextCommand1 = "чат, скажи: "
Const ChatSayTextCommand2 = "чат, "
Const StatsCommand =        "!статистика"
Const PingCommand =         "."
Const UserWhoIsCommand =    "!кто"
Const FenceCommand =        "!з"
Const PenisCommand =        "!пенис"

Const QuitCommand =         "!сгинь"
Const NickCommand =         "!ник"
Const JoinCommand =         "!зайди"
Const PartCommand =         "!выйди"
Const TopicCommand =        "!тема"
Const SayCommand =          "!скажи"
Const RawCommand =          "!ну"
Const ExecuteCommand =      "!делай"
Const CalculateCommand =    "!считай"
Const PasswordCommand =     "!пароль"
Const TimerCommand =        "!таймер"

Const AddQuestionCommand =  "!вопрос"
Const AddAnswerCommand =    "!ответ"
Const QuestionListCommand = "!вопросы"
Const AnswerListCommand =   "!ответы"

' Задержка между сообщениями, чтобы не выгнали за флуд
Const MessageTimeWait As Integer = 3000

Const vbCrLf = !"\r\n"

Const CommandDone = "Команда выполнена"
Const JuickCommandDone = "Отправляю на жуйкочан"

Const NickServNick = "NickServ"
Const PasswordKey = "NickServPassword"

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
	
	Dim SavedChannel As WString * (IrcClient.MaxBytesCount + 1)
	Dim SavedUser As WString * (IrcClient.MaxBytesCount + 1)
	
	Dim AdminAuthenticated As Boolean
End Type

' Количество фраз в чате по пингу
Const MaxPingChatAnswers As Integer = 2048

' Размер базы данных
Const DataBaseLength As Integer = SizeOf(Integer) + MaxPingChatAnswers * SizeOf(PingChatAnswers) + SizeOf(Integer) + SizeOf(Integer)

' Обработка команды администратора
Declare Function ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal Channel As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

' Обработка команды пользователя
Declare Function ProcessUserCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal Channel As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

' Ответить на сообщение
Declare Sub AnswerToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)

' Вопросные сообщениями
Declare Function QuestionToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

Declare Sub GetQuestionList(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr)

Declare Sub GetAnswerList(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal QuestionIndex As Integer)

Declare Sub AddQuestion(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal Question As WString Ptr)

Declare Sub AddAnswer(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal QuestionIndex As Integer, ByVal Answer As WString Ptr)
