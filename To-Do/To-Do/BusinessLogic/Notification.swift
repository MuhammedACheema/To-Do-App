//
//  Notification.swift
//  To-Do
//
//  Created by Muhammed Cheema on 10/26/24.
//

import Foundation
import UserNotifications //will try to get notification access to help people be notified

class Notification{
    static func checkAuthorization(completion: @escaping (Bool) -> Void){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings{ setting in
            switch setting.authorizationStatus{
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]){ allowed, error in
                    completion(allowed)
                }
            default:
                completion(false)
            }
        }
    }
    
    static func scheduleNotifications(seconds: TimeInterval, title: String, body: String){
        let notificationCenter = UNUserNotificationCenter.current()
        // remove all notifications
        
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        
        //set up content of the notification
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: PomodoroAudioSounds.done.resource))
        //trigger notifications
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: "my-notification", content: content, trigger: trigger)
        
        //add notification to the center
        
        notificationCenter.add(request)
    }
}

