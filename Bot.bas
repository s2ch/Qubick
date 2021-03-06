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
#include once "CharConstants.bi"

Const IrcServer = "chat.freenode.net"
Const Port = "6667"

' Const IrcServer = "rechat.cloudapp.net"
' Const Port = "6665"
' Const AdminNick = "mabu"
' Const Channels = "#pikabu"
' Const MainChannel = "#pikabu"

Const LocalAddress = "0.0.0.0"
Const LocalPort = ""

Const ServerPassword = ""

#if __FB_DEBUG__ <> 0
Const BotNick = "Station922_mkv"
#else
Const BotNick = "Qubick"
#endif

Const UserString = "Qubick"
Const Description = "Irc bot written in FreeBASIC"

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

Sub InitializeIrcBot(ByVal pBot As IrcBot Ptr, ByVal RealBotVersion As WString Ptr)
	pBot->IrcServer = @IrcServer
	pBot->Port = @Port
	pBot->BotNick = @BotNick
	pBot->UserString = @UserString
	pBot->Description = @Description
	
	pBot->InHandle = GetStdHandle(STD_INPUT_HANDLE)
	pBot->OutHandle = GetStdHandle(STD_OUTPUT_HANDLE)
	pBot->ErrorHandle = GetStdHandle(STD_ERROR_HANDLE)
	
	pBot->ReceivedRawMessagesCounter = 0
	pBot->SendedRawMessagesCounter = 0
	
	pBot->SavedChannel[0] = 0
	pBot->SavedUser[0] = 0
	
	pBot->AdminAuthenticated = False
	
	pBot->Client.AdvancedClientData = pBot
	pBot->Client.CodePage = CP_UTF8
	pBot->Client.ClientUserInfo = @AdminRealName
	
	MakeBotVersion(RealBotVersion)
	
	pBot->Client.ClientVersion = RealBotVersion
	
	pBot->Client.SendedRawMessageEvent = @SendedRawMessage
	pBot->Client.ReceivedRawMessageEvent = @ReceivedRawMessage
	pBot->Client.ServerMessageEvent = @ServerMessage
	pBot->Client.ChannelMessageEvent = @ChannelMessage
	pBot->Client.PrivateMessageEvent = 0
	pBot->Client.UserJoinedEvent = @UserJoined
	pBot->Client.ServerErrorEvent = 0
	pBot->Client.NoticeEvent = 0
	pBot->Client.UserLeavedEvent = 0
	pBot->Client.NickChangedEvent = @NickChanged
	pBot->Client.TopicEvent = 0
	pBot->Client.QuitEvent = @UserQuit
	pBot->Client.KickEvent = 0
	pBot->Client.InviteEvent = 0
	pBot->Client.PingEvent = 0
	pBot->Client.PongEvent = 0
	pBot->Client.ModeEvent = 0
	pBot->Client.CtcpPingRequestEvent = 0
	pBot->Client.CtcpTimeRequestEvent = 0
	pBot->Client.CtcpUserInfoRequestEvent = 0
	pBot->Client.CtcpVersionRequestEvent = 0
	pBot->Client.CtcpActionEvent = 0
	pBot->Client.CtcpPingResponseEvent = @CtcpPingResponse
	pBot->Client.CtcpTimeResponseEvent = 0
	pBot->Client.CtcpUserInfoResponseEvent = 0
	pBot->Client.CtcpVersionResponseEvent = @CtcpVersionResponse
End Sub

Sub IrcBot.Say( _
		ByVal Channel As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
	IncrementUserWords(Channel, BotNick)
	Client.SendIrcMessage(Channel, MessageText)
End Sub

Sub IrcBot.SayWithTimeOut( _
		ByVal Channel As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
	IncrementUserWords(Channel, BotNick)
	Client.SendIrcMessage(Channel, MessageText)
	SleepEx(MessageTimeWait, 0)
End Sub
