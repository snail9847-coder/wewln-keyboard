import SwiftUI

@main
struct WewlnApp: App {
    var body: some Scene {
        WindowGroup { SetupView() }
    }
}

struct SetupView: View {
    @State private var sample = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("п р и в е т   к а к   д е л а")
                        .font(.title3).padding(.vertical, 8)
                    Text("Русская клавиатура с пробелами между буквами.")
                } header: { Text("wewln") }
                Section("Включение") {
                    Text("1. Открой Настройки → Основные → Клавиатура → Клавиатуры → Новые клавиатуры.")
                    Text("2. Выбери wewln.")
                    Text("3. При вводе удерживай 🌐 и выбери wewln.")
                }
                Section("Попробуй") {
                    TextField("Выбери wewln через 🌐", text: $sample, axis: .vertical)
                        .lineLimit(3...6)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section("Приватность и ограничения") {
                    Text("Полный доступ не нужен. В проекте нет сетевых запросов, аналитики или сохранения набранного текста.")
                    Text("В полях паролей и некоторых приложениях iOS заменяет стороннюю клавиатуру системной.")
                    Text("При бесплатной подписи обновляй приложение через AltStore до истечения 7 дней.")
                }
            }
            .navigationTitle("wewln")
        }
    }
}
