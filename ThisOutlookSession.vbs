' メール受信時に発生するイベント
Private Sub Application_NewMailEx(ByVal EntryIDCollection As String)
    Dim i As Integer
    Dim c As Integer
    Dim colID As Variant
    Dim objItem As Object  'MailItem
    Dim strText As String
'   Dim objRecip As Recipient
'   Dim objNewRecip As Recipient
    
    Const SEARCH_WORD = "【脆弱性TODAY】本日の脆弱性情報"
    
    Set objItem = Session.GetItemFromID(EntryIDCollection)
    If objItem.MessageClass = "IPM.Note" Then
        Dim msgItem As MailItem
        Set msgItem = objItem
        
        strText = msgItem.Subject & vbLf & msgItem.Body
        If InStr(strText, SEARCH_WORD) > 0 Then
            If InStr(EntryIDCollection, ",") = 0 Then
                SaveAttachments EntryIDCollection
            Else
                colID = Split(EntryIDCollection, ",")
                For i = LBound(colID) To UBound(colID)
                    SaveAttachments colID(i)
                Next
            End If
        End If
    End If
End Sub

'
' 添付ファイルの保存を行うサブ プロシージャ
Private Sub SaveAttachments(ByVal strEntryID As String)

    Const SAVE_PATH = "C:\Users\username\Desktop\attachments\"
    
    Dim objFSO As Object ' FileSystemObject
    Dim objMsg As Object
    Dim objAttach As Attachment
    Dim strFileName As String
    Dim c As Integer: c = 1
   
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objMsg = Application.Session.GetItemFromID(strEntryID)
'
' ここで条件指定
'
    For Each objAttach In objMsg.Attachments
        With objAttach
          
            strFileName = SAVE_PATH & objAttach.FileName
           
            While objFSO.FileExists(strFileName)
                strFileName = SAVE_PATH & Left(.FileName, InStrRev(.FileName, ".") - 1) _
                    & "-" & c & Mid(.FileName, InStrRev(.FileName, "."))
                c = c + 1
            Wend
           
            .SaveAsFile strFileName
        End With
    Next
    
    Set objMsg = Nothing
    Set objFSO = Nothing
    
    ' バッチファイルの呼び出し
    Call RunBatShell(SAVE_PATH)
    
End Sub
'
' バッチファイルの起動
Private Sub RunBatShell(ByVal strPath As String)
    Dim dProcessId As Double
      
    BAT_FILE = strPath + "vuln.bat"
    
    dProcessId = Shell("cmd.exe /c;" & " " & BAT_FILE & " " & strPath, vbNormalFocus)
    'dProcessId = Shell("C:\Windows\Sysnative\cmd.exe /c;" & " " & BAT_FILE & " " & strPath, vbNormalFocus)
    
    If dProcessId = 0 Then
        MsgBox "起動に失敗しました"
    End If
    
    ' MsgBox "終了"
End Sub
