#include once "ProcessUserCommand.bi"
#include once "Commands.bi"
#include once "BotConfig.bi"
#include once "IntegerToWString.bi"
#include once "CharConstants.bi"
#include once "StringFunctions.bi"
#include once "Settings.bi"
#include once "windows.bi"
#include once "ProcessCtcpPingCommand.bi"
#include once "ProcessFenceCommand.bi"

Const AsciiFileName = "ascii.txt"

Type TimerThreadParam
	Dim Interval As Integer
	Dim pBot As IrcBot Ptr
	' Кому отправить сообщение
	Dim Channel As WString * (IrcClient.MaxBytesCount + 1)
	' Текст сообщения
	Dim TextToSend As WString * (IrcClient.MaxBytesCount + 1)
	
	Dim hMapFile As HANDLE
End Type

Type StatisticWordCountParam
	Dim pBot As IrcBot Ptr
	' Кому отправить сообщение
	Dim UserName As WString * (IrcClient.MaxBytesCount + 1)
	' Канал
	Dim Channel As WString * (IrcClient.MaxBytesCount + 1)
	
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

Function StatisticWordCount(ByVal lpParam As LPVOID)As DWORD
	Dim ttp As StatisticWordCountParam Ptr = CPtr(StatisticWordCountParam Ptr, lpParam)
	
#if __FB_DEBUG__ <> 0
	Const StatisticWordFileName = "c:\programming\freebasic projects\channelstats.xml"
#else
	Const StatisticWordFileName = "c:\programming\www.freebasic.su\channelstats.xml"
