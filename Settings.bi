#ifndef SETTINGS_BI
#define SETTINGS_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"

Type UserWords
	Dim UserName As WString * 512
	Dim WordsCount As Integer
End Type

Declare Function EnumerateUserWords( _
	ByVal Channel As WString Ptr, _
	ByVal hHeap As Handle, _
	ByVal ValuesCount As DWORD Ptr _
)As UserWords Ptr

' Увеличивает счётчик фраз пользователя
Declare Function IncrementUserWords( _
	ByVal Channel As WString Ptr, _
	ByVal User As WString Ptr _
)As Boolean

' Получение значения из реестра
Declare Function GetSettingsValue( _
	ByVal Buffer As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal Key As WString Ptr _
)As Integer

' Запись значения в реестр
Declare Function SetSettingsValue( _
	ByVal Key As WString Ptr, _
	ByVal Value As WString Ptr _
)As Boolean

#endif
