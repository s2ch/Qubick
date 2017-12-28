#include once "BotEvents.bi"
#include once "IrcEvents.bi"
#include once "IrcReplies.bi"
#include once "Bot.bi"
#include once "Settings.bi"
#include once "ProcessCommands.bi"
#include once "QuestionToChat.bi"
#include once "AnswerToChat.bi"
#include once "WriteLine.bi"
#include once "CharConstants.bi"
#include once "IntegerToWString.bi"
#include once "BotConfig.bi"

Sub ChannelMessage(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	
	IncrementUserWords(Channel, User)
	
	If ProcessUserCommand(pBot, User, Channel, MessageText) Then
		Exit Sub
	End If
	
	If QuestionToChat(pBot, Channel, MessageText) Then
		Exit Sub
	End If
	
	AnswerToChat(pBot, Channel, MessageText)
	
End Sub

Sub ServerMessage(ByVal AdvData As Any Ptr, ByVal ServerCode As WString Ptr, ByVal MessageText As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(ServerCode, @RPL_WELCOME) = 0 Then
		Dim PasswordBuffer As WString * (IrcClient.MaxBytesCount + 1) = Any
		Dim Result As Integer = GetSettingsValue(@PasswordBuffer, IrcClient.MaxBytesCount, @PasswordKey)
		If Result <> -1 Then
			If lstrlen(@PasswordBuffer) > 0 Then
				Dim Buffer As WString * (IrcClient.MaxBytesCount + 1) = Any
				lstrcpy(@Buffer, "IDENTIFY ")
				lstrcat(@Buffer, @PasswordBuffer)
				pBot->Client.SendIrcMessage(@NickServNick, @Buffer)
			End If
		End If
		
		pBot->Client.JoinChannel(Channels1)
		pBot->Client.JoinChannel(Channels2)
		
		Exit Sub
	End If
	
	If lstrcmp(ServerCode, @RPL_WHOISLOGGEDAS) = 0 Then
		':orwell.freenode.net 330 Station922_mkv PERDOLIKS writed :is logged in as
		' Кому, кто, аккуант, флаг залогиненности
		Dim WordsCount As Long = Any
		Dim Lines As WString Ptr Ptr = CommandLineToArgvW(MessageText, @WordsCount)
		
		If WordsCount > 4 Then
			If lstrcmp(Lines[0], AdminNick1) = 0 OrElse lstrcmp(Lines[0], AdminNick2) = 0 Then
				If StrStr(MessageText, ":is logged in as") <> 0 Then
					pBot->AdminAuthenticated = True
				End If
			Else
				If lstrlen(pBot->SavedChannel) <> 0 Then
					pBot->Say(pBot->SavedChannel, @"Ты никто и судьбы твоей нет. Ты проиграл свою душу, она не принадлежит тебе уже.")
					pBot->SavedChannel[0] = 0
				End If
			End If
		End If
		
		LocalFree(Lines)
		Exit Sub
	End If
End Sub

Sub UserJoined(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal UserName As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	
	' Убрать двоеточие
	Dim wChannel As WString Ptr = Any
	If Channel[0] = ColonChar Then
		wChannel = @Channel[1]
	Else
		wChannel = @Channel[0]
	End If
	
	If lstrcmp(@MainChannel, wChannel) <> 0 Then
		Exit Sub
	End If
	
	' Запросить информацию о клиенте, если это не мы
	If lstrcmp(pBot->BotNick, UserName) <> 0 Then
		pBot->Client.SendCtcpVersionRequest(UserName)
	End If
	
End Sub

Sub UserQuit(ByVal AdvData As Any Ptr, ByVal UserName As WString Ptr, ByVal MessageText As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(UserName, AdminNick1) = 0 OrElse lstrcmp(UserName, AdminNick2) = 0 Then
		pBot->AdminAuthenticated = False
	End If
End Sub

Sub NickChanged(ByVal AdvData As Any Ptr, ByVal OldNick As WString Ptr, ByVal NewNick As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(OldNick, AdminNick1) = 0 OrElse lstrcmp(OldNick, AdminNick2) = 0 Then
		pBot->AdminAuthenticated = False
	End If
End Sub

Sub Ping(ByVal AdvData As Any Ptr, ByVal Server As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	
	pBot->Client.SendPong(Server)
	
End Sub

Sub CtcpPingResponse(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal ToUser As WString Ptr, ByVal TimeValue As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(FromUser, ToUser) <> 0 Then
		' Получить время
		If lstrlen(pBot->SavedChannel) <> 0 Then
			Dim UserTime As ULARGE_INTEGER = Any
			Dim Result As Boolean = StrToInt64Ex(TimeValue, STIF_DEFAULT, @UserTime.QuadPart)
			If Result <> 0 Then
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
				lstrcpy(@strNumber, pBot->SavedUser)
				lstrcat(@strNumber, ": ping from you ")
				itow(ulRusult, @strNumber + lstrlen(strNumber), 10)
				lstrcat(@strNumber, " microseconds.")
				
				pBot->Say(pBot->SavedChannel, @strNumber)
				pBot->SavedChannel[0] = 0
			End If
		End If
	End If
End Sub

Sub CtcpVersionResponse(ByVal AdvData As Any Ptr, ByVal FromUser As WString Ptr, ByVal ToUser As WString Ptr, ByVal Version As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(FromUser, ToUser) <> 0 Then
		Dim strTemp As WString * (IrcClient.MaxBytesCount + 1)
		lstrcpy(@strTemp, FromUser)
		lstrcat(@strTemp, @" is using ")
		lstrcat(@strTemp, Version)
		pBot->Say(@MainChannel, @strTemp)
	End If
End Sub

Sub SendedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	pBot->SendedRawMessagesCounter += 1
#ifndef service
	WriteLine(pBot->OutHandle, MessageText)
#endif
End Sub

Sub ReceivedRawMessage(ByVal AdvData As Any Ptr, ByVal MessageText As WString Ptr)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	pBot->ReceivedRawMessagesCounter += 1
#ifndef service
	WriteLine(pBot->OutHandle, MessageText)
#endif
End Sub
