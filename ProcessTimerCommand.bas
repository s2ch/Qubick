#include once "ProcessTimerCommand.bi"
#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "CharConstants.bi"
#include once "IntegerToWString.bi"

Type TimerThreadParam
	Dim Interval As Integer
	Dim pBot As IrcBot Ptr
	' Кому отправить сообщение
	Dim Channel As WString * (IrcClient.MaxBytesCount + 1)
	' Текст сообщения
	Dim TextToSend As WString * (IrcClient.MaxBytesCount + 1)
	
	Dim hMapFile As HANDLE
End Type

Function TimerAPCProc(ByVal lpParam As LPVOID)As DWORD
	Dim ttp As TimerThreadParam Ptr = CPtr(TimerThreadParam Ptr, lpParam)
	Sleep_(ttp->Interval)
	ttp->pBot->Say(ttp->Channel, ttp->TextToSend)
	
	Dim hMapFile As Handle = ttp->hMapFile
	UnmapViewOfFile(ttp)
	CloseHandle(hMapFile)
	Return 0
End Function

Sub ProcessTimerCommand( _
		ByVal pBot As IrcBot Ptr, _
		ByVal User As WString Ptr, _
		ByVal Channel As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
	Dim wSpace1 As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
	If wSpace1 = 0 Then
		pBot->Say(Channel, @"Интервал времени должен быть в диапазоне [1, 3600].")
		Exit Sub
	End If
	wSpace1[0] = 0
	wSpace1 += 1
	
	Dim wSpace2 As WString Ptr = StrChr(wSpace1, WhiteSpaceChar)
	If wSpace2 = 0 Then
		pBot->Say(Channel, @"Необходимо указать сообщение.")
		Exit Sub
	End If
	wSpace2[0] = 0
	wSpace2 += 1
	
	If StrStrI(wSpace2, "http") <> 0 Then
		pBot->Say(Channel, @"Я не хочу ставить таймер с сообщением, содержащим ссылки.")
		Exit Sub
	End If
	
	' Проверить параметры
	Dim Seconds As LongInt = wtoi(wSpace1)
	If Seconds > 0 AndAlso Seconds <= 3600 Then
		pBot->Say(Channel, @"Интервал времени должен быть в диапазоне [1, 3600]")
		Exit Sub
	End If
	
	Dim TimerName As WString * (IrcClient.MaxBytesCount + 1) = Any
	lstrcpy(@TimerName, "IrcBotTimers")
	lstrcat(@TimerName, User)
	
	' Выделить память
	Dim hMapFile As Handle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, SizeOf(TimerThreadParam), @TimerName)
	If hMapFile = NULL Then
		pBot->Say(Channel, @"Не могу создать отображение файла")
		Exit Sub
	End If
	
	If GetLastError() = ERROR_ALREADY_EXISTS Then
		CloseHandle(hMapFile)
		Exit Sub
	End If
		
	Dim ttp As TimerThreadParam Ptr = CPtr(TimerThreadParam Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TimerThreadParam)))
	If ttp = 0 Then
		CloseHandle(hMapFile)
		pBot->Say(Channel, @"Не могу выделить память")
		Exit Sub
	End If
	
	ttp->Interval = 1000 * Seconds
	ttp->hMapFile = hMapFile
	ttp->pBot = pBot
	lstrcpy(ttp->Channel, Channel)
	lstrcpy(ttp->TextToSend, User)
	lstrcat(ttp->TextToSend, ": ")
	lstrcat(ttp->TextToSend, wSpace2)
	
	Dim hThread As Handle = CreateThread(NULL, 0, @TimerAPCProc, ttp, 0, 0)
	If hThread = NULL Then
		UnmapViewOfFile(ttp)
		CloseHandle(hMapFile)
		pBot->Say(Channel, @"Не могу создать поток ожидания таймера")
		Exit Sub
	End If
	
	CloseHandle(hThread)
End Sub