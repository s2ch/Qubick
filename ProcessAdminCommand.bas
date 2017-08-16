#include once "Bot.bi"
#include once "DateTimeToString.bi"
#include once "IntegerToWString.bi"
#include once "CharConstants.bi"
#include once "Settings.bi"

Function ProcessAdminCommand(ByVal eData As AdvancedData Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean
	' Разбить текст по пробелам
	Dim WordsCount As Long = Any
	Dim Lines As WString Ptr Ptr = CommandLineToArgvW(MessageText, @WordsCount)
	
	' Справка !справка
	If lstrcmp(Lines[0], @HelpCommand) = 0 Then
		eData->objClient.SendIrcMessage(User, @AllAdminCommands)
		ProcessAdminCommand = True
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
		' ProcessAdminCommand = True
	End If
	
	' Смена ника !ник новыйник
	If lstrcmp(Lines[0], @NickCommand) = 0 Then
		eData->objClient.ChangeNick(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
		ProcessAdminCommand = True
	End If
	
	' Присоединение к каналу !зайди channel
	If lstrcmp(Lines[0], @JoinCommand) = 0 Then
		eData->objClient.JoinChannel(Lines[1])
		eData->objClient.SendIrcMessage(User, @CommandDone)
		ProcessAdminCommand = True
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
		ProcessAdminCommand = True
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
		ProcessAdminCommand = True
	End If
	
	' Сырое сообщение !ну текст
	If lstrcmp(Lines[0], @RawCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			eData->objClient.SendRawMessage(@w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
		ProcessAdminCommand = True
	End If
	
	' Установить пароль на никсерв !пароль текст
	If lstrcmp(Lines[0], @PasswordCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			If SetSettingsValue(@PasswordKey, w) Then
				eData->objClient.SendIrcMessage(User, @CommandDone)
			End If
		End If
		ProcessAdminCommand = True
	End If
	
	' Сказать в чат !скажи канал текст сообщения
	If lstrcmp(Lines[0], @SayCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			eData->objClient.SendIrcMessage(Lines[1], @w[1])
			eData->objClient.SendIrcMessage(User, @CommandDone)
		End If
		ProcessAdminCommand = True
	End If
	
	' Выполнить программу !делай "команда" "параметры"
	If lstrcmp(Lines[0], @ExecuteCommand) = 0 Then
		REM ShellExecute(0, command, filename, param, dir, show_cmd)
		If WordsCount > 2 Then
			ShellExecute(0, 0, Lines[1], Lines[2], 0, 0)
		Else
			eData->objClient.SendIrcMessage(User, @"Недостаточно параметров для запуска приложения")
		End If
		ProcessAdminCommand = True
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
		ProcessAdminCommand = True
	End If
	
	' Показать список ключевых фраз !вопросы
	If lstrcmp(Lines[0], @QuestionListCommand) = 0 Then
		GetQuestionList(eData, User)
		ProcessAdminCommand = True
	End If
	
	' Добавить ключевую фразу !вопрос фраза
	If lstrcmp(Lines[0], @AddQuestionCommand) = 0 Then
		If WordsCount > 1 Then
			Dim w As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
			AddQuestion(eData, User, @w[1])
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
		ProcessAdminCommand = True
	End If
	
	' Добавить ответ !ответ номер‐вопроса фраза
	If lstrcmp(Lines[0], @AddAnswerCommand) = 0 Then
		If WordsCount > 2 Then
			Dim w As WString Ptr = StrChr((StrChr(MessageText, WhiteSpaceChar))[1], WhiteSpaceChar)
			AddAnswer(eData, User, wtoi(Lines[1]), @w[1])
		End If
		eData->objClient.SendIrcMessage(User, @CommandDone)
		ProcessAdminCommand = True
	End If
	
	' Показать список ключевых фраз
	If lstrcmp(Lines[0], @QuestionListCommand) = 0 Then
		GetQuestionList(eData, User)
		ProcessAdminCommand = True
	End If
	
	' Показать список ответов
	' Const  = "!ответы"
	If lstrcmp(Lines[0], @AnswerListCommand) = 0 Then
		If WordsCount > 1 Then
			GetAnswerList(eData, User, wtoi(Lines[1]))
		End If
		ProcessAdminCommand = True
	End If
	
	LocalFree(Lines)
End Function
