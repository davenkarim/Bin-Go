//
//  InstructionView.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI

struct InstructionView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image("bingo_character_middle")
                    .resizable()
                    .frame(width: 80, height: 80)
                
                Text("Place your trash inside the box!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                    )
                
                Spacer()
            }
            .padding(.bottom, 40)
            .padding(.leading, 20)
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Text("Error: \(message)")
                .foregroundColor(.red)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
            Spacer()
        }
        .padding()
    }
}
