#ifndef PROCESSPENISCOMMAND_BI
#define PROCESSPENISCOMMAND_BI

#include once "Bot.bi"

Declare Sub ProcessPenisCommand( _
	ByVal pBot As IrcBot Ptr, _
	ByVal User As WString Ptr, _
	ByVal Channel As WString Ptr, _
	ByVal MessageText As WString Ptr _
)

#endif
