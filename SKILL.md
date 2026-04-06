# Copilot Skills

本エージェントは以下の技術的スキルと実行能力を持ち、Banexy（Flutter英単語学習アプリ）の開発をサポートします。

## 1. Flutter / Dart 専門知識

* Dartの最新仕様（Null Safety, Record, Pattern Matching等）を踏まえ、安全で効率的なコードを記述する。
* FlutterのWidgetツリーを最適化し、不要な再描画を防ぐ（const の徹底、責務分割など）。
* 非同期処理（Future, Stream）を適切に扱い、UIフリーズや不整合な状態更新を防ぐ。

## 2. UI/UX 実装スキル

* 提示されたスクリーンショット（design/ ディレクトリ）の意図を正確に読み取り、FlutterのWidgetで再現性の高いUIを実装する。
* 端末サイズに応じたレスポンシブデザイン（MediaQuery, LayoutBuilder, Flexible, Expanded等）を実装する。
* 英語学習アプリとして、可読性（タイポグラフィ）と操作性（タップ領域、導線）を重視する。

## 3. テスト実装スキル

* Unitテスト: ビジネスロジックとユーティリティ関数を `test` パッケージで検証する。
* Widgetテスト: 描画、操作、状態変化を `flutter_test` で検証し、必要に応じて `setSurfaceSize()` ヘルパーを使って画面サイズを固定する。
* Repositoryテスト: `SharedPreferences.setMockInitialValues({})` を使って永続化層をモックし、原則として外部モックライブラリ（mockito / mocktail）は使わない。

## 4. プロジェクト運用スキル

* 状態管理は `setState()` を基本とし、非同期コールバックで状態を更新する前に `if (mounted)` を確認する。
* RepositoryアクセスはDIを使わず、`LocalWordRepository()`（factoryシングルトン）を直接利用する。
* 画面遷移後の再読込は `.then((_) => _loadData())` パターンを適用し、表示データの一貫性を保つ。

## 5. 外部連携・リファクタリング

* Firebase / 外部DB連携は、ユーザーから明示的な指示があった場合にのみ実装する。
* リファクタリングは、ユーザーから明示的に依頼された場合に重点対応し、可読性・再利用性・テスト容易性の向上を優先する。
