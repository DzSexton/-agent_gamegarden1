import SwiftUI

struct AIAdviceSheet: View {
    @Bindable var viewModel: PersonaViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 加载动画
                    if viewModel.isLoadingAI && viewModel.aiAdviceText.isEmpty {
                        loadingPlaceholder
                    }

                    // 流式文本（Markdown 渲染）
                    if !viewModel.aiAdviceText.isEmpty {
                        markdownContent
                    }

                    // 生成中指示器
                    if viewModel.isLoadingAI {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.7)
                            Text("AI 正在生成建议…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("AI 智能建议")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 模型标识
                    Text("TPI-GAI v2.3.1")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.regularMaterial, in: Capsule())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .disabled(viewModel.isLoadingAI)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Markdown Content

    private var markdownContent: some View {
        Group {
            if let attributed = try? AttributedString(
                markdown: viewModel.aiAdviceText,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            ) {
                Text(attributed)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            } else {
                Text(viewModel.aiAdviceText)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
    }

    // MARK: - Loading Placeholder

    private var loadingPlaceholder: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(height: 14)
                    .frame(maxWidth: i == 4 ? 200 : .infinity)
            }
        }
        .redacted(reason: .placeholder)
    }
}
