#include once "ProcessCtcpPingCommand.bi"
#include once "IntegerToWString.bi"

Sub ProcessCtcpPingCommand( _
		ByVal pBot As IrcBot Ptr, _
		ByVal User As WString Ptr, _
		ByVal Channel As WString Ptr _
	)
	lstrcpy(pBot->SavedChannel, Channel)
	lstrcpy(pBot->SavedUser, User)
	
	Dim CurrentSystemDate As SYSTEMTIME = Any
	GetSystemTime(@CurrentSystemDate)
	
	Dim CurrentSystemFileDate As FILETIME = Any
	SystemTimeToFileTime(@CurrentSystemDate, @CurrentSystemFileDate)
	
	Dim CurrentSystemDateTicks As ULARGE_INTEGER = Any
	CurrentSystemDateTicks.LowPart = CurrentSystemFileDate.dwLowDateTime
	CurrentSystemDateTicks.HighPart = CurrentSystemFileDate.dwHighDateTime
	
	Dim strCurrentSystemDateTicks As WString * 256 = Any
	i64tow(CurrentSystemDateTicks.QuadPart, @strCurrentSystemDateTicks, 10)
	
	pBot->Client.SendCtcpPingRequest(User, @strCurrentSystemDateTicks)
End Sub
