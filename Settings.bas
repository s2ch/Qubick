#include once "Settings.bi"
#ifndef unicode
#define unicode
#endif
#include once "windows.bi"

Const RegSection = "Software\Пакетные файлы\FreeBasicIrcBot"

Function IncrementUserWords(ByVal Channel As WString Ptr, ByVal User As WString Ptr)As Boolean
	Dim RegSectionChannels As WString * 512 = Any
	lstrcpy(RegSectionChannels, RegSection)
	lstrcat(RegSectionChannels, Channel)
	
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSectionChannels, 0, 0, 0, KEY_QUERY_VALUE + KEY_SET_VALUE, NULL, @reg, @lpdwDisposition)
	
	If hr <> ERROR_SUCCESS Then
		Return False
	End If
	
	Dim pdwType As DWORD = REG_DWORD
	Dim Buffer As DWORD = Any
	Dim BufferLength As DWORD = SizeOf(DWORD)
	hr = RegQueryValueEx(reg, User, 0, @pdwType, CPtr(Byte Ptr, @Buffer), @BufferLength)
	If hr <> ERROR_SUCCESS Then
		If hr = ERROR_FILE_NOT_FOUND  Then
			Buffer = 0
			BufferLength = SizeOf(DWORD)
		Else
			RegCloseKey(reg)
			Return -1
		End If
	End If
	
	Buffer += 1
	
	hr = RegSetValueEx(reg, User, 0, REG_DWORD, CPtr(Byte Ptr, @Buffer), SizeOf(DWORD))
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return False
	End If
	
	RegCloseKey(reg)
	Return True
End Function

' Получение значения из реестра
Function GetSettingsValue(ByVal Buffer As WString Ptr, ByVal BufferLength As Integer, ByVal Key As WString Ptr)As Integer
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_QUERY_VALUE, NULL, @reg, @lpdwDisposition)

	If hr <> ERROR_SUCCESS Then
		Return -1
	End If
	
	Dim pdwType As DWORD = RRF_RT_REG_SZ
	Dim BufferLength2 As DWORD = (BufferLength + 1) * SizeOf(WString)
	hr = RegQueryValueEx(reg, Key, 0, @pdwType, CPtr(Byte Ptr, Buffer), @BufferLength2)
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return -1
	End If
	
	' Закрыть
	RegCloseKey(reg)
	
	Return BufferLength \ SizeOf(WString) - 1
End Function

' Запись значения в реестр
Function SetSettingsValue(ByVal Key As WString Ptr, ByVal Value As WString Ptr)As Boolean
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_SET_VALUE, NULL, @reg, @lpdwDisposition)
	
	If hr <> ERROR_SUCCESS Then
		Return False
	End If
	
	' Записать туда параметры
	hr = RegSetValueEx(reg, Key, 0, REG_SZ, CPtr(Byte Ptr, Value), (lstrlen(Value) + 1) * SizeOf(WString))
	If hr <> ERROR_SUCCESS Then
		RegCloseKey(reg)
		Return False
	End If
	
	RegCloseKey(reg)
	Return True
End Function