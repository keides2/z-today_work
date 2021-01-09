# [z-today] 脆弱性情報収集・検知システム - 管理者向け保守情報

---

## バッチファイル実行前の準備（必要条件）

### 必要なバッチファイル

#### C:\Users\ユーザー名\Desktop\attachments フォルダに以下のバッチファイルがあること

- vuln.bat 
- findnocpe2.bat

### 必要なツール

#### 文字コード・改行コード変換ツール

##### C:\Program Files (x86)\nkf フォルダに以下のファイルがあること

- バッチファイルから `nkf32` を実行できない場合は、脆弱性情報の検索結果が、配信メールの本文に記載されずに、`ATT00001.bin` 等の名前のファイルが添付される

- nkf32.exe
- nkf32.dll

##### 環境変数 Path の設定例

- `C:\wincmd\bin;C:\WINDOWS\system32;・・・;C:\Program Files (x86)\nkf;・・・`

### 必要なドライブの割り当て

- Zドライブをマウントしておくこと

---

## 手作業で動作確認を行う方法

- バッチファイルがある `attachment` フォルダーに、`z-today????_zip.html` ファイルを置き、`attachment` フォルダーをカレントディレクトリとするコマンドプロンプトから `vuln.bat` を実行する（引数は不要）

---

## ログの保存場所（CentOS7 ）

### cron ログの確認

```bash
# tail -f /var/log/cron
```

### システムログの確認

```bash
$ cat /var/log/messages
# cat /var/log/vuls/z-today-mail.log
```

---

## スケジュールの編集

`crontab -e`を使って編集すること

```bash
$ su -
# crontab -e
# cat /var/spool/cron/vuls

# パスを通す
PATH=/sbin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/local/go/bin:/home/vuls/go/bin:/usr/lib/jvm/java/bin:/opt/apache-tomcat/apache-tomcat-7.0.50/bin:/home/vuls/.local/bin:/home/vuls/bin:
MAIL=/var/spool/mail/vuls
# 分　時　日　月　曜日　コマンド
05 6 * * 1-5 /home/vuls/vuls-auto2.sh full diff > /var/log/vuls/vuls-auto.log 2>&1
00 15 * * 1-5 /home/vuls/z-today-mail2.sh > /var/log/vuls/z-today-mail.log 2>&1
```

- 新しいスケジュールを追加する場合は行を追加する。`crond` の再起動は不要

### スケジュールファイルの属性

- 所有者 `vuls` だけに、`read`, `write` 権限のみが付与されていること

```bash
# ls -la /var/spool/cron/vuls
-rw-------. 1 vuls vuls 356  2月 21 18:36 /var/spool/cron/vuls
```

### crond ステータスの確認と再起動

```bash
# systemctl status crond
# systemctl start crond
# systemctl enable
```

---

## CentOS7

### ログイン情報

#### IP

- xxx.xxx.xxx.xxx

#### ユーザー名・パスフレーズ

- vuls
- root

### CentOS上のZドライブマウント情報

#### 脆弱性情報の検索結果の保存先

- /mnt/z/path/to/z-today/

---
