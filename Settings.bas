#include once "Settings.bi"
#ifndef unicode
#define unicode
#endif
#include once "windows.bi"

Const RegSection = "Software\Пакетные файлы\FreeBasicIrcBot"

' Получение значения из реестра
Function GetSettingsValue(ByVal Buffer As WString Ptr, ByVal BufferLength As Integer, ByVal Key As WString Ptr)As Integer
	Dim reg As HKEY = Any
	Dim lpdwDisposition As DWORD = Any
	Dim hr As Long = RegCreateKeyEx(HKEY_CURRENT_USER, @RegSection, 0, 0, 0, KEY_QUERY_VALUE, NULL, @reg, @lpdwDisposition)

	If hr <> ERROR_SUCCESS Then
		Return -1
	End If
	
	Dim pdwType As DWORD = Any
	Dim BufferLength2 As DWORD = (BufferLength + 1) * SizeOf(WString)
	hr = RegGetValue(reg, NULL, Key, RRF_RT_REG_SZ, @pdwType, Buffer, @BufferLength2)
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