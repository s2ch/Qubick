#include once "Bot.bi"

' Ответить на сообщение
Sub AnswerToChat(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)
	' Открыть файл, прочитать
	Dim hFile As HANDLE = CreateFile(@"Ответы.txt", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
	If hFile <> INVALID_HANDLE_VALUE Then
		' Найти ключевую фразу
		' Найти ответ
		' Отправить пользвателю
		' Закрытие
		CloseHandle(hFile)
	End If
End Sub
