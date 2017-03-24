#include once "WriteLine.bi"

Public Function WriteLine(ByVal hOut As Handle, ByVal s As WString Ptr)As Integer
	' Максимальная длина строки
	Const MaxBytesCount1 As Integer = 32000
	
	' Строка с переводом
	Dim StringWithNewLine As WString * (MaxBytesCount1 + 1) = Any
	
	' Получить строку вместе с символами CrLf
	' И узнать длину результата
	Dim intLength As DWORD = Cast(DWORD, lstrlen(lstrcat(lstrcpy(StringWithNewLine, s), NewLineString)))
	
	' Количество символов, выведенных на консоль или записанных в файл
	Dim CharsCount As DWORD = Any
	
	If WriteConsole(hOut, @StringWithNewLine, intLength, @CharsCount, 0) = 0 Then
		' Возможно, вывод перенаправлен, нужно записать в файл
		WriteFile(hOut, @StringWithNewLine, intLength * SizeOf(WString), @CharsCount, 0)
		
		Return CharsCount \ SizeOf(WString)
	Else
		Return CharsCount
	End If
	
End Function
