#ifndef STRINGFUNCTIONS_BI
#define STRINGFUNCTIONS_BI

Declare Function StartsWith Overload( _
	ByVal s As WString Ptr, _
	ByVal Value As WString Ptr _
)As Boolean

Declare Function StartsWith Overload( _
	ByVal s As WString Ptr, _
	ByVal Value As WString Ptr, _
	ByVal Length As Integer _
)As Boolean

#endif
