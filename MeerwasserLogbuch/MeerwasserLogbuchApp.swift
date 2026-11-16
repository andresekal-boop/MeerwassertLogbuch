import SwiftUI
import WebKit
import UIKit

@main
struct MeerwasserLogbuchApp: App {
    var body: some Scene {
        WindowGroup { AquariumHome() }
    }
}

struct AquariumHome: View {
    var body: some View {
        AquariumWebView()
            .ignoresSafeArea(edges: .bottom)
            .preferredColorScheme(.light)
    }
}

struct AquariumWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.98, alpha: 1)
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.scrollView.bounces = true
        web.navigationDelegate = context.coordinator
        if let file = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Resources") {
            web.loadFileURL(file, allowingReadAccessTo: file.deletingLastPathComponent())
        } else {
            web.loadHTMLString("<h2>Meerwasser-Logbuch</h2><p>Die App-Datei index.html fehlt im Bundle.</p>", baseURL: nil)
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow); return
            }
            if url.isFileURL || url.scheme == "data" || url.scheme == "blob" {
                decisionHandler(.allow); return
            }
            if navigationAction.navigationType == .linkActivated,
               ["http", "https", "mailto"].contains(url.scheme?.lowercased() ?? "") {
                UIApplication.shared.open(url)
                decisionHandler(.cancel); return
            }
            decisionHandler(.allow)
        }
    }
}