#endif
	
	ttp->pBot->Say(ttp->Channel, @"Читаю статистику количества фраз пользователей из реестра Windows.")
	
	Dim hHeap As Handle = HeapCreate(HEAP_NO_SERIALIZE, 0, 0)
	Dim ValuesCount As DWORD = 0
	Dim uw As UserWords Ptr = EnumerateUserWords(@ttp->Channel, hHeap, @ValuesCount)
	
	If uw = 0 Then
		ttp->pBot->Say(ttp->Channel, @"Ошибка чтения реестра, лень разбираться какая.")
	Else
		Dim hFile As HANDLE = CreateFile(@StatisticWordFileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
		If hFile <> INVALID_HANDLE_VALUE Then
			Dim bb As ZString * 2 = Any
			bb[0] = 255
			bb[1] = 254
			Dim WriteBytesCount As DWORD = Any
			WriteFile(hFile, @bb, 2, @WriteBytesCount, 0)
			
			Const xmlDeclaration = "<?xml version=""1.0"" encoding=""utf-16"" ?>"
			WriteFile(hFile, @xmlDeclaration, lstrlen(xmlDeclaration) * SizeOf(WString), @WriteBytesCount, 0)
			
			Const xmlStartRoot = "<channelstats>"
			Const xmlEndRoot = "</channelstats>"
			
			WriteFile(hFile, @xmlStartRoot, lstrlen(@xmlStartRoot) * SizeOf(WString), @WriteBytesCount, 0)
			
			For i As DWORD = 0 To ValuesCount - 1
				Const xmlStartUserMessagesTable = "<statistics>"
				Const xmlEndUserMessagesTable = "</statistics>"
				
				WriteFile(hFile, @xmlStartUserMessagesTable, lstrlen(@xmlStartUserMessagesTable) * SizeOf(WString), @WriteBytesCount, 0)
				
				Scope
					Const xmlStartUserName = "<nick>"
					Const xmlEndUserName = "</nick>"
					
					WriteFile(hFile, @xmlStartUserName, lstrlen(@xmlStartUserName) * SizeOf(WString), @WriteBytesCount, 0)
					WriteFile(hFile, @uw[i].UserName, lstrlen(@uw[i].UserName) * SizeOf(WString), @WriteBytesCount, 0)
					WriteFile(hFile, @xmlEndUserName, lstrlen(@xmlEndUserName) * SizeOf(WString), @WriteBytesCount, 0)
				End Scope
				
				Scope
					Const xmlStartMessagesCount = "<messages-count>"
					Const xmlEndMessagesCount = "</messages-count>"
					
					Dim strWordsCount As WString * 100 = Any
					itow(uw[i].WordsCount, @strWordsCount, 10)
					
					WriteFile(hFile, @xmlStartMessagesCount, lstrlen(@xmlStartMessagesCount) * SizeOf(WString), @WriteBytesCount, 0)
					WriteFile(hFile, @strWordsCount, lstrlen(@strWordsCount) * SizeOf(WString), @WriteBytesCount, 0)
					WriteFile(hFile, @xmlEndMessagesCount, lstrlen(@xmlEndMessagesCount) * SizeOf(WString), @WriteBytesCount, 0)
				End Scope
				
				WriteFile(hFile, @xmlEndUserMessagesTable, lstrlen(xmlEndUserMessagesTable) * SizeOf(WString), @WriteBytesCount, 0)
			Next
			
			WriteFile(hFile, @xmlEndRoot, lstrlen(xmlEndRoot) * SizeOf(WString), @WriteBytesCount, 0)
			
			CloseHandle(hFile)
			
			ttp->pBot->Say(ttp->Channel, @"Смотри по этой ссылке http://www.freebasic.su/channelstats.xml")
		End If
		
	End If
	
	HeapDestroy(hHeap)
	Dim hMapFile As Handle = ttp->hMapFile
	UnmapViewOfFile(ttp)
	CloseHandle(hMapFile)
	Return 0
End Function

Function ProcessUserCommand( _
		ByVal pBot As IrcBot Ptr, _
		ByVal User As WString Ptr, _
		ByVal Channel As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)As Boolean
	
	If lstrcmp(MessageText, @PingCommand) = 0 Then
		ProcessCtcpPingCommand(pBot, User, Channel)
		Return True
	End If
	
	If StartsWith(MessageText, @FenceCommand) Then
		ProcessFenceCommand(pBot, User, Channel, MessageText)
		Return True
	End If
	
	' Справка !справка
	If lstrcmp(MessageText, @HelpCommand1) = 0 OrElse lstrcmp(MessageText, @HelpCommand2) = 0 OrElse lstrcmp(MessageText, @HelpCommand3) = 0 Then
		pBot->Say(Channel, @AllUserCommands1)
		pBot->Say(Channel, @AllUserCommands2)
		Return True
	End If
	
	' Графика ASCII !ascii
	If StartsWith(MessageText, @AsciiCommand) Then
		Dim wParam As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
		If wParam <> 0 Then
			Dim hFile As HANDLE = CreateFile(@AsciiFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
			If hFile <> INVALID_HANDLE_VALUE Then
				
				wParam += 1
				If lstrlen(wParam) <> 0 Then
					
					Const MaxBufferLength As Integer = 65535
					
					' Буфер для хранения данных чтения
					Dim Buffer As ZString * (MaxBufferLength + SizeOf(WString)) = Any
					
					' Читаем данные файла
					Dim ReadBytesCount As DWORD = Any
					If ReadFile(hFile, @Buffer, MaxBufferLength, @ReadBytesCount, 0) <> 0 Then
						' Ставим нулевой символ, чтобы строка была валидной
						Buffer[ReadBytesCount] = 0
						Buffer[ReadBytesCount + 1] = 0
						
						' Будем считать, что кодировка текста UTF-16 с меткой BOM
						If ReadBytesCount > 2 Then
							If Buffer[0] = 255 AndAlso Buffer[1] = 254 Then
								
								Dim wLine As WString Ptr = CPtr(WString Ptr, @Buffer[2])
								Dim ReadedBytesCount As Integer = 0
								Dim Result2 As Integer = 1
								
								' Флаг того, что фразу нашли
								Dim FindFlag As Boolean = False
								
								Do
									
									' Найти в буфере CrLf
									Dim wCrLf As WString Ptr = StrStr(wLine, @vbCrLf)
									Do While wCrLf = NULL
										' Проверить буфер на переполнение
										If ReadedBytesCount >= MaxBufferLength Then
											' Буфер заполнен, будем читать данные в следующий раз
											Buffer[MaxBufferLength] = 0
											Buffer[MaxBufferLength + 1] = 0
											Exit Do
										End If
										
										' Если CrLf в буфере нет, то читать данные с файла
										Result2 = ReadFile(hFile, @Buffer + ReadedBytesCount, MaxBufferLength - ReadedBytesCount, @ReadBytesCount, 0)
										If Result2 = 0 OrElse ReadBytesCount = 0 Then
											' Ошибка или данные прочитаны, выйти
											Exit Do
										End If
										
										' Прочитанный байт всего
										ReadedBytesCount += ReadBytesCount
										' Ставим нулевой символ, чтобы строка была валидной
										Buffer[ReadBytesCount] = 0
										Buffer[ReadBytesCount + 1] = 0
										' Искать CrLf заново
										wCrLf = StrStr(wLine, @vbCrLf)
									Loop
									' CrLf найдено
									If wCrLf <> 0 Then
										wCrLf[0] = 0
									End If
									
									If FindFlag Then
										' Если пустая строка, то выйти из цикла
										If lstrlen(wLine) = 0 Then
											Exit Do
										End If
										
										' Отправить строку в чат
										pBot->SayWithTimeOut(Channel, wLine)
									End If
									
									' Сравнить со строкой
									If lstrcmp(wParam, wLine) = 0 Then
										' Найдено, теперь нужно отобразить в чат
										FindFlag = True
									End If
									
									' Переместить правее CrLf
									If wCrLf <> 0 Then
										wLine = wCrLf + 2
										' Передвинуть данные в буфере влево
										Dim tmpBuffer As ZString * (MaxBufferLength + SizeOf(WString)) = Any
										lstrcpy(CPtr(WString Ptr, @tmpBuffer), wLine)
										lstrcpy(CPtr(WString Ptr, @Buffer), CPtr(WString Ptr, @tmpBuffer))
										wLine = CPtr(WString Ptr, @Buffer)
									End If
									
									ReadedBytesCount = 0
								Loop While Result2 <> 0 And ReadBytesCount <> 0						
								
							End If
						End If
					End If
				End If
			End If
			CloseHandle(hFile)
		End If
		Return True
	End If
	
	' Команда !жуйк текст
	If StartsWith(MessageText, @JuickCommand) Then
		pBot->Say(Channel, @JuickCommandDone)
		Return True
	End If
	
	' Команда «чат, скажи:»
	Scope
		Dim ChatSayTextCommandLength As Integer = Any
		If StartsWith(MessageText, ChatSayTextCommand1) Then
			ChatSayTextCommandLength = 12
		Else
			If StartsWith(MessageText, ChatSayTextCommand2) Then
				ChatSayTextCommandLength = 5
			Else
				ChatSayTextCommandLength = 0
			End If
		End If
		
		If ChatSayTextCommandLength > 0 Then
			If StrStrI(MessageText, "http") <> 0 Then
				' IncrementUserWords(Channel, @BotNick)
				' eData->objClient.SendIrcMessage(Channel, @"Я не хочу отвечать на сообщения, содержащие ссылки.")
				Return True
			End If
			
			' Чат, скажи: ааа или ввв
			' Найти « или »
			Dim wOrString As WString Ptr = StrStrI(MessageText + ChatSayTextCommandLength, " или ")
			If wOrString <> 0 Then
				' Удалить пробел перед «или»
				wOrString[0] = 0
				
				Dim Buffer As WString * (IrcClient.MaxBytesCount + 1) = Any
				
				' Фраза «сделай»
				Scope
					Dim Number As Integer = pBot->ReceivedRawMessagesCounter Mod 10
					Select Case Number
						Case 0
							lstrcpy(@Buffer, "Конечно же ")
						Case 1
							lstrcpy(@Buffer, "Обязательно ")
						Case 2
							lstrcpy(@Buffer, "Наверное ")
						Case 3
							lstrcpy(@Buffer, "Не знаю насчёт ")
						Case 4
							lstrcpy(@Buffer, "Ни в коем случае не ")
						Case 5
							lstrcpy(@Buffer, "Было бы странным ")
						Case 6
							lstrcpy(@Buffer, "Тебя засмеют, если ")
						Case 7
							lstrcpy(@Buffer, "Ящитаю, что ")
						Case 8
							lstrcpy(@Buffer, "Мне нравится ")
						Case 9
							lstrcpy(@Buffer, "Ты зашкваришься, если ")
					End Select
				End Scope
				
				' Фраза из вопроса пользователя
				Scope
					Dim Number As Integer = pBot->ReceivedRawMessagesCounter Mod 2
					
					Select Case Number
						Case 0
							lstrcat(@Buffer, MessageText + ChatSayTextCommandLength)
							
						Case 1
							' Удалить знак вопроса
							Dim wQuestionMark As WString Ptr = StrChr(wOrString + 5, QuestionMarkChar)
							If wQuestionMark <> 0 Then
								wQuestionMark[0] = 0
							End If
							lstrcat(@Buffer, wOrString + 5)
							
					End Select
					
					lstrcat(@Buffer, ".")
				End Scope
				
				pBot->Say(Channel, @Buffer)
				Return True
			End If
		End If
	End Scope
	
	' Команда !таймер время сообщение
	If StartsWith(MessageText, @TimerCommand) Then
		Dim wSpace1 As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
		If wSpace1 = 0 Then
			pBot->Say(Channel, @"Интервал времени должен быть в диапазоне [1, 3600].")
			Return True
		End If
		wSpace1[0] = 0
		wSpace1 += 1
		
		Dim wSpace2 As WString Ptr = StrChr(wSpace1, WhiteSpaceChar)
		If wSpace2 = 0 Then
			pBot->Say(Channel, @"Необходимо указать сообщение.")
			Return True
		End If
		wSpace2[0] = 0
		wSpace2 += 1
		
		If StrStrI(wSpace2, "http") <> 0 Then
			pBot->Say(Channel, @"Я не хочу ставить таймер с сообщением, содержащим ссылки.")
			Return True
		End If
		
		' Проверить параметры
		Dim Seconds As LongInt = wtoi(wSpace1)
		If Seconds > 0 AndAlso Seconds <= 3600 Then
			Dim TimerName As WString * (IrcClient.MaxBytesCount + 1) = Any
			lstrcpy(@TimerName, "IrcBotTimers")
			lstrcat(@TimerName, User)
			
			' Выделить память
			Dim hMapFile As Handle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, SizeOf(TimerThreadParam), @TimerName)
			If hMapFile <> NULL Then
				
				If GetLastError() <> ERROR_ALREADY_EXISTS Then
					
					Dim ttp As TimerThreadParam Ptr = CPtr(TimerThreadParam Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TimerThreadParam)))
					If ttp <> 0 Then
						ttp->Interval = 1000 * Seconds
						ttp->hMapFile = hMapFile
						ttp->pBot = pBot
						lstrcpy(ttp->Channel, Channel)
						lstrcpy(ttp->TextToSend, User)
						lstrcat(ttp->TextToSend, ": ")
						lstrcat(ttp->TextToSend, wSpace2)
						
						Dim hThread As Handle = CreateThread(NULL, 0, @TimerAPCProc, ttp, 0, 0)
						If hThread <> NULL Then
							CloseHandle(hThread)
							pBot->Say(Channel, @CommandDone)
						Else
							UnmapViewOfFile(ttp)
							CloseHandle(hMapFile)
							pBot->Say(Channel, @"Не могу создать поток ожидания таймера")
						End If
					Else
						CloseHandle(hMapFile)
						pBot->Say(Channel, @"Не могу выделить память")
					End If
				Else
					CloseHandle(hMapFile)
				End If
			Else
				pBot->Say(Channel, @"Не могу создать отображение файла")
			End If
		Else
			pBot->Say(Channel, @"Интервал времени должен быть в диапазоне [1, 3600]")
		End If
		Return True
	End If
	
	' Статистика
	If lstrcmp(MessageText, @StatsCommand) = 0 Then
		Dim TimerName As WString * (IrcClient.MaxBytesCount + 1) = Any
		lstrcpy(@TimerName, "IrcBotStatistic")
		lstrcat(@TimerName, User)
		
		' Выделить память
		Dim hMapFile As Handle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, SizeOf(StatisticWordCountParam), @TimerName)
		If hMapFile <> NULL Then
			
			If GetLastError() <> ERROR_ALREADY_EXISTS Then
				
				Dim ttp As StatisticWordCountParam Ptr = CPtr(StatisticWordCountParam Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(StatisticWordCountParam)))
				If ttp <> 0 Then
					ttp->hMapFile = hMapFile
					ttp->pBot = pBot
					lstrcpy(ttp->UserName, User)
					lstrcpy(ttp->Channel, Channel)
					
					Dim hThread As Handle = CreateThread(NULL, 0, @StatisticWordCount, ttp, 0, 0)
					If hThread <> NULL Then
						CloseHandle(hThread)
					Else
						UnmapViewOfFile(ttp)
						CloseHandle(hMapFile)
						pBot->Say(Channel, @"Не могу создать поток получения статистики")
					End If
				Else
					CloseHandle(hMapFile)
					pBot->Say(Channel, @"Не могу выделить память")
				End If
			Else
				CloseHandle(hMapFile)
			End If
		Else
			pBot->Say(Channel, @"Не могу создать отображение файла")
		End If
		Return True
	End If
	
	' Добавление админа в список
	If lstrcmp(MessageText, @UserWhoIsCommand) = 0 Then
		lstrcpy(pBot->SavedChannel, Channel)
		lstrcpy(pBot->SavedUser, User)
		
		Dim Buffer As WString * (IrcClient.MaxBytesCount + 1) = Any
		lstrcpy(@Buffer, "WHOIS ")
		lstrcat(@Buffer, User)
		pBot->Client.SendRawMessage(@Buffer)
		Return True
	End If
	
	' Узнать длину пениса
	If StartsWith(MessageText, @PenisCommand) Then
		Dim PenisNick As WString Ptr = Any
		Dim wSpace1 As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
		If wSpace1 = 0 Then
			PenisNick = User
		Else
			PenisNick = wSpace1 + 1
		End If
		
		Dim Seed As Integer = 0
		Dim i As Integer = 0
		Do While PenisNick[i] <> 0
			Seed += PenisNick[i]
			i += 1
		Loop
		Dim Number As Integer = 8 + Seed Mod 13
		
		'Пенис у %user% длиной %Number% сантиметров, вот такой: 8====Э
		Dim Buffer As WString * (IrcClient.MaxBytesCount + 1) = Any
		lstrcpy(@Buffer, "Пенис у ")
		lstrcat(@Buffer, PenisNick)
		lstrcat(@Buffer, " длиной ")
		itow(Number, @Buffer + lstrlen(@Buffer), 10)
		lstrcat(@Buffer, " сантиметров, вот такой: 8")
		
		Select Case Number Mod 5
			Case 0
				lstrcat(@Buffer, "---")
			Case 1
				lstrcat(@Buffer, "----")
			Case 2
				lstrcat(@Buffer, ":::")
			Case 3
				lstrcat(@Buffer, "::::")
			Case 4
				lstrcat(@Buffer, "====")
		End Select
		lstrcat(@Buffer, "Э")
		
		pBot->Say(Channel, @Buffer)
		Return True
	End If
	
	' Игра крестики‐нолики
	
	' Игра в карты
	
	' Проверка заголовков какого‐нибудь http‐сервера
	
End Function