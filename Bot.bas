#ifndef unicode
	#define unicode
#endif
#include once "bot.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"
#include once "IrcReplies.bi"
#include once "IrcEvents.bi"
#include once "BotConfig.bi"
#include once "IntegerToWString.bi"
#include once "Settings.bi"

Sub ChannelMessage(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	
	' Команды пользователя
	ProcessUserCommand(CPtr(AdvancedData Ptr, AdvData), User, Channel, MessageText)
	
	' Добавление статистики
	IncrementUserWords(Channel, User)
	
	' Вопросное сообщение
	If QuestionToChat(CPtr(AdvancedData Ptr, AdvData), Channel, MessageText) Then
		Exit Sub
	End If
	
	' Здесь можно отправлять ответ на сообщение
	AnswerToChat(CPtr(AdvancedData Ptr, AdvData), Channel, MessageText)
	
End Sub

Sub IrcPrivateMessage(ByVal AdvData As Any Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	
	' Команды пользователя
	ProcessUserCommand(CPtr(AdvancedData Ptr, AdvData), User, User, MessageText)
	
	' Команда от админа
	If lstrcmp(User, AdminNick1) = 0 OrElse lstrcmp(User, AdminNick2) = 0 Then
		If ProcessAdminCommand(CPtr(AdvancedData Ptr, AdvData), User, User, MessageText) Then
			Exit Sub
		End If
	End If
	
	' Вопросное сообщение
	If QuestionToChat(CPtr(AdvancedData Ptr, AdvData), User, MessageText) Then
		Exit Sub
	End If
	
	' Ответить пользователю в чат
	AnswerToChat(CPtr(AdvancedData Ptr, AdvData), User, MessageText)
	
End Sub

#ifndef service
Sub SendedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub

Sub ReceivedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	WriteLine(CPtr(AdvancedData Ptr, AdvData)->OutHandle, MessageText)
End Sub
#endif

Sub ServerMessage(ByVal AdvData As Any Ptr, ByVal ServerCode As WString Ptr, ByVal MessageText As WString Ptr)
	If lstrcmp(ServerCode, @RPL_WELCOME) = 0 Then
		Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
		
		' Пароль
		Scope
			Dim PasswordBuffer As WString * (IrcClient.MaxBytesCount + 1) = Any
			Dim Result As Integer = GetSettingsValue(@PasswordBuffer, IrcClient.MaxBytesCount, @PasswordKey)
			If Result <> -1 Then
				If lstrlen(@PasswordBuffer) > 0 Then
					Dim Buffer As WString * (IrcClient.MaxBytesCount + 1) = Any
					lstrcpy(@Buffer, "IDENTIFY ")
					lstrcat(@Buffer, @PasswordBuffer)
					eData->objClient.SendIrcMessage(@NickServNick, @Buffer)
				End If
			End If
		End Scope
		
		Scope
			' Режим запрета приёма личных сообщений от незарегистрированных пользователей
			Dim strMode As WString * (IrcClient.MaxBytesCount + 1) = Any
			lstrcpy(@strMode, "MODE ")
			lstrcat(@strMode, @BotNick)
			lstrcat(@strMode, " +R")
			eData->objClient.SendRawMessage(@strMode)
		End Scope
		
		' Присоединиться к каналам
		eData->objClient.JoinChannel(Channels)
	End If
End Sub

Sub UserJoined(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal UserName As WString Ptr)
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Если название канала начинается с двоеточия, то убрать
	Dim wChannel As WString Ptr = Any
	If Channel[0] = 58 Then
		wChannel = @Channel[1]
	Else
		wChannel = @Channel[0]
	End If
	
	If lstrcmp(@MainChannel, wChannel) <> 0 Then
		Exit Sub
	End If
	
	' Запросить информацию о клиенте, если это не мы
	If lstrcmp(@BotNick, UserName) <> 0 Then
		eData->objClient.SendCtcpVersionRequest(UserName)
	End If
	
End Sub

Sub Ping(ByVal AdvData As Any Ptr, ByVal Server As WString Ptr)
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	
	' Обязательно отправляем понг как можно быстрее
	eData->objClient.SendPong(Server)
	
End Sub

Sub CtcpPingResponse(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal ToUser As WString Ptr, ByVal TimeValue As WString Ptr)
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	If lstrcmp(FromUser, ToUser) <> 0 Then
		' Получить время
		Dim UserTime As ULARGE_INTEGER = Any
		Dim Result As Boolean = StrToInt64Ex(TimeValue, STIF_DEFAULT, @UserTime.QuadPart)
		If Result <> 0 Then
			If lstrlen(eData->SavedChannel) <> 0 Then
				' Получить разницу времени
				Dim dt As SYSTEMTIME = Any
				GetSystemTime(@dt)
				Dim ft As FILETIME = Any
				SystemTimeToFileTime(@dt, @ft)
				
				Dim ul As ULARGE_INTEGER = Any
				ul.LowPart = ft.dwLowDateTime
				ul.HighPart = ft.dwHighDateTime
				
				Dim ulRusult As Integer = ul.QuadPart - UserTime.QuadPart
				ulRusult = ulRusult \ 100
				ulRusult = ulRusult \ 2
				
				' Вывести в чат
				Dim strNumber As WString * (IrcClient.MaxBytesCount + 1) = Any
				lstrcpy(@strNumber, eData->SavedUser)
				lstrcat(@strNumber, ": пинг от тебя ")
				itow(ulRusult, @strNumber + lstrlen(strNumber), 10)
				lstrcat(@strNumber, " микросекунд.")
				
				eData->objClient.SendIrcMessage(eData->SavedChannel, @strNumber)
			End If
		End If
	End If
End Sub

Sub CtcpVersionResponse(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal ToUser As WString Ptr, ByVal Version As WString Ptr)
	Dim eData As AdvancedData Ptr = CPtr(AdvancedData Ptr, AdvData)
	If lstrcmp(FromUser, ToUser) <> 0 Then
		' Нужно как‐то отобразить информацию на текущем канале
		Dim strTemp As WString * (IrcClient.MaxBytesCount + 1)
		lstrcpy(@strTemp, FromUser)
		lstrcat(@strTemp, @" использует ")
		lstrcat(@strTemp, Version)
		eData->objClient.SendIrcMessage(@MainChannel, @strTemp)
	End If
End Sub

Sub MakeBotVersion(ByVal Version As WString Ptr)
	lstrcpy(Version, @BotVersion)
	
	Dim osVersion As OsVersionInfoEx
	osVersion.dwOSVersionInfoSize = SizeOf(OsVersionInfoEx)
	
	If GetVersionEx(CPtr(OsVersionInfo Ptr, @osVersion)) <> 0 Then
		Scope
			Dim strNumber As WString * 256 = Any
			itow(osVersion.dwMajorVersion, @strNumber, 10)
			lstrcat(Version, @strNumber)
			lstrcat(Version, @".")
		End Scope
		
		Scope
			Dim strNumber As WString * 256 = Any
			itow(osVersion.dwMinorVersion, @strNumber, 10)
			lstrcat(Version, @strNumber)
			lstrcat(Version, @".")
		End Scope
		
		Scope
			Dim strNumber As WString * 256 = Any
			itow(osVersion.dwBuildNumber, @strNumber, 10)
			lstrcat(Version, @strNumber)
		End Scope
	End If
End Sub

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
	
	AdvData.objClient.AdvancedClientData = @AdvData
	AdvData.objClient.CodePage = CP_UTF8
	AdvData.objClient.ClientUserInfo = @AdminRealName
	
	Dim RealBotVersion As WString * (IrcClient.MaxBytesCount + 1) = Any
	MakeBotVersion(@RealBotVersion)
	
	AdvData.objClient.ClientVersion = @RealBotVersion
	AdvData.SavedChannel[0] = 0
	
	' События, которые бот не обрабатывает
	' необходимо установить в NULL
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
	AdvData.objClient.UserJoinedEvent = @UserJoined
	
	AdvData.objClient.ServerErrorEvent = NULL
	AdvData.objClient.NoticeEvent = NULL
	AdvData.objClient.UserLeavedEvent = NULL
	AdvData.objClient.NickChangedEvent = NULL
	AdvData.objClient.TopicEvent = NULL
	AdvData.objClient.QuitEvent = NULL
	AdvData.objClient.KickEvent = NULL
	AdvData.objClient.InviteEvent = NULL
	AdvData.objClient.PingEvent = NULL
	AdvData.objClient.PongEvent = NULL
	AdvData.objClient.ModeEvent = NULL

	AdvData.objClient.CtcpPingRequestEvent = NULL
	AdvData.objClient.CtcpTimeRequestEvent = NULL
	AdvData.objClient.CtcpUserInfoRequestEvent = NULL
	AdvData.objClient.CtcpVersionRequestEvent = NULL
	AdvData.objClient.CtcpActionEvent = NULL
	AdvData.objClient.CtcpPingResponseEvent = @CtcpPingResponse
	AdvData.objClient.CtcpTimeResponseEvent = NULL
	AdvData.objClient.CtcpUserInfoResponseEvent = NULL
	AdvData.objClient.CtcpVersionResponseEvent = @CtcpVersionResponse
	
	' Инициализация случайных чисел
	Dim dtNow As SYSTEMTIME = Any
	GetSystemTime(@dtNow)
	srand(dtNow.wMilliseconds - dtNow.wSecond + dtNow.wMinute + dtNow.wHour)
	
#ifdef service
	Do
#endif
		' Инициализация: сервер порт ник юзер описание
		If AdvData.objClient.OpenIrc(@IrcServer, @Port, @BotNick, @UserString, @Description) Then
			AdvData.objClient.Run()
		End If
		AdvData.objClient.CloseIrc()
#ifdef service
		Sleep_(60 * 1000)
	Loop
#endif
	
	Return 0
End Function

#if __FB_DEBUG__ <> 0
End(EntryPoint())
#endif