#ifndef INTEGERTOWSTRING_BI
#define INTEGERTOWSTRING_BI

Declare Function itow cdecl Alias "_itow"( _
	ByVal Value As Integer, _
	ByVal src As WString Ptr, _
	ByVal radix As Integer _
)As WString Ptr

Declare Function i64tow cdecl Alias "_i64tow"( _
	ByVal Value As Integer, _
	ByVal src As WString Ptr, _
	ByVal radix As Integer _
)As WString Ptr

Declare Function ltow cdecl Alias "_ltow"( _
	ByVal Value As Long, _
	ByVal src As WString Ptr, _
	ByVal radix As Integer _
)As WString Ptr

Declare Function wtoi cdecl Alias "_wtoi"( _
	ByVal src As WString Ptr _
)As Integer

Declare Function wtol cdecl Alias "_wtol"( _
	ByVal src As WString Ptr _
)As Long

#endif
