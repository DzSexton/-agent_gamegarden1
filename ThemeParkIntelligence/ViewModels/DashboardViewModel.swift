import Foundation
import Observation

@Observable
final class DashboardViewModel {

    // MARK: - State

    var snapshot: DashboardSnapshot?
    var alerts: [TPIAlert] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // 自动刷新间隔（秒）
    var refreshInterval: TimeInterval = 30

    // MARK: - Private

    private let service: DataServiceProtocol
    private var refreshTask: Task<Void, Never>?

    init(service: DataServiceProtocol = MockDataService()) {
        self.service = service
    }

    deinit {
        stopAutoRefresh()
    }

    // MARK: - Public Interface

    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        await refresh()
        isLoading = false
    }

    func startAutoRefresh() {
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                guard !Task.isCancelled else { break }
                await refresh()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func acknowledgeAlert(id: UUID) {
        guard let idx = alerts.firstIndex(where: { $0.id == id }) else { return }
        alerts[idx].isAcknowledged = true
    }

    // MARK: - Computed

    var unacknowledgedCriticalCount: Int {
        alerts.filter { $0.severity == .critical && !$0.isAcknowledged }.count
    }

    // MARK: - Private

    private func refresh() async {
        async let snapshotResult = service.fetchDashboardSnapshot()
        async let alertsResult = service.fetchAlerts()

        do {
            let (newSnapshot, newAlerts) = try await (snapshotResult, alertsResult)
            self.snapshot = newSnapshot
            self.alerts = newAlerts
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
