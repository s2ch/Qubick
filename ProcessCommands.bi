#ifndef PROCESSUSERCOMMANDS_BI
#define PROCESSUSERCOMMANDS_BI

#include once "Bot.bi"

Declare Function ProcessUserCommand( _
	ByVal pBot As IrcBot Ptr, _
	ByVal User As WString Ptr, _
	ByVal Channel As WString Ptr, _
	ByVal MessageText As WString Ptr _
)As Boolean

#endif
