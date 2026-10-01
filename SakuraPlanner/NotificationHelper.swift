import UserNotifications

enum NotificationHelper {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(todo: Todo) {
        guard todo.hour >= 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "该做事啦！"
        content.body = todo.content
        content.sound = .default

        var date = DateComponents()
        date.hour = todo.hour
        date.minute = todo.minute

        let trigger: UNNotificationTrigger
        if todo.repeatDaily {
            trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        } else {
            var next = DateComponents()
            next.hour = todo.hour
            next.minute = todo.minute
            var dateComp = next
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        }

        let req = UNNotificationRequest(identifier: "todo-\(todo.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    static func cancel(todo: Todo) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["todo-\(todo.id)"])
    }
}
