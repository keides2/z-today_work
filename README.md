# z-today

## **GRCS が配信する"【脆弱性TODAY】本日の脆弱性情報" からソフトウェアを自動検索するツール**（CPEリストにないソフトウェアの検索 ）

### 概要

- GRCSから配信されるメール "【脆弱性TODAY】本日の脆弱性情報" に添付されているファイルは、圧縮された脆弱性情報の保存先のリンクファイルです。このため、リンク先からこの情報を取得するために手作業で圧縮ファイルをダウンロードし解凍する手間が発生します。このツールは、この圧縮された脆弱性情報をリンク先から自動的に取得し、自動解凍するスクリプトです。
- また解凍された脆弱性情報に、予めリストアップしたソフトウェアが使われているかチェックすることができます（CPEが存在するソフトウェアは、Vulsを利用したツール [vuls-auto](https://github.com/keides2/vuls-auto)を利用し、CPEが存在しないソフトウェアを、このツールを使って検索します）
- ソフトウェアは正規表現を使って検索できます

### 環境
- メールを受信するクライアントに`Windows10 `
- スクリプトを実行するサーバーに`CentOS7`
### 準備

<u>1. ファイル保存先フォルダの作成</u>

- デスクトップ（以下は一例につき任意のフォルダーに設定可能）に、`attachments` フォルダを作成する
- さらに、`attachments`フォルダの下に、`done`フォルダを作成する

<u>2. プロジェクト・フォルダーの作成</u>

- `proj`フォルダーを作成し、その下にプロジェクトごとのフォルダーを作成する

- プロジェクト・フォルダーの中に、`nocpe.txt`を保存する

<u>3. Outlook にマクロが実行できる環境を作る</u>

- 詳細は「Outlook VBA マクロ、はじめの一歩」など参照
  - [https://outlooklab.wordpress.com/2007/02/18/outlook-vba-%e3%83%9e%e3%82%af%e3%83%ad%e3%80%81%e3%81%af%e3%81%98%e3%82%81%e3%81%ae%e4%b8%80%e6%ad%a9/](https://outlooklab.wordpress.com/2007/02/18/outlook-vba-マクロ、はじめの一歩/)

<u>3. ~~Linuxシェルが開く環境を作る~~</u>

- ~~詳細は省略する。「WSL2を機に始めるWindows上での環境構築」https://qiita.com/ogawayuj/items/7ba34e3fd50f2fdc8753 など参照　）~~ 不要

<u>4. Linuxシェル用の`vuln.bat`をコマンドプロンプト用`vuln.bat`に置き換える（上書き保存）</u>

- ※Linuxシェル用の`vuln.bat`は、`vuln.wsl2.bat`です。コマンドプロンプト用`vuln.bat`は、`vuln.cmd.bat`です
   
   **※CPEリストにないソフトウェアを検索する`vuln.bat`は、`vuln.NOCPE.bat`です。**



### できること

##### Outlook

1. "【脆弱性TODAY】本日の脆弱性情報" メールを受信都度、添付されているファイルをあらかじめ用意した保存先フォルダ（`attachments`）に自動的に保存する（ThisOutlookSessionの「メール受信時に発生するイベント」と「添付ファイルの保存を行うサブ プロシージャ」マクロを利用する）
2. 添付ファイルの保存が終了したら、Windowsコマンドプロンプトを起動し、さらにそこからLinuxシェルを起動するバッチファイルを呼び出す
3.  予め作成済のOutlookフォルダ（例えば、下図「脆弱性TODAY」フォルダ）に、"【脆弱性TODAY】本日の脆弱性情報" メールを自動仕分けしている場合、このフォルダに含まれる添付ファイルを自動的に一括保存する（標準モジュールの「現在表示されているフォルダーに含まれるアイテムの添付ファイルをすべて保存する」マクロを利用する）

#### ~~Linuxシェル（bash）~~ 不要

1. ~~`attachments` フォルダに保存されている全ての脆弱性 html ファイルから、ここに記載されているリンク先に自動的に接続し、圧縮された脆弱性ファイルをダウンロードして解凍する~~

2. ~~（作成中）解凍された脆弱性情報に、予め用意したプロジェクトが使用しているソフトウェアが使われているかチェックする（作成予定だったが、Vulsを利用したシステムに移行する予定）~~

#### コマンドプロンプト（.bat）

   1. `attachments` フォルダに保存されている全ての脆弱性 html ファイルから、ここに記載されているリンク先に自動的に接続し、圧縮された脆弱性ファイルをダウンロードして解凍する

#### 補足・免責

- ~~Outlookとシェルの実行は非同期です~~　Outlookのマクロから自動的に（Windowsコマンドプロンプトを起動し）~~Linuxシェル~~バッチファイルを起動します
- ~~Linuxシェル環境には、予め、`nkf`, `unar`をインストールしておいてください~~
- ~~Linuxシェル環境において、`wget`コマンド実行時に社内プロキシーを通過できる必要があります~~
- ~~Linuxコマンドシェル `vuln.sh`~~ バッチファイル `vuln.bat`は、正常系のみ実装しています
- "【脆弱性TODAY】本日の脆弱性情報" は、2019年4月16日から配信されていましたが、古い情報はサーバーから取得できませんでした。「現在表示されているフォルダーに含まれるアイテムの添付ファイルをすべて保存する」マクロは、2019年12月分の情報のみ一括取得できることを動作確認しています

### 実施手順

#### Outlook

1. 自動保存コードの実装
   - 以下のコード（ThisOutlookSession.vbs）を、`Visual Basic > Project1（VbaProject.OTM) > Microsoft Outlook Objects > `**ThisOutlookSession**　に実装する

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
    
    ' バッチファイルの呼び出し
    Call RunBatShell(SAVE_PATH)
    
End Sub
'
' バッチファイルの起動
Private Sub RunBatShell(ByVal strPath As String)
    Dim dProcessId As Double
      
    BAT_FILE = strPath + "vuln.bat"
    
    dProcessId = Shell("cmd.exe /c;" & " " & BAT_FILE & " " & strPath, vbNormalFocus)
    
    If dProcessId = 0 Then
        MsgBox "起動に失敗しました"
    End If
    
    ' MsgBox "終了"
End Sub
```

2. 保存先フォルダの修正
   - 添付ファイルの保存を行うサブ プロシージャ `SaveAttachments` にある次の行
     `Const SAVE_PATH = "C:\Users\`**username**`\Desktop\attachments\"`
     を、自分が作成したフォルダ名に変更する
   - 以上で「【脆弱性TODAY】本日の脆弱性情報」メールを受信すると自動的に添付ファイルを attachment フォルダに移動する 
3. 一括保存コードの実装
   - 以下のコード（Module1.vbs）を、`Visual Basic > Project1（VbaProject.OTM) > 標準モジュール >` **Module1** に実装する
   - 上記同様に `Private Sub SaveAttachmentsInOneItem(objItem As Object)` にある次の行
     `Const SAVE_PATH = "C:\Users\`**username**`\Desktop\attachments\"`
     を、自分が作成したフォルダ名に変更する

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

- 「【脆弱性TODAY】本日の脆弱性情報」メールを分類したフォルダに移動し、リボンに登録したマクロ `SaveAttachmentsInCurrentFolder` ボタンを押すと、すべての添付ファイルを作成したフォルダに保存します

#### ~~Linuxシェル（bash）~~　バッチファイル（bat）

1. 以下に、~~Linuxシェル~~コマンドプロンプト～ ~~v`uln.sh`~~ `vuln.bat`を単独起動する場合について記す（Outlookマクロから自動起動されます）
   - 改行コードに注意。windows環境では、CRLFでないと実行できない。ダウンロードの方法により改行コードがLFになる場合がある。

2. 保存先フォルダから ~~Linuxシェル~~ コマンドプロンプトを開く

3. ~~`vuln.sh`~~ `vuln.bat` を実行する

4. ~~`vuln.sh`~~ `vuln.bat`を実行すると、該当日の脆弱性情報圧縮ファイルをダウンロードし、ダウンロードした圧縮ファイルを解凍します（該当日のフォルダを自動作成します）

5. 各フォルダ内にその日の脆弱性情報ファイルが解凍されています

6. 処理が終わった`html`ファイルと`zip`ファイルは、フォルダ `done` に移動されます

7. **ファイル`nocpe.txt`に記載されたソフトウェアを解凍された`csv`ファイルから検索し、結果を`[proj-name]NoCCPE-z-todayyyyymmdd.txt`ファイルに保存します**

8. 作成した`[proj-name]NoCCPE-z-todayyyyymmdd.txt`は、`proj`フォルダー下の各プロジェクトに移動されます

### ライセンス LICENSE

事情によりしばらく `NO LICENSE` といたしますので、`GitHub` の利用規約と著作権法が定める範囲を超えた利用・複製・再頒布などを一切禁止させていただきます。

Due to circumstances, it will be NO LICENSE for a while, so I will prohibit any use, duplication, redistribution, etc. beyond the scope of the tProject-D of service of GitHub and the copyright law.
