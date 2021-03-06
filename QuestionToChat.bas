#include once "QuestionToChat.bi"
#include once "IntegerToWString.bi"
#include once "CharConstants.bi"
#include once "Settings.bi"

Const QuestionsWhereCount As Integer = 10
Const QuestionsWhereString0 = "Может, в стиральной машине?"
Const QuestionsWhereString1 = "Может во Флориде?"
Const QuestionsWhereString2 = "Я думаю, это где‐то в Америке."
Const QuestionsWhereString3 = "Подожди… Я пороюсь в атласе."
Const QuestionsWhereString4 = "В Германии. Я точно знаю, потому что был там."
Const QuestionsWhereString5 = "Прямо на небесах."
Const QuestionsWhereString6 = "На скотном дворе."
Const QuestionsWhereString7 = "Сам догадайся."
Const QuestionsWhereString8 = "В Белом Доме или Пентагоне."
Const QuestionsWhereString9 = "Последний раз я его видел в нижнем белье."

Const QuestionsWhereFromCount As Integer = 10
Const QuestionsWhereFromString0 = "Оттуда."
Const QuestionsWhereFromString1 = "Оттуда, откуда обычно не возвращаются, но мне дали второй шанс за особые заслуги."
Const QuestionsWhereFromString2 = "Из тех же ворот, откель и весь народ."
Const QuestionsWhereFromString3 = "Насосал."
Const QuestionsWhereFromString4 = "С небес упало."
Const QuestionsWhereFromString5 = "Из интернетов."
Const QuestionsWhereFromString6 = "Омпитудо!"
Const QuestionsWhereFromString7 = "Ты должен сам знать."
Const QuestionsWhereFromString8 = "Из будущего."
Const QuestionsWhereFromString9 = "Я не желаю отвечать на этот вопрос."

Const QuestionsWhere2Count As Integer = 11
Const QuestionsWhere2String0 = "Туда."
Const QuestionsWhere2String1 = "Куда послали, туда и иди."
Const QuestionsWhere2String2 = "Пойдём со мной, узнаешь. Только потом не говори, что Я тебя не предупреждал."
Const QuestionsWhere2String3 = "Иду куда глаза глядят, и пока ноги несут."
Const QuestionsWhere2String4 = "Ага, а может быть пароль на мой сервер сказать?"
Const QuestionsWhere2String5 = "Щас приду."
Const QuestionsWhere2String6 = "Я сегодня на репетицию опоздал с утра, надо хоть сейчас успеть. Я там помогаю накачивать шины клубничным силиконом, пока охотник читает газету."
Const QuestionsWhere2String7 = "Вас туда не пустют."
Const QuestionsWhere2String8 = "В серверную."
Const QuestionsWhere2String9 = "В интернет."
Const QuestionsWhere2String10 = "Такие как ты только и делают, что спрашивают!"

Const QuestionsWhenCount As Integer = 10
Const QuestionsWhenString0 = "Завтра."
Const QuestionsWhenString1 = "Вчера."
Const QuestionsWhenString2 = "Это было в 1900."
Const QuestionsWhenString3 = "Ты будешь слишком стар, когда это будет."
Const QuestionsWhenString4 = "Давно это было…"
Const QuestionsWhenString5 = "Во времена DialUp."
Const QuestionsWhenString6 = "А когда ты родился?"
Const QuestionsWhenString7 = "Когда ты первый раз побрился."
Const QuestionsWhenString8 = "Сейчас."
Const QuestionsWhenString9 = "Тогда, когда наступит нечётное воскресенье."

Const QuestionsQCount As Integer = 18
Const QuestionsQString0 = "Я так думаю."
Const QuestionsQString1 = "А что ты думаешь?"
Const QuestionsQString2 = "Да."
Const QuestionsQString3 = "Нет."
Const QuestionsQString4 = "Все знают, что нет."
Const QuestionsQString5 = "Наверное."
Const QuestionsQString6 = "Да нет, наверное."
Const QuestionsQString7 = "Не уверен."
Const QuestionsQString8 = "Да конечно."
Const QuestionsQString9 = "Все знают, что да."
Const QuestionsQString10 = "Я устал, поговорим завтра."
Const QuestionsQString11 = "Ну… как тебе сказать…"
Const QuestionsQString12 = "Любопытный вопрос. Кто‐то уже спрашивал."
Const QuestionsQString13 = "Нехороший вопрос."
Const QuestionsQString14 = "Ты хочешь знать, что Я думаю об этом?"
Const QuestionsQString15 = "Я не хочу говорить об этом."
Const QuestionsQString16 = "Извини, забыл."
Const QuestionsQString17 = "Терпеть не могу любопытных людей."

