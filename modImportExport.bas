Attribute VB_Name = "modImportExport"
Option Explicit

Const strThisProjectName As String = "VBAExport"


Public Sub MakeFileList()
    Dim prjActVBProject As VBProject
    Dim modFileList As VBComponent
    Dim comComponent As VBComponent

    On Error GoTo ErrHandler
    
    '// name this project if it has not been already
    If ThisWorkbook.VBProject.Name <> strThisProjectName Then ThisWorkbook.VBProject.Name = strThisProjectName

    If Application.VBE.ActiveVBProject Is Nothing Then Exit Sub
    Set prjActVBProject = Application.VBE.ActiveVBProject
    
    '// Add logic sso that this project is not listed
    If prjActVBProject.Name = strThisProjectName Then Exit Sub

    On Error Resume Next
    Set modFileList = prjActVBProject.VBComponents("modFileList")
    On Error GoTo ErrHandler

    If modFileList Is Nothing Then
        'module does not already exist
    Else
        'module already exists, so first remove it
        prjActVBProject.VBComponents.Remove modFileList
    End If

    'Add module
    Set modFileList = prjActVBProject.VBComponents.Add(vbext_ct_StdModule)
    modFileList.Name = "modFileList"

    With modFileList.CodeModule
        .AddFromString ("'DO NOT DELETE THIS MODULE")

        'For each module form etc, add the name to the modFileList Module
        For Each comComponent In prjActVBProject.VBComponents
            Select Case comComponent.Type
            Case Is = vbext_ct_StdModule
                If UCase(comComponent.Name) <> UCase("modFileList") Then
                    .AddFromString ("'Module: " & comComponent.Name)
                End If
            Case Is = vbext_ct_ClassModule
                .AddFromString ("'Class: " & comComponent.Name)
            Case Is = vbext_ct_MSForm
                .AddFromString ("'Form: " & comComponent.Name)
            Case Is = vbext_ct_ActiveXDesigner
                .AddFromString ("'Designer: " & comComponent.Name)
            End Select
        Next
    End With

    Exit Sub

ErrHandler:
    MsgBox "Error building file list" & vbCrLf & "Error Number: " & Err.Number & vbCrLf & Err.Description _
         , vbExclamation, "modImportExport.MakeFileList"
End Sub

Sub ImportFiles()
    Dim prjActVBProject As VBProject
    Dim modFileList As VBComponent
    Dim strModuleName As String
    Dim strActVBProjectDir As String
    Dim intModRowCounter As Integer

    On Error GoTo ErrHandler

    If Application.VBE.ActiveVBProject Is Nothing Then Exit Sub
    Set prjActVBProject = Application.VBE.ActiveVBProject

    strActVBProjectDir = Left(prjActVBProject.Filename, Len(prjActVBProject.Filename) - _
                                                        Len(Dir(prjActVBProject.Filename, vbNormal)))

    'Check modFileList module exists
    On Error Resume Next
    Set modFileList = prjActVBProject.VBComponents("modFileList")
    On Error GoTo ErrHandler

    'If modFileList module doesnt exist, you need to warn user then exit sub
    If modFileList Is Nothing Then
        MsgBox "You need to create modFileList before you can import files!"
        Exit Sub
    End If

    With modFileList.CodeModule
        'loop through each module name listed in modFileList and import the associated module
        For intModRowCounter = 1 To .CountOfDeclarationLines
            Select Case Left(.Lines(intModRowCounter, 1), InStr(.Lines(intModRowCounter, 1), ": "))
            Case Is = "'Module:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 9)
                prjActVBProject.VBComponents.Import (strActVBProjectDir & strModuleName & ".bas")
            Case Is = "'Class:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 8)
                prjActVBProject.VBComponents.Import (strActVBProjectDir & strModuleName & ".cls")
            Case Is = "'Form:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 7)
                prjActVBProject.VBComponents.Import (strActVBProjectDir & strModuleName & ".frm")
            End Select
        Next intModRowCounter
    End With

    MsgBox "Finished building " & prjActVBProject.Name

    Exit Sub

ErrHandler:
    MsgBox "Error in Importing Files" & vbCrLf & "Error Number: " & Err.Number & vbCrLf & Err.Description _
         , vbExclamation, "modImportExport.ImportFiles"
End Sub

Sub ExportFiles()
    Dim prjActVBProject As VBProject
    Dim modFileList As VBComponent
    Dim strModuleName As String
    Dim strActVBProjectDir As String
    Dim intModRowCounter As Integer

    On Error GoTo ErrHandler

    If Application.VBE.ActiveVBProject Is Nothing Then Exit Sub
    Set prjActVBProject = Application.VBE.ActiveVBProject

    strActVBProjectDir = Left(prjActVBProject.Filename, Len(prjActVBProject.Filename) - _
                                                        Len(Dir(prjActVBProject.Filename, vbNormal)))

    'Check modFileList module exists
    On Error Resume Next
    Set modFileList = prjActVBProject.VBComponents("modFileList")
    On Error GoTo ErrHandler

    'If modFileList module doesnt exist, you need to warn user then exit sub
    If modFileList Is Nothing Then
        MsgBox "You need to create modFileList before you can export files!"
        Exit Sub
    End If

    With modFileList.CodeModule
        'loop through each module name listed in modFileList and import the associated module
        For intModRowCounter = 1 To .CountOfDeclarationLines
            Select Case Left(.Lines(intModRowCounter, 1), InStr(.Lines(intModRowCounter, 1), ": "))
            Case Is = "'Module:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 9)
                prjActVBProject.VBComponents(strModuleName).Export (strActVBProjectDir & strModuleName & ".bas")
                If UCase(strModuleName) <> UCase("modFileList") Then
                    prjActVBProject.VBComponents.Remove prjActVBProject.VBComponents(strModuleName)
                End If
            Case Is = "'Class:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 8)
                prjActVBProject.VBComponents(strModuleName).Export (strActVBProjectDir & strModuleName & ".cls")
                prjActVBProject.VBComponents.Remove prjActVBProject.VBComponents(strModuleName)
            Case Is = "'Form:"
                strModuleName = Right(.Lines(intModRowCounter, 1), Len(.Lines(intModRowCounter, 1)) - 7)
                prjActVBProject.VBComponents(strModuleName).Export (strActVBProjectDir & strModuleName & ".frm")
                prjActVBProject.VBComponents.Remove prjActVBProject.VBComponents(strModuleName)
            End Select
        Next intModRowCounter
    End With

    MsgBox "Finished exporting " & prjActVBProject.Name

    Exit Sub

ErrHandler:
    MsgBox "Error in Exporting Files" & vbCrLf & "Error Number: " & Err.Number & vbCrLf & Err.Description _
         , vbExclamation, "modImportExport.ExportFiles"
End Sub

