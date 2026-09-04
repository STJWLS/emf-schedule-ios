import SwiftUI
import UIKit
import WebKit

/// 与网页版看板一致的配色（米白 / 白 / 复旦蓝 / 马卡龙粉 / 暖棕）
enum Palette {
    static let bg = Color(red: 248/255, green: 244/255, blue: 236/255)      // #f8f4ec 米白
    static let blue = Color(red: 0, green: 61/255, blue: 165/255)           // #003da5 复旦蓝
    static let pink = Color(red: 236/255, green: 159/255, blue: 190/255)    // #ec9fbe 马卡龙粉
    static let pinkDeep = Color(red: 178/255, green: 94/255, blue: 131/255) // #b25e83
    static let text = Color(red: 66/255, green: 57/255, blue: 43/255)       // #42392b 暖棕
}

struct ContentView: View {
    /// 与网页端共享的同一个入口：后端更新后 App 无需重新构建
    private static let homeURL = URL(string: "https://stjwls.github.io/kitten/emf-schedule/")!

    @State private var webView = WKWebView()
    @State private var isLoading = false
    @State private var hasError = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if isLoading { loadingBar }
            WebViewContainer(webView: webView, onStart: { isLoading = true },
                             onFinish: { isLoading = false; hasError = false },
                             onError: { isLoading = false; hasError = true })
            if hasError { errorBar }
        }
        .background(Palette.bg)
        .onAppear {
            if webView.url == nil {
                webView.load(URLRequest(url: Self.homeURL))
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 9) {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(colors: [Palette.blue, Palette.pink],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 10, height: 10)
            Text("EMF 26R 课程看板")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Palette.text)
            Spacer()
            Button {
                webView.reload()
            } label: {
                Text("↻ 刷新")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(Palette.blue)
                    .cornerRadius(16)
            }
            Button {
                UIApplication.shared.open(Self.homeURL)
            } label: {
                Text("Safari")
                    .font(.system(size: 13))
                    .foregroundColor(Palette.pinkDeep)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(Palette.pink, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    private var loadingBar: some View {
        LinearGradient(colors: [Palette.blue, Palette.pink],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 2)
            .opacity(0.95)
    }

    private var errorBar: some View {
        Text("网络不可用，加载失败 · 点此重试")
            .font(.system(size: 13))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(Color(red: 201/255, green: 106/255, blue: 90/255)) // #c96a5a 粉棕珊瑚
            .onTapGesture {
                hasError = false
                webView.reload()
            }
    }
}

/// WKWebView 的 SwiftUI 包装
struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    var onStart: () -> Void
    var onFinish: () -> Void
    var onError: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 248/255, green: 244/255, blue: 236/255, alpha: 1)
        webView.scrollView.backgroundColor = UIColor(red: 248/255, green: 244/255, blue: 236/255, alpha: 1)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: WebViewContainer
        init(_ p: WebViewContainer) { parent = p }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onStart()
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onFinish()
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }
        /// 站内链接留在 WebView，外链交给系统 Safari
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host,
               host == "stjwls.github.io" || navigationAction.request.url == nil {
                decisionHandler(.allow)
            } else if navigationAction.navigationType == .linkActivated {
                if let url = navigationAction.request.url {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