Const QuestionsWhyCount As Integer = 10
Const QuestionsWhyString0 = "Потому что кончается на «У», дурочка!"
Const QuestionsWhyString1 = "Открой энциклопедию!"
Const QuestionsWhyString2 = "Я не знаю."
Const QuestionsWhyString3 = "Я так хочу!"
Const QuestionsWhyString4 = "Спроси тётю квАсю."
Const QuestionsWhyString5 = "Ну ты попроще задавай вопросы."
Const QuestionsWhyString6 = "Я не помню."
Const QuestionsWhyString7 = "Ты не помнишь, потому что у тебя голова с вентиляцией, все мысли проветриваются."
Const QuestionsWhyString8 = "Поясни вопрос."
Const QuestionsWhyString9 = "А почему ты не спросишь об этом маму?"

Const QuestionsHowManyCount As Integer = 11
Const QuestionsHowManyString0 = "Столько, колько нужно."
Const QuestionsHowManyString1 = "Ну… посчитай сам. Математику уже затем учить надо, что она ум в порядок приводит."
Const QuestionsHowManyString2 = "Подожди… есть калькулятор?"
Const QuestionsHowManyString3 = "x = ((25 + 43) / 489.4561) + ((156 - 456) * 956) ^ (153.654 * (654 / 6987))"
Const QuestionsHowManyString4 = "Вычислять??? Ну уж нет! У тебя и без меня вирусов в системном блоке полно."
Const QuestionsHowManyString5 = "Четырнадцать."
Const QuestionsHowManyString6 = "А ты сам сможешь сказать, сколько дней прошло как ты родился?"
Const QuestionsHowManyString7 = "Ну я вам что, математик?"
Const QuestionsHowManyString8 = "&h00FF15D395"
Const QuestionsHowManyString9 = "Вскрытие покажет сколько, где, с кем и в какой позе."
Const QuestionsHowManyString10 = "265!"

Const QuestionsWhoCount As Integer = 11
Const QuestionsWhoString0 = "Ты!"
Const QuestionsWhoString1 = "Тот, кто тебя не боится."
Const QuestionsWhoString2 = "Ты не думаешь, что это тётя Ася?"
Const QuestionsWhoString3 = "Чужой с планеты Хоумуолд."
Const QuestionsWhoString4 = "Какая‐то мошенническая учётная запись. Рекомендую вообще удалить данный аккуант."
Const QuestionsWhoString5 = "Я."
Const QuestionsWhoString6 = "Врач‐гинеколог."
Const QuestionsWhoString7 = "Конь в кожаном пальто."
Const QuestionsWhoString8 = "Кот педальный!"
Const QuestionsWhoString9 = "Анна Курникова."
Const QuestionsWhoString10 = "Саша Грей."

' Вопросы:
Enum Questions
	' Без вопроса
	None
	' Где
	Where
	' Откуда
	WhereFrom
	' Куда
	Where2
	' Когда
	When
	' Как
	How
	' Почему
	Why
	' Сколько
	HowMany
	' Кто
	Who
	' Ник бота
	QuestionsQ
	
	' Что
	What
	' Чей
	Whose
	' Зачем
	Wozu
End Enum

