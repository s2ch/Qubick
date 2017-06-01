﻿#ifndef unicode
	#define unicode
#endif
#include once "bot.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"
#include once "IrcReplies.bi"
#include once "IrcEvents.bi"
#include once "BotConfig.bi"

Const ColorWhite = "00"
Const ColorBlack = "01"
Const ColorBlue = "02"
Const ColorGreen = "03"
Const ColorLightRed = "04"
Const ColorBrown = "05"
Const ColorPurple = "06"
Const ColorOrange = "07"
Const ColorYellow = "08"
Const ColorLightGreen = "09"
Const ColorCyan = "10"
Const ColorLightCyan = "11"
Const ColorLightBlue = "12"
Const ColorPink = "13"
Const ColorGrey = "14"
Const ColorLightGrey = "15"

' Сообщение с канала
Function ChannelMessage(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Dim strTemp As WString * (IrcClient.MaxBytesCount + 1) = Any
	
	' strTemp[0] = 3
	' lstrcpy(@strTemp[1], ColorWhite)
	' lstrcpy(@strTemp, "14Мы всегда рады видеть Вас. Приятного общения! :: 14Список команд: 06!хелп :: 14Случайная команда: 06!гугл :: 14Сегодня вы 074014-й посетитель, а за 05489 14дней вы зашли 061 14раз и стали06 2831814-м посетителем канала 05#pikabu14! :: 14Ваша карма: 060 :: 14Включена защита от 04мата14!")
	' Dim intLen As Integer = lstrlen(@strTemp)
	' strTemp[intLen] = 3
	' strTemp[intLen + 1] = 0
	
	' eData->objClient.SendIrcMessage(@MainChannel, @strTemp)
	
	
	' Вопросное сообщение
	If QuestionToChat(eData, Channel, MessageText) Then
		Return ResultType.None
	End If
	
	' Здесь можно отправлять ответ на сообщение
	AnswerToChat(eData, Channel, MessageText)
	
	' Можно искать ссылки в тексте, чтобы ходить по ним
	
	' Если сообщение начинается с ника бота, можно ответить пользователю
	
	' Можно среагировать на точку — это пинг
	
	' Команды пользователя
	ProcessUserCommand(eData, Channel, MessageText)
	
	' Команда от админа
	' If lstrcmp(User, @AdminNick) = 0 Then
		' If ProcessAdminCommand(eData, Channel, MessageText) Then
			' Return ResultType.None
		' End If
	' End If
	
	Return ResultType.None
End Function

' Личное сообщение
Function IrcPrivateMessage(ByVal AdvData As Any Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Вопросное сообщение
	If QuestionToChat(eData, User, MessageText) Then
		Return ResultType.None
	End If
	
	' Ответить пользователю в чат
	AnswerToChat(eData, User, MessageText)
	
	' Команды пользователя
	ProcessUserCommand(eData, User, MessageText)
	
	' Команда от админа
	If lstrcmp(User, AdminNick) = 0 Then
		If ProcessAdminCommand(eData, User, MessageText) Then
			Return ResultType.None
		End If
	End If
	
	Return ResultType.None
End Function

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
		' Режим запрета приёма личных сообщений от незарегистрированных пользователей
		Dim strMode As WString * (IrcClient.MaxBytesCount + 1) = Any
		lstrcpy(@strMode, "MODE ")
		lstrcat(@strMode, @BotNick)
		lstrcat(@strMode, " +R")
		
		' Присоединиться к каналам
		eData->objClient.JoinChannel(Channels)
		' Режим
		eData->objClient.SendRawMessage(@strMode)
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
	If lstrcmp(@BotNick, UserName) <> 0 Then
		eData->objClient.SendCtcpMessage(UserName, CtcpMessageType.Version, 0)
	End If
	
	Return ResultType.None
End Function

' Эту функцию можно использовать как таймер с интервалом примерно 265 секунд
Function Ping(ByVal AdvData As Any Ptr, ByVal Server As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Обязательно отправляем понг как можно быстрее
	Return eData->objClient.SendPong(Server)
	
End Function

' Какой‐то пользователь запрашивает наши параметры
Function CtcpMessage(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal UserName As WString Ptr, ByVal MessageType As CtcpMessageType, ByVal Param As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	REM ' Запрос CTCP
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
				Dim strTemp As WString * (IrcClient.MaxBytesCount + 1)
				lstrcpy(@strTemp, FromUser)
				lstrcat(@strTemp, @" использует ")
				lstrcat(@strTemp, MessageText)
				eData->objClient.SendIrcMessage(@MainChannel, @strTemp)
		End Select
	End If
	Return ResultType.None
End Function

#ifdef service
Function ServiceProc(ByVal lpParam As LPVOID)As DWORD
#else
Function EntryPoint Alias "EntryPoint"()As Integer
#endif
	' Дополнительные данные
	Dim AdvData As AdvancedData = Any
	
	' Идентификаторы ввода‐вывода
	AdvData.InHandle = GetStdHandle(STD_INPUT_HANDLE)
	AdvData.OutHandle = GetStdHandle(STD_OUTPUT_HANDLE)
	AdvData.ErrorHandle = GetStdHandle(STD_ERROR_HANDLE)
	
	' Дополнительные данные, передающиеся в каждом событии
	AdvData.objClient.ExtendedData = @AdvData
	' Кодировка
	AdvData.objClient.CodePage = CP_UTF8
	
	' События
#ifdef service
	AdvData.objClient.SendedRawMessageEvent = NULL
	AdvData.objClient.ReceivedRawMessageEvent = NULL
#else
	AdvData.objClient.SendedRawMessageEvent = @SendedRawMessage
	AdvData.objClient.ReceivedRawMessageEvent = @ReceivedRawMessage
#endif
	AdvData.objClient.ServerMessageEvent = @ServerMessage
	AdvData.objClient.ChannelMessageEvent = @ChannelMessage
	AdvData.objClient.PrivateMessageEvent = @IrcPrivateMessage
	AdvData.objClient.CtcpMessageEvent = @CtcpMessage
	AdvData.objClient.CtcpNoticeEvent = @CtcpNotice
	AdvData.objClient.UserJoinedEvent = @UserJoined
	
	' События, которые бот не обрабатывает
	' необходимо установить в NULL
	AdvData.objClient.ServerErrorEvent = NULL
	AdvData.objClient.PingEvent = NULL
	AdvData.objClient.NoticeEvent = NULL
	AdvData.objClient.UserLeavedEvent = NULL
	AdvData.objClient.NickChangedEvent = NULL
	AdvData.objClient.TopicEvent = NULL
	AdvData.objClient.QuitEvent = NULL
	AdvData.objClient.KickEvent = NULL
	AdvData.objClient.InviteEvent = NULL
	AdvData.objClient.PongEvent = NULL
	AdvData.objClient.ModeEvent = NULL
	
	' Инициализация случайных чисел
	Dim dtNow As SYSTEMTIME = Any
	GetSystemTime(@dtNow)
	srand(dtNow.wMilliseconds - dtNow.wSecond + dtNow.wMinute + dtNow.wHour)
	
#ifdef service
	Do
#endif
		' Инициализация: сервер порт ник юзер описание
		If AdvData.objClient.OpenIrc(@IrcServer, @Port, @LocalAddress, @LocalPort, @ServerPassword, @BotNick, @UserString, @Description, False) = ResultType.None Then
			' Всё идёт по плану
			
			' Получение данных от сервера и разбор данных
			Dim strReceiveBuffer As WString * (IrcClient.MaxBytesCount + 1) = Any
			Dim intResult As ResultType = Any
			Do
				If AdvData.objClient.ReceiveData(@strReceiveBuffer) <> ResultType.None Then
					Exit Do
				End If
				intResult = AdvData.objClient.ParseData(@strReceiveBuffer)
			Loop While intResult = ResultType.None
			' Закрыть
			AdvData.objClient.CloseIrc()
		End If
#ifdef service
		Sleep_(60 * 1000)
	Loop
#endif
	
	Return 0
End Function
