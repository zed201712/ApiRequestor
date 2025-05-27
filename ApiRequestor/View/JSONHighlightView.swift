//
//  JSONHighlightView.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

//https://github.com/raspu/Highlightr.git
//import Highlightr
//import SwiftUI
//
//struct JSONHighlightView: UIViewRepresentable {
//    let code: String
//    
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.isEditable = false
//        textView.backgroundColor = .systemBackground
//        return textView
//    }
//    
//    func updateUIView(_ textView: UITextView, context: Context) {
//        let highlightr = Highlightr()!
//        highlightr.setTheme(to: "paraiso-dark")
//        if let highlightedCode = highlightr.highlight(code, as: "json") {
//            textView.attributedText = highlightedCode
//        } else {
//            textView.text = code
//        }
//    }
//}