Function GetQuestionsWhere(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhereString1
		Case 1
			Return @QuestionsWhereString2
		Case 2
			Return @QuestionsWhereString3
		Case 3
			Return @QuestionsWhereString4
		Case 4
			Return @QuestionsWhereString5
		Case 5
			Return @QuestionsWhereString6
		Case 6
			Return @QuestionsWhereString7
		Case 7
			Return @QuestionsWhereString8
		Case 8
			Return @QuestionsWhereString9
		Case Else
			Return @QuestionsWhereString0
	End select
End Function

Function GetQuestionsWhereFrom(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhereFromString1
		Case 1
			Return @QuestionsWhereFromString2
		Case 2
			Return @QuestionsWhereFromString3
		Case 3
			Return @QuestionsWhereFromString4
		Case 4
			Return @QuestionsWhereFromString5
		Case 5
			Return @QuestionsWhereFromString6
		Case 6
			Return @QuestionsWhereFromString7
		Case 7
			Return @QuestionsWhereFromString8
		Case 8
			Return @QuestionsWhereFromString9
		Case Else
			Return @QuestionsWhereFromString0
	End select
End Function

Function GetQuestionsWhere2(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhere2String1
		Case 1
			Return @QuestionsWhere2String2
		Case 2
			Return @QuestionsWhere2String3
		Case 3
			Return @QuestionsWhere2String4
		Case 4
			Return @QuestionsWhere2String5
		Case 5
			Return @QuestionsWhere2String6
		Case 6
			Return @QuestionsWhere2String7
		Case 7
			Return @QuestionsWhere2String8
		Case 8
			Return @QuestionsWhere2String9
		Case 9
			Return @QuestionsWhere2String10
		Case Else
			Return @QuestionsWhere2String0
	End select
End Function

Function GetQuestionsWhen(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhenString1
		Case 1
			Return @QuestionsWhenString2
		Case 2
			Return @QuestionsWhenString3
		Case 3
			Return @QuestionsWhenString4
		Case 4
			Return @QuestionsWhenString5
		Case 5
			Return @QuestionsWhenString6
		Case 6
			Return @QuestionsWhenString7
		Case 7
			Return @QuestionsWhenString8
		Case 8
			Return @QuestionsWhenString9
		Case Else
			Return @QuestionsWhenString0
	End select
End Function

Function GetQuestionsQ(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsQString1
		Case 1
			Return @QuestionsQString2
		Case 2
			Return @QuestionsQString3
		Case 3
			Return @QuestionsQString4
		Case 4
			Return @QuestionsQString5
		Case 5
			Return @QuestionsQString6
		Case 6
			Return @QuestionsQString7
		Case 7
			Return @QuestionsQString8
		Case 8
			Return @QuestionsQString9
		Case 9
			Return @QuestionsQString10
		Case 10
			Return @QuestionsQString11
		Case 11
			Return @QuestionsQString12
		Case 12
			Return @QuestionsQString13
		Case 13
			Return @QuestionsQString14
		Case 14
			Return @QuestionsQString15
		Case 15
			Return @QuestionsQString16
		Case 16
			Return @QuestionsQString17
		Case Else
			Return @QuestionsQString0
	End select
End Function

Function GetQuestionsWhy(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhyString1
		Case 1
			Return @QuestionsWhyString2
		Case 2
			Return @QuestionsWhyString3
		Case 3
			Return @QuestionsWhyString4
		Case 4
			Return @QuestionsWhyString5
		Case 5
			Return @QuestionsWhyString6
		Case 6
			Return @QuestionsWhyString7
		Case 7
			Return @QuestionsWhyString8
		Case 8
			Return @QuestionsWhyString9
		Case Else
			Return @QuestionsWhyString0
	End select
End Function

Function GetQuestionsHowMany(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsHowManyString1
		Case 1
			Return @QuestionsHowManyString2
		Case 2
			Return @QuestionsHowManyString3
		Case 3
			Return @QuestionsHowManyString4
		Case 4
			Return @QuestionsHowManyString5
		Case 5
			Return @QuestionsHowManyString6
		Case 6
			Return @QuestionsHowManyString7
		Case 7
			Return @QuestionsHowManyString8
		Case 8
			Return @QuestionsHowManyString9
		Case 9
			Return @QuestionsHowManyString10
		Case Else
			Return @QuestionsHowManyString0
	End select
End Function

Function GetQuestionsWho(ByVal Number As Integer)As WString Ptr
	Select Case Number
		Case 0
			Return @QuestionsWhoString1
		Case 1
			Return @QuestionsWhoString2
		Case 2
			Return @QuestionsWhoString3
		Case 3
			Return @QuestionsWhoString4
		Case 4
			Return @QuestionsWhoString5
		Case 5
			Return @QuestionsWhoString6
		Case 6
			Return @QuestionsWhoString7
		Case 7
			Return @QuestionsWhoString8
		Case 8
			Return @QuestionsWhoString9
		Case 9
			Return @QuestionsWhoString10
		Case Else
			Return @QuestionsWhoString0
	End select
End Function

Function GetQuestions(ByVal w As WString Ptr, ByVal BotNick As WString Ptr)As Questions
	If StrStrI(w, "где ") = w Then
		Return Questions.Where
	End If
	If StrStrI(w, "откуда ") = w Then
		Return Questions.WhereFrom
	End If
	If StrStrI(w, "куда ") = w Then
		Return Questions.Where2
	End If
	If StrStrI(w, "когда ") = w Then
		Return Questions.When
	End If
	If StrStrI(w, "как ") = w Then
		Return Questions.How
	End If
	If StrStrI(w, "почему ") = w Then
		Return Questions.Why
	End If
	If StrStrI(w, "сколько ") = w Then
		Return Questions.HowMany
	End If
	If StrStrI(w, "кто ") = w Then
		Return Questions.Who
	End If
	If StrStrI(w, "что ") = w Then
		Return Questions.What
	End If
	If StrStrI(w, "чей ") = w Then
		Return Questions.Whose
	End If
	If StrStrI(w, "зачем ") = w Then
		Return Questions.Wozu
	End If
	If StrStrI(w, BotNick) = w Then
		Return Questions.QuestionsQ
	End If
	
	Return Questions.None
End Function

Function QuestionToChat(ByVal pBot As IrcBot Ptr, ByVal User As WString Ptr, ByVal MessageText As WString Ptr)As Boolean
	
	' Последний символ должен быть вопросом
	Dim MessageTextLength As Integer = lstrlen(MessageText)
	If MessageTextLength = 0 Then
		Return False
	End If
	
	Dim wQuestionMark As WString Ptr = StrChr(MessageText, QuestionMarkChar)
	If wQuestionMark <> 0 Then
		
		Select Case GetQuestions(MessageText, pBot->BotNick)
			Case Questions.Where
				' Где
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhereCount
				pBot->Say(User, GetQuestionsWhere(AnswerIndex))
				Return True
				
			Case Questions.WhereFrom
				' Откуда
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhereFromCount
				pBot->Say(User, GetQuestionsWhereFrom(AnswerIndex))
				Return True
				
			Case Questions.Where2
				' Куда
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhere2Count
				pBot->Say(User, GetQuestionsWhere2(AnswerIndex))
				Return True
				
			Case Questions.When
				' Когда
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhenCount
				pBot->Say(User, GetQuestionsWhen(AnswerIndex))
				Return True
				
			Case Questions.How
				' Как
				
			Case Questions.Why
				' Почему
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhyCount
				pBot->Say(User, GetQuestionsWhy(AnswerIndex))
				Return True
				
			Case Questions.HowMany
				' Сколько
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsHowManyCount
				pBot->Say(User, GetQuestionsHowMany(AnswerIndex))
				Return True
				
			Case Questions.Who
				' Кто
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsWhoCount
				pBot->Say(User, GetQuestionsWho(AnswerIndex))
				Return True
				
			Case Questions.QuestionsQ
				' Ник бота
				Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsQCount
				pBot->Say(User, GetQuestionsQ(AnswerIndex))
				Return True
				
			Case Questions.What
				' Что
				
			Case Questions.Whose
				' Чей
				
			Case Questions.Wozu
				' Зачем
				
			Case Else
				' Любой другой вопрос
				If StrStrI(MessageText, pBot->BotNick) = MessageText Then
					Dim AnswerIndex As Integer = pBot->ReceivedRawMessagesCounter Mod QuestionsQCount
					pBot->Say(User, GetQuestionsQ(AnswerIndex))
					Return True
				End If
				
		End Select
	End If
	
	Return False
	
End Function
