﻿#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"
#include once "win\shellapi.bi"
#include once "win\shlwapi.bi"
#include once "Irc.bi"
#include once "WriteLine.bi"

' Константы команд
Const AllAdminCommands = "справка покажи жуйк"
Const AllUserCommands = "справка покажи жуйк ник зайди выйди сгинь тема скажи ну делай память процессы пароль"
' Выход из сети
Const QuitCommand = "!сгинь"
' Сменить ник
Const NickCommand = "!ник"
' Зайти на канал
Const JoinCommand = "!зайди"
' Покинуть канал
Const PartCommand = "!выйди"
' Сменить тему
Const TopicCommand = "!тема"
' Сказать в чат
Const SayCommand = "!скажи"
' Сказать сырую команду
Const RawCommand = "!ну"
' Выполнить на сервере файл
Const ExecuteCommand = "!делай"
' Показать список команд
Const HelpCommand = "!справка"
' Отправить фразу на жуйк
Const JuickCommand = "!жуйк"
' Показать использование памяти процесса
Const ProcessInfoCommand = "!память"
' Показать список процессов
Const ProcessesListCommand = "!процессы"
' Вычислить выражение
Const CalculateCommand = "!считай"
' Графика ASCII
Const ASCIICommand = "!покажи"
' Пароль для никсерва
Const PasswordCommand = "!пароль"

' Добавить ключевую фразу для реагирования
Const AddQuestionCommand = "!вопрос"
' Добавить ответ
Const AddAnswerCommand = "!ответ"
' Показать список ключевых фраз
Const QuestionListCommand = "!вопросы"
' Показать список ответов
Const AnswerListCommand = "!ответы"

' Задержка между сообщениями, чтобы не выгнали за флуд
Const MessageTimeWait As Integer = 3000

Const vbCrLf = !"\r\n"

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
	
End Type

' Количество фраз в чате по пингу
Const MaxPingChatAnswers As Integer = 2048

' Размер базы данных
Const DataBaseLength As Integer = SizeOf(Integer) + MaxPingChatAnswers * SizeOf(PingChatAnswers) + SizeOf(Integer) + SizeOf(Integer)

' Обработка команды администратора
Declare Function ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

' Обработка команды пользователя
Declare Function ProcessUserCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

' Ответить на сообщение
Declare Sub AnswerToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)

' Вопросные сообщениями
Declare Function QuestionToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean

Declare Sub GetQuestionList(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr)

Declare Sub GetAnswerList(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal QuestionIndex As Integer)

Declare Sub AddQuestion(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal Question As WString Ptr)

Declare Sub AddAnswer(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal QuestionIndex As Integer, ByVal Answer As WString Ptr)
