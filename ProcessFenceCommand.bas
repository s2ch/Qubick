#include once "ProcessFenceCommand.bi"
#include once "CharConstants.bi"

Sub ProcessFenceCommand( _
		ByVal pBot As IrcBot Ptr, _
		ByVal User As WString Ptr, _
		ByVal Channel As WString Ptr, _
		ByVal MessageText As WString Ptr _
	)
	
	If StrStrI(MessageText, "http") Then
		Exit Sub
	End If
	
	Dim wSpace1 As WString Ptr = StrChr(MessageText, WhiteSpaceChar)
	If wSpace1 = 0 Then
		Exit Sub
	End If
	
	Dim FenceText As WString Ptr = wSpace1 + 1
	Dim FenceTextLength As Integer = lstrlen(FenceText)
	If FenceTextLength = 0 Then
		Exit Sub
	End If
	
	For i As Integer = 0 To FenceTextLength - 1
		Dim wChar As Integer = FenceText[i]
		If i Mod 2 = 0 Then
			Select Case wChar
				Case &h401 ' Ё
					wChar = &h451
				Case &h410 ' А
					wChar = &h430
				Case &h411
					wChar = &h431
				Case &h412
					wChar = &h432
				Case &h413
					wChar = &h433
				Case &h414
					wChar = &h434
				Case &h415
					wChar = &h435
				Case &h416
					wChar = &h436
				Case &h417
					wChar = &h437
				Case &h418
					wChar = &h438
				Case &h419
					wChar = &h439
				Case &h41A
					wChar = &h43A
				Case &h41B
					wChar = &h43B
				Case &h41C
					wChar = &h43C
				Case &h41D
					wChar = &h43D
				Case &h41E
					wChar = &h43E
				Case &h41F
					wChar = &h43F
				Case &h420
					wChar = &h440
				Case &h421
					wChar = &h441
				Case &h422
					wChar = &h442
				Case &h423
					wChar = &h443
				Case &h424
					wChar = &h444
				Case &h425
					wChar = &h445
				Case &h426
					wChar = &h446
				Case &h427
					wChar = &h447
				Case &h428
					wChar = &h448
				Case &h429
					wChar = &h449
				Case &h42A
					wChar = &h44A
				Case &h42B
					wChar = &h44B
				Case &h42C
					wChar = &h44C
				Case &h42D
					wChar = &h44D
				Case &h42E
					wChar = &h44E
				Case &h42F
					wChar = &h44F
			End Select
		Else
			Select Case wChar
				Case &h451 ' Ё
					wChar = &h401
				Case &h430 ' А
					wChar = &h410
				Case &h431
					wChar = &h411
				Case &h432
					wChar = &h412
				Case &h433
					wChar = &h413
				Case &h434
					wChar = &h414
				Case &h435
					wChar = &h415
				Case &h436
					wChar = &h416
				Case &h437
					wChar = &h417
				Case &h438
					wChar = &h418
				Case &h439
					wChar = &h419
				Case &h43A
					wChar = &h41A
				Case &h43B
					wChar = &h41B
				Case &h43C
					wChar = &h41C
				Case &h43D
					wChar = &h41D
				Case &h43E
					wChar = &h41E
				Case &h43F
					wChar = &h41F
				Case &h440
					wChar = &h420
				Case &h441
					wChar = &h421
				Case &h442
					wChar = &h422
				Case &h443
					wChar = &h423
				Case &h444
					wChar = &h424
				Case &h445
					wChar = &h425
				Case &h446
					wChar = &h426
				Case &h447
					wChar = &h427
				Case &h448
					wChar = &h428
				Case &h449
					wChar = &h429
				Case &h44A
					wChar = &h42A
				Case &h44B
					wChar = &h42B
				Case &h44C
					wChar = &h42C
				Case &h44D
					wChar = &h42D
				Case &h44E
					wChar = &h42E
				Case &h44F
					wChar = &h42F
			End Select
		End If
		FenceText[i] = wChar
	Next
	
	pBot->Say(Channel, FenceText)
End Sub

