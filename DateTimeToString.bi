#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"

' Заполняет буфер датой и временем в http формате
Declare Sub GetHttpDate Overload(ByVal Buffer As WString Ptr)
Declare Sub GetHttpDate Overload(ByVal Buffer As WString Ptr, ByVal dt As SYSTEMTIME Ptr)
