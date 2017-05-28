#define unicode
#include once "windows.bi"

#ifdef service

Declare Sub ReportSvcStatus(ByVal dwCurrentState As DWORD, ByVal dwWin32ExitCode As DWORD, ByVal dwWaitHint As DWORD)
Declare Sub SvcMain(ByVal dwNumServicesArgs As DWORD, ByVal lpServiceArgVectors As LPWSTR Ptr)
Declare Sub SvcCtrlHandler(ByVal dwCtrl As DWORD)
' Функция сервисного потока
Declare Function ServiceProc(ByVal lpParam As LPVOID)As DWORD

' Имя службы
Const ServiceName = "IrcBot"

' Состояние службы
Dim Shared gSvcStatus As SERVICE_STATUS
' идентификатор службы
Dim Shared gSvcStatusHandle As SERVICE_STATUS_HANDLE
' Событие
Dim Shared ghSvcStopEvent As HANDLE
' Счётчик длительных операций
Dim Shared dwCheckPoint As DWORD

' Идентификатор потока запуска соединений с сервером
Dim Shared hThreadLoop As HANDLE


Function EntryPoint Alias "EntryPoint"()As Integer
	Dim DispatchTable(1) As SERVICE_TABLE_ENTRY = Any
	DispatchTable(0).lpServiceName = @ServiceName
	DispatchTable(0).lpServiceProc = @SvcMain
	DispatchTable(1).lpServiceName = 0
	DispatchTable(1).lpServiceProc = 0

	' Вызов функции StartServiceCtrlDispatcher возвращает значение когда служба завершится
	StartServiceCtrlDispatcher(@DispatchTable(0))
	Return 0
End Function

' Точка входа службы
' Параметры:
' dwArgc — количество аргументов командной строки
' lpszArgv — массив аргументов командной строки
Sub SvcMain(ByVal dwNumServicesArgs As DWORD, ByVal lpServiceArgVectors As LPWSTR Ptr)
	' Регистрация функции‐обработчика сообщений от контроллёра
	gSvcStatusHandle = RegisterServiceCtrlHandler(@ServiceName, @SvcCtrlHandler)
	If gSvcStatusHandle = 0 Then
		' Какая‐то ошибка
		Exit Sub
	End If
	
	' Заполнить структуру SERVICE_STATUS
	gSvcStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS
	gSvcStatus.dwServiceSpecificExitCode = 0
	
	' Сообщить контроллёру, что служба ожидает
	ReportSvcStatus(SERVICE_START_PENDING, NO_ERROR, 3000)
	
	' TODO Добавить необходимых инициализаций
	' Необходимо периодически сообщать контроллёру SERVICE_START_PENDING
	' чтобы контроллёр не считал службу зависшей
	' Если инициализация не удалась необходимо
	' сообщить контроллёру SERVICE_STOPPED
	
	' Событие, которое будем ожидать для завершения службы
	ghSvcStopEvent = CreateEvent(NULL, _ /' атрибуты безопасности по умолчанию '/
		TRUE, _ /' ручное сбрасывание '/
		FALSE, _ /' событие ещё не произошло '/
		NULL) /' без имени '/
	
	' Если событие не создано, то сообщить контроллёру,
	' что служба остановлена и выйти
	If ghSvcStopEvent = NULL Then
		ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	
	ReportSvcStatus(SERVICE_START_PENDING, NO_ERROR, 3000)
	
	Dim ThreadId As DWord = Any
	hThreadLoop = CreateThread(NULL, 0, @ServiceProc, 0, 0, @ThreadId)
	If hThreadLoop = NULL Then
		ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
		Exit Sub
	End If
	' CloseHandle(hThreadLoop)
	
	' Сообщить контроллёру, что служба запущена
	ReportSvcStatus(SERVICE_RUNNING, NO_ERROR, 0)
	
	' Ожидать до тех пор, пока служба не остновится
	WaitForSingleObject(ghSvcStopEvent, INFINITE)
	ReportSvcStatus(SERVICE_STOPPED, NO_ERROR, 0)
End Sub

' Вызывается контроллёром и отправляет управляющий код службе
' Параметры:
' dwCtrl — управляющий код
Sub SvcCtrlHandler(ByVal dwCtrl As DWORD)
	' Эти коды могут поступать в любом порядке,
	' даже если предыдущие операции не завершены
	Select Case dwCtrl
		Case SERVICE_CONTROL_INTERROGATE
			ReportSvcStatus(gSvcStatus.dwCurrentState, NO_ERROR, 0)
		Case SERVICE_CONTROL_STOP
			' Код остановки службы
			ReportSvcStatus(SERVICE_STOP_PENDING, NO_ERROR, 0)
			' Остановить событие
			SetEvent(ghSvcStopEvent)
		Case Else
			' Обработка собственных кодов
	End Select
End Sub

' Сообщение котроллёру состояния службы
' Параметры:
' dwCurrentState — текущее состояние службы
' dwWin32ExitCode — код ошибки
' dwWaitHint — расчётное время операции, в миллисекундах
Sub ReportSvcStatus(ByVal dwCurrentState As DWORD, ByVal dwWin32ExitCode As DWORD, ByVal dwWaitHint As DWORD)
	' Заполнить структуру SERVICE_STATUS
	gSvcStatus.dwCurrentState = dwCurrentState
	gSvcStatus.dwWin32ExitCode = dwWin32ExitCode
	gSvcStatus.dwWaitHint = dwWaitHint
	
	If dwCurrentState = SERVICE_START_PENDING Then
		gSvcStatus.dwControlsAccepted = 0
	Else
		gSvcStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP
	End If
	
	If dwCurrentState = SERVICE_RUNNING Or dwCurrentState = SERVICE_STOPPED Then
		gSvcStatus.dwCheckPoint = 0
	Else
		dwCheckPoint += 1
		gSvcStatus.dwCheckPoint = dwCheckPoint
	End If
	
	' Сообщить состояние службы контроллёру
	SetServiceStatus(gSvcStatusHandle, @gSvcStatus)
End Sub

#endif

