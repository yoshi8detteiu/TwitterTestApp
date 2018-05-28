# TwitterTestApp

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

## Description

Twitterクライアントアプリとして以下の機能を有しています
- ログイン・ログアウト
- Tweetの閲覧
- ユーザ情報の閲覧
- 画像解析(CoreML)を使ったTweet検索

***DEMO:***

TBD
![Demo](https://image-url.gif)

## Features

- 画像解析(CoreML)を使ったTweet検索
- UI
- チーム開発を前提とした疎結合設計

## Requirement

- TwitterKit
- Alamofire
- AlamofireImage
- SwiftyJSON

## Installation

    $ pod install

## Anything Else

CleanArchtectureは規模的に不適切でしたので、CocoaMVCを採用しています。
Storyboardは、重さ対策、複数人で実装する際のコンフリクト防止、画面間の密結合防止のため、画面単位で実装しています。

<追加要件>
- Tweet情報の追加(ScreenName、日時、プロフィールリンク、フォロー&フォロワー数)
- CoreMLのVisionを使った画像解析twitter検索
- ログアウト
- 日時等の追加
- TweetをRefreshControlで更新
- アラート
- アイコン&スプラッシュ


## Author

Yosuke Shiina

## License

[MIT](http://b4b4r07.mit-license.org)
