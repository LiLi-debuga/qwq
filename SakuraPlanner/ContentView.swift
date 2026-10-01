import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject var store = Storage.shared
    @State private var newContent = ""
    @State private var pickHour = -1
    @State private var pickMinute = 0
    @State private var repeatDaily = false
    @State private var showTimePicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    banner
                    petCard
                    inputCard
                    todoList
                }
                .padding(.bottom, 30)
            }
            .background(Color(red: 1.0, green: 0.96, blue: 0.97).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear { store.checkPetDeath() }
    }

    var banner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("sakura")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
            VStack(alignment: .leading) {
                Text(greeting)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.38, blue: 0.57))
                Text(dateString)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.white.opacity(0.85))
            .cornerRadius(8)
            .padding([.leading, .bottom], 12)
        }
    }

    var petCard: some View {
        HStack(spacing: 10) {
            Image("kero")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .opacity(store.petAlive ? 1 : 0.3)
            VStack(alignment: .leading) {
                Text(store.petStatus)
                    .font(.system(size: 13))
                    .foregroundColor(store.petAlive ? .gray : Color(red: 0.94, green: 0.38, blue: 0.57))
                Text("积分 \(store.points)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.94, green: 0.38, blue: 0.57))
            }
            Spacer()
            Button(action: {
                store.feed()
            }) {
                Text(store.petAlive ? "喂小可" : "复活(100分)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color(red: 1.0, green: 0.56, blue: 0.67)))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    var inputCard: some View {
        VStack(spacing: 8) {
            TextField("写下今天要做的事…", text: $newContent, axis: .vertical)
                .padding(10)
            Divider()
            HStack {
                Button(action: { showTimePicker = true }) {
                    Text(pickHour >= 0 ? String(format: "提醒 %02d:%02d", pickHour, pickMinute) : "不提醒")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 1.0, green: 0.56, blue: 0.67))
                }
                Spacer()
                Button(action: { repeatDaily.toggle() }) {
                    Text(repeatDaily ? "每天重复" : "一次性")
                        .font(.system(size: 13, weight: repeatDaily ? .bold : .regular))
                        .foregroundColor(repeatDaily ? Color(red: 0.94, green: 0.38, blue: 0.57) : .gray)
                }
                Button(action: addTodo) {
                    Text("添加")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.56, blue: 0.67)))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showTimePicker) {
            NavigationView {
                Form {
                    DatePicker("时间", selection: Binding(
                        get: {
                            var c = DateComponents()
                            c.hour = pickHour >= 0 ? pickHour : 9
                            c.minute = pickMinute
                            return Calendar.current.date(from: c) ?? Date()
                        },
                        set: { d in
                            let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                            pickHour = c.hour ?? 9
                            pickMinute = c.minute ?? 0
                        }
                    ), displayedComponents: .hourAndMinute)
                }
                .navigationTitle("选提醒时间")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { showTimePicker = false }
                    }
                }
            }
        }
    }

    var todoList: some View {
        VStack(alignment: .leading, spacing: 0) {
            section(title: "上午", items: store.todos.filter { $0.hour >= 0 && $0.hour < 12 })
            section(title: "中午", items: store.todos.filter { $0.hour >= 12 && $0.hour < 14 })
            section(title: "晚上", items: store.todos.filter { $0.hour >= 14 })
            section(title: "无提醒", items: store.todos.filter { $0.hour < 0 })
        }
    }

    @ViewBuilder
    func section(title: String, items: [Todo]) -> some View {
        if !items.isEmpty {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 0.94, green: 0.38, blue: 0.57))
                .padding(.leading, 20)
                .padding(.top, 14)
            ForEach(items) { t in
                row(todo: t)
            }
        }
    }

    func row(todo t: Todo) -> some View {
        HStack(spacing: 10) {
            Button(action: { toggle(t) }) {
                Image(systemName: t.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(t.done ? Color(red: 1.0, green: 0.56, blue: 0.67) : Color.gray.opacity(0.4))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(t.content)
                    .strikethrough(t.done)
                    .foregroundColor(t.done ? .gray : .primary)
                    .opacity(t.done ? 0.5 : 1)
                if t.hour >= 0 {
                    Text(String(format: "⏰ %02d:%02d · %@", t.hour, t.minute, t.repeatDaily ? "每天" : "一次"))
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 1.0, green: 0.56, blue: 0.67))
                }
            }
            Spacer()
            Button(action: { delete(t) }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5...10: return "早安呀，小樱为你加油"
        case 11...13: return "中午啦，记得吃饭"
        case 14...17: return "下午好，小可陪你"
        case 18...22: return "晚上好，今天辛苦啦"
        default: return "夜深啦，该睡觉了…"
        }
    }

    var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f.string(from: Date())
    }

    func addTodo() {
        guard !newContent.isEmpty else { return }
        let t = Todo(id: store.nextId(), content: newContent, done: false,
                     hour: pickHour, minute: pickMinute, repeatDaily: repeatDaily)
        store.todos.append(t)
        store.save()
        if pickHour >= 0 { NotificationHelper.schedule(todo: t) }
        newContent = ""
        pickHour = -1; pickMinute = 0; repeatDaily = false
    }

    func toggle(_ t: Todo) {
        if let i = store.todos.firstIndex(where: { $0.id == t.id }) {
            store.todos[i].done.toggle()
            if store.todos[i].done { store.points += 3 }
            store.save()
        }
    }

    func delete(_ t: Todo) {
        NotificationHelper.cancel(todo: t)
        store.todos.removeAll { $0.id == t.id }
        store.save()
    }
}
