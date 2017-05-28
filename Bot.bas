#ifndef unicode
	#define unicode
#endif
#include once "bot.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"
#include once "IrcReplies.bi"
#include once "IrcEvents.bi"

Const IrcServer = "chat.freenode.net"
Const Port = "6667"
Const LocalAddress = "0.0.0.0"
Const LocalPort = ""

Const ServerPassword = ""
Const BotNick = "Qubick"
Const UserString = "FreeBASIC"
Const Description = "Irc bot written in FreeBASIC"
Const AdminNick = "writed"
Const Channels = "##freebasic-ru,#s2ch"
Const MainChannel = "##freebasic-ru"

' Сообщение с канала
Function ChannelMessage(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As ResultType
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Вопросное сообщение
	If QuestionToChat(eData, Channel, MessageText) Then
		Return ResultType.None
	End If
	
	' Здесь можно отправлять ответ на сообщение
	AnswerToChat(eData, Channel, MessageText)
	
	' Можно искать ссылки в тексте, чтобы ходить по ним
	
	' Если сообщение начинается с ника бота, можно ответить пользователю
	
	' Можно среагировать на точку — это пинг
	
	' Команда от админа
	If lstrcmp(User, @AdminNick) = 0 Then
		ProcessAdminCommand(eData, Channel, MessageText)
	End If
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
	
	' Команда от админа
	If lstrcmp(User, AdminNick) = 0 Then
		ProcessAdminCommand(eData, User, MessageText)
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
		' Присоединиться к каналам
		eData->objClient.JoinChannel(Channels)
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
	AdvData.objClient.DisconnectEvent = NULL
	AdvData.objClient.PongEvent = NULL
	AdvData.objClient.ModeEvent = NULL
	
	' Инициализация случайных чисел
	Dim dtNow As SYSTEMTIME = Any
	GetSystemTime(@dtNow)
	srand(dtNow.wMilliseconds - dtNow.wSecond + dtNow.wMinute + dtNow.wHour)
	
	Do
		' Инициализация: сервер порт ник юзер описание
		If AdvData.objClient.OpenIrc(@IrcServer, @Port, @LocalAddress, @LocalPort, @ServerPassword, @BotNick, @UserString, @Description, False) = ResultType.None Then
			' Всё идёт по плану
			
			' Получение данных от сервера и разбор данных
			Dim strReceiveBuffer As WString * (IrcClient.MaxBytesCount + 1) = Any
			Dim intResult As ResultType = Any
			Do
				intResult = AdvData.objClient.ReceiveData(@strReceiveBuffer)
				intResult = AdvData.objClient.ParseData(@strReceiveBuffer)
			Loop While intResult = ResultType.None
			' Закрыть
			AdvData.objClient.CloseIrc()
		End If
		Sleep_(60 * 1000)
	Loop
	
	Return 0
End Function
