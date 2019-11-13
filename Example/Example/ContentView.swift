//
//  ContentView.swift
//  Example
//
//  Created by Tomoya Hirano on 2019/11/04.
//  Copyright © 2019 Tomoya Hirano. All rights reserved.
//

import SwiftUI

let log: String = {
    let url = Bundle.main.url(forResource: "log", withExtension: "txt")!
    return try! String(contentsOf: url)
}()

struct ContentView: View {
    var body: some View {
        ANSIText(log)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import UIKit

struct ANSIText: UIViewOptimizedRepresentable {
    typealias UIViewType = UITextView
    let value: String
    init(_ value: Value) {
        self.value = value
    }
    
    func makeUIView(context: UIViewRepresentableContext<ANSIText>) -> ANSIText.UIViewType {
        return .init()
    }
    
    func shouldUpdateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<ANSIText>) {
        let font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let options = ANSI.Options(color: UIColor.white, font: font)
        let attributed = NSAttributedString(ansiString: value, options: options)
        uiView.isEditable = false
        uiView.attributedText = attributed
        uiView.backgroundColor = .black
    }
}

public protocol UIViewOptimizedRepresentable: UIViewRepresentable {
    associatedtype Value: Hashable
    var value: Value { get }
    init(_ value: Value)
    func shouldUpdateUIView(_ uiView: Self.UIViewType, context: Self.Context)
}

public extension UIViewOptimizedRepresentable {
    func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
        guard uiView.tag != self.value.hashValue else { return }
        shouldUpdateUIView(uiView, context: context)
        uiView.tag = self.value.hashValue
    }
}


