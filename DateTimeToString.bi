#ifndef DATETIMETOSTRING_BI
#define DATETIMETOSTRING_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"

Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr _
)

Declare Sub GetHttpDate Overload( _
	ByVal Buffer As WString Ptr, _
	ByVal dt As SYSTEMTIME Ptr _
)

Declare Function GetCurrentSystemDateTicks( _
)As ULARGE_INTEGER

#endif
