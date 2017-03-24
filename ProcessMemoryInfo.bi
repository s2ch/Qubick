#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "win\psapi.bi"

Type ProcessMemoryInfo
	Dim PageFaultCount As WString * 100
	Dim PeakWorkingSetSize As WString * 100
	Dim WorkingSetSize As WString * 100
	' Dim QuotaPeakPagedPoolUsage As WString * 100
	' Dim QuotaPagedPoolUsage As WString * 100
	' Dim QuotaPeakNonPagedPoolUsage As WString * 100
	' Dim QuotaNonPagedPoolUsage As WString * 100
	Dim PagefileUsage As WString * 100
	Dim PeakPagefileUsage As WString * 100
	Dim PrivateUsage As WString * 100
End Type

Declare Function GetMemoryInfo(ByVal ProcessData As ProcessMemoryInfo Ptr, ByVal processID As DWORD)As Boolean

