Attribute VB_Name = "modFunctions"
Option Explicit

Function ConfFileExists() As Boolean

    '// Determine if current location has a
    '// project file saved in it looking for the
    '// FileList.conf file in the ThisWorkbook location
    '// pre populate rExportTo and rImportFrom if found

    Dim FSO     As New Scripting.FileSystemObject
    Dim File    As Scripting.File
    Dim strPath As String
    Dim strFile As String
    
    strFile = strConfigFileName

    strPath = FSO.GetParentFolderName(Application.VBE.ActiveVBProject.FileName)
    
    For Each File In FSO.GetFolder(strPath).Files
        If File.Name = strFile Then
            blnConfigAvailable = True
            shtConfig.Range("rComponentTXTList") = blnConfigAvailable
            strConfigFilePath = File.path
            ConfFileExists = True
            GoTo ExitFunction
        End If
    Next
        
    '// if not config
    blnConfigAvailable = False
    ConfFileExists = False
    
ExitFunction:
    Exit Function

CatchError:
    GoTo ExitFunction

End Function

'Function fUseTXTList() As Boolean
'    fUseTXTList = blnConfigAvailable
'End Function
'
'Function fExportLocation()
'    fExportLocation = strExportTo
'End Function
'
'Function fImportLocation()
'    fImportLocation = strImportFrom
'End Function

Function fFilePicker(strPickType As String, Optional strFileSpec As String, Optional strTitle As String, _
    Optional strFilterString As String, Optional bolAllowMultiSelect As Boolean) As String

    Dim fdiBox                      As FileDialog
    Dim lngIdx                      As Long
    Dim lngCount                    As Long
    Dim varArrFilters()             As Variant
    Dim varArrFilterElements()      As Variant
    Dim strSiteName                 As String

    On Error GoTo CatchError
   
    Select Case LCase(strPickType)
        Case "file"
            Set fdiBox = Application.FileDialog(msoFileDialogFilePicker)
        Case "folder"
            Set fdiBox = Application.FileDialog(msoFileDialogFolderPicker)
    End Select
    
    With fdiBox
        .InitialFileName = strFileSpec
        .AllowMultiSelect = bolAllowMultiSelect
        
        If strTitle <> "" Then
            .Title = strTitle
        End If
        
        .Filters.Clear
        
        If strFilterString <> "" Then
            varArrFilters = Split(strFilterString, "|")
            
            For lngIdx = LBound(varArrFilters) To UBound(varArrFilters)
                varArrFilterElements = Split(varArrFilters(lngIdx), ",")
                
                .Filters.Add varArrFilterElements(0), "*." & varArrFilterElements(1)
            Next
        End If

        If .Show = -1 Then

            For lngIdx = 1 To .SelectedItems.Count
                If lngIdx > 1 Then
                    fFilePicker = fFilePicker & "|"
                End If
                    
                fFilePicker = fFilePicker & fConvToUNC(CStr(.SelectedItems(lngIdx)))
            Next
        End If
    End With
    
    'Set the object variable to Nothing.
    Set fdiBox = Nothing

ExitFunction:
    Exit Function

CatchError:
    GoTo ExitFunction
    
End Function


Function fConvToUNC(strPath As String) As String
        
    '// converts a URL to a UNC path adding the @SSL where required for SharePoint
    
    If LCase(Left(strPath, 4)) = "http" Then
    
        If InStr(1, strPath, "https://") Then
            strPath = Replace(strPath, "https://", "")
            strPath = Replace(strPath, "/", "@SSL\", , 1)
        ElseIf InStr(1, strPath, "https:\\") Then
            strPath = Replace(strPath, "https:\\", "")
            strPath = Replace(strPath, "\", "@SSL\", , 1)
        ElseIf InStr(1, strPath, "http://") Then
            strPath = Replace(strPath, "http://", "")
        ElseIf InStr(1, strPath, "http:\\") Then
            strPath = Replace(strPath, "http:\\", "")
        End If
        
        strPath = "\\" & Replace(strPath, "/", "\")
        '// added to cater for spaces
        strPath = Replace(strPath, "%20", " ")
    End If
    
    fConvToUNC = strPath

End Function


