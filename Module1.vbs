' 現在表示されているフォルダーに含まれるアイテムの添付ファイルをすべて保存する
Public Sub SaveAttachmentsInCurrentFolder()
    Dim objItem As Object ' MailItem
    For Each objItem In ActiveExplorer.CurrentFolder.Items
        SaveAttachmentsInOneItem objItem
    Next
End Sub
'
Private Sub SaveAttachmentsInOneItem(objItem As Object)
    Const SAVE_PATH = "C:\Users\username\Desktop\attachments\"
    Dim objFSO As Object ' FileSystemObject
    Dim objAttach As Attachment
    Dim strFileName As String
    Dim c As Integer
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    '
    ' ここで条件指定
    If Not objItem.Subject Like "*【脆弱性TODAY】本日の脆弱性情報*" Then Exit Sub
    '
    For Each objAttach In objItem.Attachments
        With objAttach
            strFileName = SAVE_PATH & objAttach.FileName
            c = 2
            While objFSO.FileExists(strFileName)
                strFileName = SAVE_PATH & Left(.FileName, InStrRev(.FileName, ".") - 1) _
                    & "-" & c & Mid(.FileName, InStrRev(.FileName, "."))
                c = c + 1
            Wend
            .SaveAsFile strFileName
        End With
    Next
    '
    Set objFSO = Nothing
End Sub
