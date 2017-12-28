#include once "StringFunctions.bi"

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\shlwapi.bi"

Function StartsWith Overload(ByVal s As WString Ptr, ByVal Value As WString Ptr, ByVal Length As Integer)As Boolean
	If lstrlen(s) < Length Then
		Return False
	End If
	
	Dim ch As Integer = s[Length]
	s[Length] = 0
	
	If StrStrI(s, Value) <> 0 Then
		StartsWith = True
	Else
		StartsWith = False
	End If
	
	s[Length] = ch
End Function

Function StartsWith Overload(ByVal s As WString Ptr, ByVal Value As WString Ptr)As Boolean
	Return StartsWith(s, Value, lstrlen(Value))
End Function
