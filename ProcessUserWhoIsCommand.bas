#include once "ProcessUserWhoIsCommand.bi"

Sub ProcessUserWhoIsCommand( _
		ByVal pBot As IrcBot Ptr, _
		ByVal User As WString Ptr, _
		ByVal Channel As WString Ptr _
	)
	lstrcpy(pBot->SavedChannel, Channel)
	lstrcpy(pBot->SavedUser, User)
	
	Dim strWhoIsUser As WString * (IrcClient.MaxBytesCount + 1) = Any
	lstrcpy(@strWhoIsUser, "WHOIS ")
	lstrcat(@strWhoIsUser, User)
	pBot->Client.SendRawMessage(@strWhoIsUser)
End Sub
