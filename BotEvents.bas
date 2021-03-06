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
#include once "DateTimeToString.bi"

Sub ChannelMessage( _
		ByVal AdvData As Any Ptr, _
		ByVal Channel As WString Ptr, _
		ByVal User As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
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

Sub ServerMessage( _
		ByVal AdvData As Any Ptr, _
		ByVal ServerCode As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
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
				If lstrcmp(Lines[1], AdminNick1) = 0 Then
					If StrStr(MessageText, ":is logged in as") <> 0 Then
						pBot->AdminAuthenticated = True
					End If
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

Sub UserJoined( _
		ByVal AdvData As Any Ptr, _
		ByVal Channel As WString Ptr, _
		ByVal UserName As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	
	Dim wChannel As WString Ptr = Any
	If Channel[0] = ColonChar Then
		wChannel = @Channel[1]
	Else
		wChannel = @Channel[0]
	End If
	
	If lstrcmp(@MainChannel, wChannel) <> 0 Then
		Exit Sub
	End If
	
	If lstrcmp(pBot->BotNick, UserName) <> 0 Then
		pBot->Client.SendCtcpVersionRequest(UserName)
	End If
End Sub

Sub UserQuit( _
		ByVal AdvData As Any Ptr, _
		ByVal UserName As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(UserName, AdminNick1) = 0 OrElse lstrcmp(UserName, AdminNick2) = 0 Then
		pBot->AdminAuthenticated = False
	End If
End Sub

Sub NickChanged( _
		ByVal AdvData As Any Ptr, _
		ByVal OldNick As WString Ptr, _
		ByVal NewNick As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(OldNick, AdminNick1) = 0 Then
		pBot->AdminAuthenticated = False
	End If
	If lstrcmp(OldNick, AdminNick2) = 0 Then
		pBot->AdminAuthenticated = False
	End If
End Sub

Sub Ping( _
		ByVal AdvData As Any Ptr, _
		ByVal Server As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	pBot->Client.SendPong(Server)
End Sub

Sub CtcpPingResponse( _
		ByVal AdvData As Any Ptr, _
		ByVal FromUser As WString Ptr, _
		ByVal ToUser As WString Ptr, _
		ByVal TimeValue As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	Dim CurrentSystemDateTicks As ULARGE_INTEGER = GetCurrentSystemDateTicks()
	If lstrcmp(FromUser, ToUser) = 0 Then
		Exit Sub
	End If
	
	If lstrlen(pBot->SavedChannel) = 0 Then
		Exit Sub
	End If
	
	Dim UserDateTicks As ULARGE_INTEGER = Any
	If StrToInt64Ex(TimeValue, STIF_DEFAULT, @UserDateTicks.QuadPart) = 0 Then
		Exit Sub
	End If
	
	Dim UserDelay As Integer = CurrentSystemDateTicks.QuadPart - UserDateTicks.QuadPart
	UserDelay = UserDelay \ 100
	UserDelay = UserDelay \ 2
	
	Dim strUserDelay As WString * (IrcClient.MaxBytesCount + 1) = Any
	lstrcpy(@strUserDelay, pBot->SavedUser)
	lstrcat(@strUserDelay, ": ping from you ")
	itow(UserDelay, @strUserDelay + lstrlen(@strUserDelay), 10)
	lstrcat(@strUserDelay, " microseconds.")
	
	pBot->Say(pBot->SavedChannel, @strUserDelay)
	pBot->SavedChannel[0] = 0
End Sub

Sub CtcpVersionResponse( _
		ByVal AdvData As Any Ptr, _
		ByVal FromUser As WString Ptr, _
		ByVal ToUser As WString Ptr, _
		ByVal Version As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	If lstrcmp(FromUser, ToUser) <> 0 Then
		Dim ClientVersion As WString * (IrcClient.MaxBytesCount + 1)
		lstrcpy(@ClientVersion, FromUser)
		lstrcat(@ClientVersion, @" is using ")
		lstrcat(@ClientVersion, Version)
		pBot->Say(@MainChannel, @ClientVersion)
	End If
End Sub

Sub SendedRawMessage( _
		ByVal AdvData As Any Ptr, _
		ByVal MessageText As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	pBot->SendedRawMessagesCounter += 1
#ifndef service
	WriteLine(pBot->OutHandle, MessageText)
#endif
End Sub

Sub ReceivedRawMessage( _
		ByVal AdvData As Any Ptr, _
		ByVal MessageText As WString Ptr _
	)
	Dim pBot As IrcBot Ptr = CPtr(IrcBot Ptr, AdvData)
	pBot->ReceivedRawMessagesCounter += 1
#ifndef service
	WriteLine(pBot->OutHandle, MessageText)
#endif
End Sub
