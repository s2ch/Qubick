' Увеличивает счётчик фраз пользователя
Declare Function IncrementUserWords(ByVal Channel As WString Ptr, ByVal User As WString Ptr)As Boolean

' Получение значения из реестра
Declare Function GetSettingsValue(ByVal Buffer As WString Ptr, ByVal BufferLength As Integer, ByVal Key As WString Ptr)As Integer

' Запись значения в реестр
Declare Function SetSettingsValue(ByVal Key As WString Ptr, ByVal Value As WString Ptr)As Boolean