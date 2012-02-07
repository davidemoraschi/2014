Sub Delete_File(strFilePath)
       Set objFSO = CreateObject("Scripting.FileSystemObject")
       With objFSO
           If (.FileExists(strFilePath)) Then
               .DeleteFile(strFilePath)
           End If
       End With
       Set objFSO = Nothing
End Sub

Sub Check_File(strFilePath)
       Set objFSO = CreateObject("Scripting.FileSystemObject")
       With objFSO
           If Not (.FileExists(strFilePath)) Then
               Create_MDB_File(strFilePath)
           End If
       End With
       Set objFSO = Nothing
End Sub