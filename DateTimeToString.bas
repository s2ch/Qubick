#include once "DateTimeToString.bi"

Const DateFormatString = "ddd, dd MMM yyyy "
Const TimeFormatString = "HH:mm:ss GMT"

Sub GetHttpDate(ByVal Buffer As WString Ptr, ByVal dt As SYSTEMTIME Ptr)
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormat(LOCALE_INVARIANT, 0, dt, @DateFormatString, Buffer, 31) - 1
	GetTimeFormat(LOCALE_INVARIANT, 0, dt, @TimeFormatString, @Buffer[dtBufferLength], 31 - dtBufferLength)
End Sub

Sub GetHttpDate(ByVal Buffer As WString Ptr)
	Dim dt As SYSTEMTIME = Any
	GetSystemTime(@dt)
	GetHttpDate(Buffer, @dt)
End Sub
