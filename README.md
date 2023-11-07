# mc-settings

星野あおい参加型サーバーの設定集。  

バグ報告やリクエストがある場合は、Issueを作成してください。  

## 使い方

### ブランチ

| ブランチ名 | 説明 | 
| :-------:| :--:|
| paper | PaperMC用設定ファイルと起動ファイル |
| velocity | Velocity用設定ファイルと起動ファイル |

### 起動方法

各ブランチに移動後、`start.sh`を起動してください。  
また必要に応じて`start.sh`内の変数を書き換えてください。

```shell
# ブランチ移動
$ git checkout <paper | velocity>

# 起動
$ ./start.sh manager
```

## 各種リンク

- [バグ報告](https://github.com/aoissx/mc-settings/issues/new?assignees=aoissx&labels=bug&projects=&template=%E3%83%90%E3%82%B0%E5%A0%B1%E5%91%8A.md&title=%5BBUG%5D)
- [リクエスト](https://github.com/aoissx/mc-settings/issues/new?assignees=aoissx&labels=enhancement&projects=&template=%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88.md&title=%5B%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%5D)
