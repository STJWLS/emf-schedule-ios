import SwiftUI

/// EMF 26R 课程看板 · iOS 壳应用（WKWebView 入口）
///
/// 只负责加载网页版看板（GitHub Pages），网页端更新后无需重新发布 App：
///   https://stjwls.github.io/kitten/emf-schedule/
@main
struct EMFScheduleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
