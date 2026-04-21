import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("总览", systemImage: "chart.bar.fill")
                }

            PersonaMainView()
                .tabItem {
                    Label("人物", systemImage: "person.3.fill")
                }

            WeatherIntelligenceView()
                .tabItem {
                    Label("天气", systemImage: "cloud.sun.bolt.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
