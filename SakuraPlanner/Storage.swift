import Foundation

class Storage: ObservableObject {
    static let shared = Storage()
    private let ud = UserDefaults.standard

    @Published var todos: [Todo] = []
    @Published var points: Int = 0
    @Published var lastFeed: Date = Date()
    @Published var petAlive: Bool = true

    static let threeDays: TimeInterval = 3 * 24 * 3600
    static let oneDay: TimeInterval = 24 * 3600

    private init() {
        if let data = ud.data(forKey: "todos"),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = decoded
        }
        points = ud.integer(forKey: "points")
        if ud.object(forKey: "lastFeed") == nil {
            ud.set(Date(), forKey: "lastFeed")
        }
        lastFeed = ud.object(forKey: "lastFeed") as? Date ?? Date()
        petAlive = ud.bool(forKey: "petAlive")
        if !ud.bool(forKey: "petAliveSet") {
            ud.set(true, forKey: "petAlive")
            ud.set(true, forKey: "petAliveSet")
        }
        checkPetDeath()
    }

    func save() {
        if let data = try? JSONEncoder().encode(todos) {
            ud.set(data, forKey: "todos")
        }
        ud.set(points, forKey: "points")
        ud.set(lastFeed, forKey: "lastFeed")
        ud.set(petAlive, forKey: "petAlive")
    }

    func nextId() -> Int {
        let n = ud.integer(forKey: "nextId") + 1
        ud.set(n, forKey: "nextId")
        return n
    }

    func checkPetDeath() {
        if !petAlive { return }
        if Date().timeIntervalSince(lastFeed) > Self.threeDays {
            petAlive = false
            save()
        }
    }

    var petStatus: String {
        if !petAlive { return "小可饿死了…花100分复活" }
        let since = Date().timeIntervalSince(lastFeed)
        if since > Self.oneDay { return "小可饿了…快喂它" }
        return "小可吃饱啦~"
    }

    func feed() {
        if !petAlive {
            if points < 100 { return }
            points -= 100
            petAlive = true
        }
        lastFeed = Date()
        save()
    }
}
