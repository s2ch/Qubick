' Получение значения из реестра
Declare Function GetSettingsValue(ByVal Buffer As WString Ptr, ByVal BufferLength As Integer, ByVal Key As WString Ptr)As Integer

' Запись значения в реестр
Declare Function SetSettingsValue(ByVal Key As WString Ptr, ByVal Value As WString Ptr)As Boolean