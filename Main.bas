#include once "Main.bi"
#include once "Bot.bi"
#include once "MainLoop.bi"

Function EntryPoint Alias "EntryPoint"()As Integer
	Dim pBot As IrcBot = Any
	Dim RealBotVersion As WString * (IrcClient.MaxBytesCount + 1) = Any
	InitializeIrcBot(@pBot, @RealBotVersion)
	Return MainLoop(@pBot)
End Function

#if __FB_DEBUG__ <> 0
End(EntryPoint())
#endif