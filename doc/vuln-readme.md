### 【脆弱性TODAY】本日の脆弱性情報 取得ツール
##### 目的
- GRCSから配信されているメール「【脆弱性TODAY】本日の脆弱性情報」に添付されているファイルは、圧縮された脆弱性情報の保存先のリンクファイルである。このため、リンク先からこの情報を取得するために手作業でダウンロードし解凍する手間が発生している。そこで、この圧縮された脆弱性情報をリンク先から自動的に取得し、自動解凍するスクリプトを作成し工数を低減する
- （作成中）解凍された脆弱性情報に、予めリストアップしたプロジェクトが使用しているソフトウェアが使われているかチェックする
##### 準備
1. ファイル保存先フォルダの作成

- デスクトップ（例）に、`attachments` フォルダを作成する
- さらに、`attachments`フォルダの下に、`done`フォルダを作成する
- ![](img/tree.JPG)

2. Outlook にマクロが実行でき環境を作る

- ![](img/outlook-macro.JPG)

3. Linuxシェルが開く環境を作る

- ![](img/linux.JPG)

#### できること
##### Outlook
1. 「【脆弱性TODAY】本日の脆弱性情報」メールを受信都度、添付されているファイルをあらかじめ用意した保存先フォルダ（`attachments`）に自動的に保存する
2. 予め自動分類しておいたフォルダに「【脆弱性TODAY】本日の脆弱性情報」メールを自動仕分けしている場合、一覧から、添付ファイルを自動的に一括保存する
	- ![](img/outlook-folder.JPG)

#### シェル（bash）
1. `attachments` フォルダに保存されている全ての脆弱性 html ファイルから、ここに記載されているリンク先に自動的に接続し、圧縮された脆弱性ファイルをダウンロードして解凍する
2. （作成中）解凍された脆弱性情報に、予め用意したプロジェクトが使用しているソフトウェアが使われているかチェックする

###### 補足・免責
- Outlookとシェルの実行は非同期です
- Linuxシェル閑居には、予め、`nkf`, `unar`をインストールしておきます
- Linuxシェル環境において、`wget`コマンド実行時に社内プロキシーを通過できる必要があります
- Linuxコマンドシェル `vuln.sh`は、正常系のみ実装しています
- 【脆弱性TODAY】本日の脆弱性情報 は、2019年4月16日から配信されていましたが、古い情報はサーバーから取得できませんでした。12月分の情報のみ一括取得できることを確認しています

#### 実施手順
##### Outlook
1. 自動保存コードの実装
	- 以下のコードを、`Visual Basic > Project1（VbaProject.OTM) > Microsoft Outlook Objects > `**ThisOutlookSession**　に実装する
```Application_NewMailEx.vb
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
End Sub
```
2. 保存先フォルダの修正
	- 添付ファイルの保存を行うサブ プロシージャ `SaveAttachments` にある次の行
	`Const SAVE_PATH = "C:\Users\`**username**`\Desktop\attachments\"`
	を、自分が作成したフォルダ名に変更する
	- 以上で「【脆弱性TODAY】本日の脆弱性情報」メールを受信すると自動的に添付ファイルを attachment フォルダに移動します 
3. 一括保存コードの実装
	- 以下のコードを、`Visual Basic > Project1（VbaProject.OTM) > 標準モジュール >` **Module1** に実装する
```SaveAttachmentsInCurrentFolder.vb
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
```

- リボンにマクロ `SaveAttachmentsInCurrentFolder` を登録する
	- ![](img/outlook-ribbon.JPG)
- 「【脆弱性TODAY】本日の脆弱性情報」メールを分類したフォルダに移動し、リボンに登録したマクロ `SaveAttachmentsInCurrentFolder` ボタンを押すと、すべての添付ファイルを作成したフォルダに保存します



##### シェル（bash）
1. 保存先フォルダからLinuxシェルを開く
2. `vuln.sh` を実行する
	- ![](img/linux-vuln.JPG)

3. `vuln.sh`を実行すると、該当日の脆弱性情報圧縮ファイルをダウンロードし、ダウンロードした圧縮ファイルを解凍します（該当日のフォルダを作成します）
	- ![](img/download-unzip.JPG)

4. 各フォルダ内にその日の脆弱性情報ファイルが解凍されています
	- ![](img/z-today1225.JPG)
5. 処理が終わったhtmlファイルとzipファイルは、フォルダ `done` に移動されます

以上