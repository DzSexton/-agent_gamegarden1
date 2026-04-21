import SwiftUI

struct PersonaMainView: View {
    @State private var viewModel = PersonaViewModel()
    @State private var navPath  = NavigationPath()

    private let columns = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    var body: some View {
        NavigationStack(path: $navPath) {
            GeometryReader { geo in
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(PersonaCategory.allCases) { category in
                        categoryCell(category: category, size: geo.size)
                            .onTapGesture {
                                navPath.append(PersonaRoute.list(category))
                            }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("人物类型")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: PersonaRoute.self) { route in
                switch route {
                case .list(let category):
                    PersonaListView(
                        category: category,
                        personas: viewModel.personas(for: category),
                        navPath: $navPath
                    )
                case .detail(let persona):
                    PersonaDetailView(persona: persona, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Category Cell

    private func categoryCell(category: PersonaCategory, size: CGSize) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 大号装饰图标（背景）
            Image(systemName: category.icon)
                .font(.system(size: 90))
                .foregroundStyle(.white.opacity(0.12))
                .offset(x: 30, y: 30)

            // 主内容
            VStack(alignment: .leading, spacing: 10) {
                Spacer()

                Image(systemName: category.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Text(category.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.80))
                }

                // 人物数量徽章
                let count = viewModel.personas(for: category).count
                Text("\(count) 个档案")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(category.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.92), in: Capsule())
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: size.width / 2, height: size.height / 2)
        .contentShape(Rectangle())
    }
}

#Preview {
    PersonaMainView()
}
