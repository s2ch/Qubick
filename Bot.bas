#ifndef unicode
	#define unicode
#endif
#include once "bot.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"
#include once "IrcReplies.bi"
#include once "IrcEvents.bi"

' Что требуется от этого бота?
' Сидеть на канале
' Выполнять команды от пользователя на локальном компе
' Возможно, говорить что‐нибудь в чат
' Возможность говорить пользователю от имени

' Отправка сырого сообщения на сервер
Sub SendedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub

' Принятие сырого сообщения от сервера
Sub ReceivedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub

' Любое серверное сообщение
Function ServerMessage(ByVal AdvData As Any Ptr, ByVal ServerCode As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	If lstrcmp(ServerCode, @RPL_WELCOME) = 0 Then
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
	AnswerToChat(eData, User, MessageText)
	
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
	
	' Идентификаторы ввода‐вывода
	AdvData.InHandle = GetStdHandle(STD_INPUT_HANDLE)
	AdvData.OutHandle = GetStdHandle(STD_OUTPUT_HANDLE)
	AdvData.ErrorHandle = GetStdHandle(STD_ERROR_HANDLE)
	
	If AdvData.ArgsCount > 6 Then
		
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
		WriteLine(AdvData.OutHandle, @HowToUseHelpMessage)
	End If
	
	LocalFree(AdvData.Args)
	Return 0
End Function
