#ifndef unicode
	#define unicode
#endif
#include once "bot.bi"
#include once "ProcessMemoryInfo.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"

' Что требуется от этого бота?
' Сидеть на канале
' Выполнять команды от пользователя на локальном компе
' Возможно, говорить что‐нибудь в чат
' Возможность говорить пользователю от имени

' Ответить на сообщение
Sub Answer(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	' Открыть файл, прочитать
	Dim hFile As HANDLE = CreateFile(@"Ответы.txt", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
	If hFile <> INVALID_HANDLE_VALUE Then
		' Найти ключевую фразу
		' Найти ответ
		' Отправить пользвателю
		CloseHandle(hFile)
	End If
End Sub

Sub ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	' Разбить текст по пробелам
	Dim WordsCount As Long = Any
	Dim Lines As WString Ptr Ptr = CommandLineToArgvW(MessageText, @WordsCount)
	
	' Справка !справка
	If lstrcmp(Lines[0], @HelpCommand) = 0 Then
		eData->objClient.SendIrcMessage(User, @AllCommand)
	End If
	
	' Выход из сети !сгинь причина выхода из сети
	If lstrcmp(Lines[0], @QuitCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrStr(MessageText, @IrcClient.WhiteSpaceString)
			eData->objClient.QuitFromServer(@w[1])
		Else
			Dim strQuitString As WString * SizeOf(WString)
			eData->objClient.QuitFromServer(@strQuitString)
		End If
		ExitProcess(0)
	End If
	
	' Смена ника !ник новыйник
	If lstrcmp(Lines[0], @NickCommand) = 0 Then
		eData->objClient.ChangeNick(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Присоединение к каналу !зайди channel
	If lstrcmp(Lines[0], @JoinCommand) = 0 Then
		eData->objClient.JoinChannel(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Отключение от канала !выйди channel причина выхода
	If lstrcmp(Lines[0], @PartCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrStr((StrStr(MessageText, @IrcClient.WhiteSpaceString))[1], @IrcClient.WhiteSpaceString)
			eData->objClient.PartChannel(Lines[1], @w[1])
		Else
			Dim strQuitString As WString * SizeOf(WString)
			eData->objClient.PartChannel(Lines[1], @strQuitString)
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Смена темы канала !тема канал новая тема канала
	If lstrcmp(Lines[0], @TopicCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrStr((StrStr(MessageText, @IrcClient.WhiteSpaceString))[1], @IrcClient.WhiteSpaceString)
			eData->objClient.ChangeTopic(Lines[1], @w[1])
		Else
			' Очистить тему
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Сырое сообщение !ну текст
	If lstrcmp(Lines[0], @RawCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrStr(MessageText, @IrcClient.WhiteSpaceString)
			eData->objClient.SendRawMessage(@w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
	End If
	
	' Сказать в чат !скажи канал текст сообщения
	If lstrcmp(Lines[0], @SayCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrStr((StrStr(MessageText, @IrcClient.WhiteSpaceString))[1], @IrcClient.WhiteSpaceString)
			eData->objClient.SendIrcMessage(Lines[1], @w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
	End If
	
	' Выполнить программу !делай "команда" "параметры"
	If lstrcmp(Lines[0], @ExecuteCommand) = 0 Then
		REM ShellExecute(0, command, filename, param, dir, show_cmd)
		If WordsCount > 2 Then
			ShellExecute(0, 0, Lines[1], Lines[2], 0, 0)
		Else
			eData->objClient.SendIrcMessage(User, @"Недостаточно параметров для запуска приложения")
		End If
	End If
	
	' Команда !символ текст
	If lstrcmp(Lines[0], @CharCommand) = 0 Then
		' Вывести в чат коды символов фразы
		' Число в строку
		' Dim strBuffer As WString * 100 = Any
		' itow(*eData->TimerCounter, @strBuffer, 10)
	End If
	
	' Команда !пинг пользователь
	If lstrcmp(Lines[0], @PingCommand) = 0 Then
		' Засечь время
		' Отправить запрос
		' Получить ответ, получить время
		' Получить разницу времени
		' Вывести в чат
	End If
	
	' Команда !процессы
	If lstrcmp(Lines[0], @ProcessesListCommand) = 0 Then
		' Показать список всех процессов
		Dim hProcessSnap As HANDLE = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		If hProcessSnap = INVALID_HANDLE_VALUE Then
			eData->objClient.SendIrcMessage(User, @"Не могу создать список процессов")
		Else
			Dim pe32 As PROCESSENTRY32 = Any
			pe32.dwSize = SizeOf(PROCESSENTRY32)
			If Process32First(hProcessSnap, @pe32) = 0 Then
				eData->objClient.SendIrcMessage(User, @"Ошибка в функции Process32First")
			Else
				Do
					' Идентификатор процесса
					Dim strProcessID As WString * 100 = Any
					itow(pe32.th32ProcessID, @strProcessID, 10)
					
					' Имя исполняемого файла
					Dim strProcessName As WString * (IrcClient.MaxBytesCount + 1) = Any
					lstrcpy(@strProcessName, @pe32.szExeFile)
					lstrcat(@strProcessName, @IrcClient.WhiteSpaceString)
					lstrcat(@strProcessName, @strProcessID)
					
					eData->objClient.SendIrcMessage(User, @strProcessName)
					SleepEx(MessageTimeWait, 0)
				Loop While Process32Next(hProcessSnap, @pe32) <> 0
			End If
			CloseHandle(hProcessSnap)
		End If
	End If
	
	' Команда !инфо ID процесса
	If lstrcmp(Lines[0], @ProcessInfoCommand) = 0 Then
		' Вывести информацию о процессе
		Dim ProcessData As ProcessMemoryInfo = Any
		If WordsCount > 1 Then
			If GetMemoryInfo(@ProcessData, wtoi(Lines[1])) Then
				Dim strCounter As WString * (IrcClient.MaxBytesCount + 1) = Any
				
				lstrcpy(@strCounter, "Ошибок страниц ")
				lstrcat(@strCounter, ProcessData.PageFaultCount)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Рабочее множество ")
				lstrcat(@strCounter, ProcessData.WorkingSetSize)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Пик рабочего множества ")
				lstrcat(@strCounter, ProcessData.PeakWorkingSetSize)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Виртуальная память ")
				lstrcat(@strCounter, ProcessData.PagefileUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Пик виртуальной памяти ")
				lstrcat(@strCounter, ProcessData.PeakPagefileUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Собственные байты ")
				lstrcat(@strCounter, ProcessData.PrivateUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
			Else
				eData->objClient.SendIrcMessage(User, @"Не могу получить информацию о процессе")
			End If
		Else
			eData->objClient.SendIrcMessage(User, @"Для отображения информации о памяти процесса нужен его ID")
		End If
	End If
	
	' Команда !жуйк текст
	If lstrcmp(Lines[0], @JuickCommand) = 0 Then
		eData->objClient.SendIrcMessage(User, @JuickCommandDone)
	End If
	
	' Сказать реальное значение ника пользователя
	
	' Игра крестики‐нолики
	
	' Игра в карты
	
	' Проверка заголовков какого‐нибудь http‐сервера
	' Выдать случайную фразу (говорящий бот)
	
	LocalFree(Lines)
End Sub

' Отправка сырого сообщения от сервера
Sub SendedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub

' Принятие сырого сообщения от сервера
Sub ReceivedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub

' Любое серверное сообщение
Function ServerMessage(ByVal AdvData As Any Ptr, ByVal ServerCode As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	If lstrcmp(ServerCode, @RPL_WELLCOME) = 0 Then
		Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
		' Присоединиться к каналам
		For i As Integer = StartChannelIndex To eData->ArgsCount - 1
			eData->objClient.JoinChannel(eData->Args[i])
		Next
	End If
	Return ResultType.None
End Function

' Сообщение с канала
Function ChannelMessage(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Здесь можно отправлять ответ на сообщение
	' Answer(eData, Channel, MessageText)
	
	' Можно искать ссылки в тексте, чтобы ходить по ним
	
	' Если сообщение начинается с ника бота, можно ответить пользователю
	
	' Можно выдать случайную фразу
	
	' Можно среагировать на точку — это пинг
	
	' Команда от админа
	If lstrcmp(User, eData->Args[AdminNickIndex]) = 0 Then
		ProcessAdminCommand(eData, Channel, MessageText)
	End If
	Return ResultType.None
End Function

' Личное сообщение
Function IrcPrivateMessage(ByVal AdvData As Any Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Ответить пользователю в чат
	Answer(eData, User, MessageText)
	
	' Команда от админа
	If lstrcmp(User, eData->Args[AdminNickIndex]) = 0 Then
		ProcessAdminCommand(eData, User, MessageText)
	End If
	Return ResultType.None
End Function

' Кто‐то присоединился к каналу
Function UserJoined(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal UserName As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Если название канала начинается с двоеточия, то убрать
	Dim wChannel As WString Ptr = Any
	If Channel[0] = 58 Then
		wChannel = @Channel[1]
	Else
		wChannel = @Channel[0]
	End If
	
	' Запросить информацию о клиенте, если это не мы
	If lstrcmp(eData->Args[NickIndex], UserName) <> 0 Then
		eData->objClient.SendCtcpMessage(UserName, CtcpMessageType.Version, 0)
	End If
	
	Return ResultType.None
End Function

' Эту функцию можно использовать как таймер с интервалом примерно 265 секунд
Function Ping(ByVal AdvData As Any Ptr, ByVal Server As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Обязательно отправляем понг как можно быстрее
	Dim strTemp As WString * (IrcClient.MaxBytesCount + 1) = Any
	lstrcpy(strTemp, IrcClient.PongStringWithSpace)
	lstrcat(strTemp, Server)
	eData->objClient.SendRawMessage(strTemp)
	
	Return ResultType.None
End Function

' Какой‐то пользователь запрашивает наши параметры
Function CtcpMessage(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal UserName As WString Ptr, ByVal MessageType As CtcpMessageType, ByVal Param As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	REM ' Сообщение CTCP
	REM ' VERSION HexChat 2.9.1 [x86] / Windows 8 [1.46GHz]
	REM ' TIME Fri 23 Nov 2012 19:26:42 EST
	REM ' PING 23152511
	Dim NoticeText As WString * (IrcClient.MaxBytesCount + 1) = Any
	Select Case MessageType
		Case CtcpMessageType.Ping
			lstrcpy(NoticeText, Param)
		Case CtcpMessageType.Time
			' Получение даты в HTTP ‐формате
			GetHttpDate(@NoticeText)
		Case CtcpMessageType.UserInfo
			lstrcpy(NoticeText, @AdminRealName)
		Case CtcpMessageType.Version
			lstrcpy(NoticeText, @OSVersion)
	End Select
	Return eData->objClient.SendCtcpNotice(FromUser, MessageType, NoticeText)
End Function

' Какой‐то пользователь отвечает на запрос о параметрах
Function CtcpNotice(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal UserName As WString Ptr, ByVal MessageType As CtcpMessageType, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	If lstrcmp(FromUser, UserName) <> 0 Then
		Select Case MessageType
			Case CtcpMessageType.Ping
				'
			Case CtcpMessageType.Time
				'
			Case CtcpMessageType.UserInfo
				'
			Case CtcpMessageType.Version
				' Нужно как‐то отобразить информацию на текущем канале
				If StartChannelIndex < eData->ArgsCount Then
					Dim strTemp As WString * (IrcClient.MaxBytesCount + 1)
					lstrcpy(@strTemp, FromUser)
					lstrcat(@strTemp, @" использует ")
					lstrcat(@strTemp, MessageText)
					eData->objClient.SendIrcMessage(eData->Args[StartChannelIndex], @strTemp)
				End If
		End Select
	End If
	REM eData->objClient.SendIrcMessage(FreeBASICruCnahhel, MessageText)
	Return ResultType.None
End Function

Sub ServerError(ByVal AdvData As Any Ptr, ByVal Message As WString Ptr)
	ExitProcess(1)
End Sub

Function EntryPoint Alias "EntryPoint"()As Integer
	' Дополнительные данные
	Dim AdvData As AdvancedData = Any
	' Массив параметров командной строки
	AdvData.Args = CommandLineToArgvW(GetCommandLine(), @AdvData.ArgsCount)
	
	If AdvData.ArgsCount > 6 Then
		' Идентификаторы ввода‐вывода
		AdvData.InHandle = GetStdHandle(STD_INPUT_HANDLE)
		AdvData.OutHandle = GetStdHandle(STD_OUTPUT_HANDLE)
		AdvData.ErrorHandle = GetStdHandle(STD_ERROR_HANDLE)
		
		' Дополнительные данные, передающиеся в каждом событии
		AdvData.objClient.ExtendedData = @AdvData
		
		' События
		AdvData.objClient.SendedRawMessageEvent = @SendedRawMessage
		AdvData.objClient.ReceivedRawMessageEvent = @ReceivedRawMessage
		AdvData.objClient.ServerMessageEvent = @ServerMessage
		AdvData.objClient.ChannelMessageEvent = @ChannelMessage
		AdvData.objClient.PrivateMessageEvent = @IrcPrivateMessage
		AdvData.objClient.CtcpMessageEvent = @CtcpMessage
		AdvData.objClient.CtcpNoticeEvent = @CtcpNotice
		AdvData.objClient.PingEvent = @Ping
		AdvData.objClient.UserJoinedEvent = @UserJoined
		AdvData.objClient.ServerErrorEvent = @ServerError
		
		' События, которые бот не обрабатывает
		' необходимо установить в NULL
		AdvData.objClient.NoticeEvent = NULL
		AdvData.objClient.UserLeavedEvent = NULL
		AdvData.objClient.NickChangedEvent = NULL
		AdvData.objClient.TopicEvent = NULL
		AdvData.objClient.UserQuitEvent = NULL
		AdvData.objClient.KickEvent = NULL
		AdvData.objClient.InviteEvent = NULL
		AdvData.objClient.DisconnectEvent = NULL
		AdvData.objClient.PongEvent = NULL
		AdvData.objClient.ModeEvent = NULL
		
		' Инициализация: сервер порт ник юзер описание
		If AdvData.objClient.OpenIrc(AdvData.Args[ServerIndex], AdvData.Args[PortIndex], AdvData.Args[LocalServerIndex], AdvData.Args[LocalPortIndex], AdvData.Args[PasswordIndex], AdvData.Args[NickIndex], AdvData.Args[UserIndex], AdvData.Args[DescriptionIndex], False) = ResultType.None Then
			' Всё идёт по плану
			Do
			Loop While AdvData.objClient.GetData() = ResultType.None
			' Закрыть
			AdvData.objClient.CloseIrc()
		End If
	Else
		' Количество аргументов меньше 6
		' выдать справку по использованию
	End If
	
	LocalFree(AdvData.Args)
	Return 0
End Function
