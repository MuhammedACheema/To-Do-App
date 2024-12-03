//
//  NotificationDisabled.swift
//  To-Do
//
//  Created by Muhammed Cheema on 11/8/24.
//

import SwiftUI

struct NotificationDisabled: View {
    var body: some View {
        VStack{
            Text("Notificiation are Disabled")
                .font(.headline)
            Text("To be notified when pomodoro period is over, enable notifications")
                .font(.subheadline)
            Button("Open Settings"){
                openSettings()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color("Light"))
        .foregroundColor(Color("Dark"))
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        
    }
    private func openSettings(){
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string:
                                            UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    VStack{
        NotificationDisabled()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color("Dark"))
}
