//
//  SwiftUIView.swift
//  FaceDetectionTestApp
//
//  Created by aristarh on 18.11.2024.
//

import SwiftUI

struct SwiftUIView: View {
    
    private let contacts: [String] = [
        "Александр работа",
        "Мафия скипасс",
        "Артэмон52",
        "Андрей занавески"
    ]
    
    var body: some View {
        TabView {
            NavigationStack {
                List {
                    ForEach(contacts, id: \.self) { contact in
                        HStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Text(contact.first?.description ?? "")
                                        .font(.system(size: 20))
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                            VStack(alignment: .leading) {
                                Text(contact)
                                HStack {
                                    Image(systemName: "phone")
                                    Text("сотовый")
                                }
                                .foregroundStyle(.gray)
                            }
                            Spacer()
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .navigationTitle("Избранные")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: "plus") {
                            //
                        }
                    }
                }
            }
            .tabItem {
                Label("Избранные", systemImage: "star.fill")
            }
            NavigationStack {
                //
            }
            .tabItem {
                Label("Недавние", systemImage: "clock")
            }
            NavigationStack {
                //
            }
            .tabItem {
                Label("Контакты", systemImage: "person.circle")
            }
            NavigationStack {
                //
            }
            .tabItem {
                Label("Клавиши", systemImage: "teletype")
            }
            NavigationStack {
                //
            }
            .tabItem {
                Label("BMW", systemImage: "engine.combustion")
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
