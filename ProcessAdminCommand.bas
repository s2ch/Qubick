#include once "Bot.bi"
#include once "win\tlhelp32.bi"
#include once "DateTimeToString.bi"
#include once "ProcessMemoryInfo.bi"
#include once "IntegerToWString.bi"

Function ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean
	' Разбить текст по пробелам
	Dim WordsCount As Long = Any
	Dim Lines As WString Ptr Ptr = CommandLineToArgvW(MessageText, @WordsCount)
	
	' Справка !справка
	If lstrcmp(Lines[0], @HelpCommand) = 0 Then
		eData->objClient.SendIrcMessage(User, @AllAdminCommands)
	End If
	
	' Выход из сети !сгинь причина выхода из сети
	If lstrcmp(Lines[0], @QuitCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			eData->objClient.QuitFromServer(@w[1])
		Else
			Dim strQuitString As WString * SizeOf(WString)
			eData->objClient.QuitFromServer(@strQuitString)
		End If
		ExitProcess(0)
	End If
	
	' Смена ника !ник новыйник
	If lstrcmp(Lines[0], @NickCommand) = 0 Then
		eData->objClient.ChangeNick(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Присоединение к каналу !зайди channel
	If lstrcmp(Lines[0], @JoinCommand) = 0 Then
		eData->objClient.JoinChannel(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Отключение от канала !выйди channel причина выхода
	If lstrcmp(Lines[0], @PartCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			eData->objClient.PartChannel(Lines[1], @w[1])
		Else
			Dim strQuitString As WString * SizeOf(WString)
			eData->objClient.PartChannel(Lines[1], @strQuitString)
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Смена темы канала !тема канал новая тема канала
	If lstrcmp(Lines[0], @TopicCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			eData->objClient.ChangeTopic(Lines[1], @w[1])
		Else
			' Очистить тему
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Сырое сообщение !ну текст
	If lstrcmp(Lines[0], @RawCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			eData->objClient.SendRawMessage(@w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
	End If
	
	' Сказать в чат !скажи канал текст сообщения
	If lstrcmp(Lines[0], @SayCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			eData->objClient.SendIrcMessage(Lines[1], @w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
	End If
	
	' Выполнить программу !делай "команда" "параметры"
	If lstrcmp(Lines[0], @ExecuteCommand) = 0 Then
		REM ShellExecute(0, command, filename, param, dir, show_cmd)
		If WordsCount > 2 Then
			ShellExecute(0, 0, Lines[1], Lines[2], 0, 0)
		Else
			eData->objClient.SendIrcMessage(User, @"Недостаточно параметров для запуска приложения")
		End If
	End If
	
	' Команда !процессы
	If lstrcmp(Lines[0], @ProcessesListCommand) = 0 Then
		' Показать список всех процессов
		Dim hProcessSnap As HANDLE = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		If hProcessSnap = INVALID_HANDLE_VALUE Then
			eData->objClient.SendIrcMessage(User, @"Не могу создать список процессов")
		Else
			Dim pe32 As PROCESSENTRY32 = Any
			pe32.dwSize = SizeOf(PROCESSENTRY32)
			If Process32First(hProcessSnap, @pe32) = 0 Then
				eData->objClient.SendIrcMessage(User, @"Ошибка в функции Process32First")
			Else
				Do
					' Идентификатор процесса
					Dim strProcessID As WString * 100 = Any
					itow(pe32.th32ProcessID, @strProcessID, 10)
					
					' Имя исполняемого файла
					Dim strProcessName As WString * (IrcClient.MaxBytesCount + 1) = Any
					lstrcpy(@strProcessName, @pe32.szExeFile)
					lstrcat(@strProcessName, @" ")
					lstrcat(@strProcessName, @strProcessID)
					
					eData->objClient.SendIrcMessage(User, @strProcessName)
					SleepEx(MessageTimeWait, 0)
				Loop While Process32Next(hProcessSnap, @pe32) <> 0
			End If
			CloseHandle(hProcessSnap)
		End If
	End If
	
	' Команда !инфо ID процесса
	If lstrcmp(Lines[0], @ProcessInfoCommand) = 0 Then
		' Вывести информацию о процессе
		Dim ProcessData As ProcessMemoryInfo = Any
		If WordsCount > 1 Then
			If GetMemoryInfo(@ProcessData, wtoi(Lines[1])) Then
				Dim strCounter As WString * (IrcClient.MaxBytesCount + 1) = Any
				
				lstrcpy(@strCounter, "Ошибок страниц ")
				lstrcat(@strCounter, ProcessData.PageFaultCount)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Рабочее множество ")
				lstrcat(@strCounter, ProcessData.WorkingSetSize)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Пик рабочего множества ")
				lstrcat(@strCounter, ProcessData.PeakWorkingSetSize)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Виртуальная память ")
				lstrcat(@strCounter, ProcessData.PagefileUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Пик виртуальной памяти ")
				lstrcat(@strCounter, ProcessData.PeakPagefileUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
				
				lstrcpy(@strCounter, "Собственные байты ")
				lstrcat(@strCounter, ProcessData.PrivateUsage)
				eData->objClient.SendIrcMessage(User, @strCounter)
				SleepEx(MessageTimeWait, 0)
			Else
				eData->objClient.SendIrcMessage(User, @"Не могу получить информацию о процессе")
			End If
		Else
			eData->objClient.SendIrcMessage(User, @"Для отображения информации о памяти процесса нужен его ID")
		End If
	End If
	
	' Команда !считай текст
	If lstrcmp(Lines[0], @CalculateCommand) = 0 Then
		If WordsCount > 1 Then
			Dim wCalc As WString Ptr = @(StrChr(MessageText, WhiteSpaceChar))[1]
			' Создать файл, записать в него текст
			' Print 
			' Скомпилировать
			' Создать процесс, перенаправить вывод к себе
			' Отправить вывод в чат
		Else
			Dim strQuitString As WString * SizeOf(WString)
			' eData->objClient.QuitFromServer(@strQuitString)
		End If
	End If
	
	' Показать список ключевых фраз !вопросы
	If lstrcmp(Lines[0], @QuestionListCommand) = 0 Then
		GetQuestionList(eData, User)
	End If
	
	' Добавить ключевую фразу !вопрос фраза
	If lstrcmp(Lines[0], @AddQuestionCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			AddQuestion(eData, User, @w[1])
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Добавить ответ !ответ номер‐вопроса фраза
	If lstrcmp(Lines[0], @AddAnswerCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			AddAnswer(eData, User, wtoi(Lines[1]), @w[1])
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
	End If
	
	' Показать список ключевых фраз
	If lstrcmp(Lines[0], @QuestionListCommand) = 0 Then
		GetQuestionList(eData, User)
	End If
	
	' Показать список ответов
	' Const  = "!ответы"
	If lstrcmp(Lines[0], @AnswerListCommand) = 0 Then
		If WordsCount > 1 Then
			GetAnswerList(eData, User, wtoi(Lines[1]))
		End If
	End If
	
	LocalFree(Lines)
	Return True
End Function
