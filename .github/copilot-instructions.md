# Copilot Instructions

## 1. プロジェクト概要

本プロジェクトは、Flutterを用いた英単語学習アプリ「Banexy」の開発です。ユーザーが単語カードをスワイプして既知/未知に分類し、未知の単語をテストするアプリです。

CopilotはシニアFlutterエンジニアとして、ユーザー（開発者）の指示に従い、プロジェクトの規約に沿った高品質で保守性の高いコードを提供してください。

## 2. コマンドとCI

開発・テスト・フォーマットには以下のコマンドを使用します。

```bash
flutter pub get          # 依存関係のインストール
flutter test             # 全てのテストを実行
flutter test test/screens/check_screen_test.dart   # 単一のテストファイルを実行
flutter test --name "displays the first word"      # 名前を指定して単一のテストを実行
flutter analyze          # 静的解析の実行
dart format .            # 全てのDartファイルのフォーマット
```

CI (`.github/workflows/ci.yaml`) は main ブランチへのPR作成時に実行されます。`dart format` 後に `flutter test` が実行されます（Flutter 3.38.9 stable）。

## 3. 基本的なワークフロー

* 画面および機能ごとの開発:
  * design/ ディレクトリ内のスクリーンショット画像と機能要件が提示されたら、それに基づきFlutterのUIコードおよびビジネスロジックを実装します。
  * 1つの機能要件が複数の画面にまたがる場合、画面間のルーティングや状態の受け渡しも適切に実装してください。
* 既存画面の変更・改良:
  * 既存機能のデザイン変更指示があった場合は、新規開発時と同様に design/ の新しいスクショを参照し、既存コードとテストを適切に修正してください。

## 4. アーキテクチャとディレクトリ構造

アーキテクチャは Models → Repositories → Screens → Widgets のレイヤード構造を採用しています。

【ディレクトリ構造】

Banexy/
 ├── .github/          # CI/CDのワークフロー設定
 ├── design/           # 画面および機能開発時に参照するスクリーンショット格納用
 ├── lib/
 │    ├── models/         # データモデル (WordCard, WordStatusなど)
 │    ├── repositories/   # データ保存・取得ロジック (LocalWordRepositoryなど)
 │    ├── screens/        # 各画面のStatefulWidget
 │    ├── theme/          # アプリのテーマ、色定義 (AppColorsなど)
 │    ├── widgets/        # 再利用可能な共通UIコンポーネント
 │    └── main.dart       # エントリーポイント
 ├── test/
 │    ├── repositories/   # リポジトリのテスト
 │    ├── screens/        # 画面のテスト
 │    └── widget_test.dart
 ├── pubspec.yaml
 ├── analysis_options.yaml
 └── ... (その他プラットフォーム用フォルダ・設定ファイル)

* Models (lib/models/):
  * WordCard クラスおよび WordStatus enum (fresh → learning → mastered)。
  * 習熟度を proficiency (int) で追跡します。
  * toJson() / fromJson() を持ち、fromJson は単一の文字列 meaning と、現在のリスト形式 meanings の両方に対応する後方互換性を持ちます。
* Repositories (lib/repositories/):
  * 抽象インターフェース BaseWordRepository と、そのシングルトン実装である LocalWordRepository を持ちます。
  * データは SharedPreferences にキー user_study_data でJSONとして永続化します。保存データがない場合は組み込みのマスター単語リストにフォールバックします。
* Screens (lib/screens/):
  * 各画面は StatefulWidget を使用し、状態管理には setState() のみを使用します（Provider/Bloc/Riverpodなどの状態管理パッケージは使用しません）。
* Widgets (lib/widgets/):
  * 共有UIコンポーネント（例: AppHeader, WordCardWidget）。
* Theme (lib/theme/):
  * AppColors クラスにて静的な色の定数を管理します（sage green primary, rust accent, red danger）。

画面遷移フロー:

HomeScreen → NewWordsSetupScreen → SortingScreen → SortCompleteScreen → LearningListScreen → CheckScreen

* Navigator.push / pushReplacement / popUntil を使用。
* 遷移先から戻った画面では、.then((_) => _loadData()) のようにデータをリロードしてください。

## 5. コーディング規約と重要ルール (Key Conventions)

* Repositoryアクセス: 画面からはDIフレームワークを使用せず、LocalWordRepository() を直接インスタンス化します（factory コンストラクタで _instance を返すシングルトンパターン）。
* 非同期状態更新: 非同期処理のコールバック内で setState() を呼ぶ際は、必ず事前に if (mounted) をチェックしてください。
* 画面間のデータ受け渡し: 画面はコンストラクタパラメータ経由でデータを受け取ります（例: CheckScreen({required this.wordsToCheck})）。

## 6. アプリ固有のドメインロジック

* 解答チェック (CheckScreen): 入力された解答と単語の正解（meanings）との照合には、レーベンシュタイン距離（Levenshtein distance）を使用し、距離が「2以下」であれば「ほぼ正解 (almost correct)」とするファジーマッチングを行います。
* スワイプの閾値 (SortingScreen): スワイプのアクションは、画面幅の30%（screenSize.width * 0.3）を超えた時点でトリガーされます。
* 習熟度（Proficiency）の進行:
  * 右スワイプ: proficiency を加算。3に達するとステータスを mastered に変更。
  * 左スワイプ: proficiency を 0 にリセットし、カードをリトライキューに追加。

## 7. テスト駆動・品質保証

* 機能を実装する際は、必ずテスト（Unitテスト、Widgetテスト）を作成してください。全てパスするまで自律的に修正を行ってください。
* テストのセットアップ規約:
  * Widgetテストでは setSurfaceSize() ヘルパー関数を使用して固定の画面サイズを設定します。
  * Repositoryのテストでは、ストレージのモックとして SharedPreferences.setMockInitialValues({}) を使用します。
  * 原則として外部のモックライブラリ（mockito等）は使用しないでください。

## 8. リファクタリングフェーズ

* ユーザーから「リファクタリングしてください」という明示的な指示があった場合のみ、新機能追加を止めてリファクタリングフェーズに移行します。コードの可読性向上、重複排除、Widgetの適切な分割に集中してください。

## 9. 外部連携（Firebase / 外部DB）

* Firebase（Auth, Firestore等）や外部DBの連携は、ユーザーが「連携してください」と指定したタイミングでのみ実装を開始してください。
* 連携するまでは、既存の SharedPreferences とモックデータでの処理を維持します。

## 10. ドキュメント配置

* `.github/copilot-instructions.md`: プロジェクト固有ルールと実装規約
* `AGENT.md` (リポジトリ直下): ペルソナと対話ルール
* `SKILL.md` (リポジトリ直下): 実装スキルと実務上の指針

上記3ファイルはこの配置を基準として維持してください。
