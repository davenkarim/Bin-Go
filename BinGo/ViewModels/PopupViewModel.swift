//
//  PopupViewModel.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI
import Foundation
import Combine

public class PopupViewModel: ObservableObject {
    @Published var countdown = 5
    
    private var timer: Timer?
    
    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }
    
    func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
