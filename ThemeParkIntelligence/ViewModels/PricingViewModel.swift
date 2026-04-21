import Foundation
import Observation

@Observable
final class PricingViewModel {

    // MARK: - Simulation Inputs (bound to UI sliders)

    var basePrice: Double = 369
    var demandMultiplier: Double = 1.0
    var weatherFactor: Double = 1.0
    var selectedTimeSlot: PricingSimulationRequest.TimeSlot = .afternoon

    // MARK: - State

    var simulationResult: PricingSimulationResult?
    var isSimulating: Bool = false
    var errorMessage: String?

    // MARK: - Private

    private let service: DataServiceProtocol
    private var simulationTask: Task<Void, Never>?

    init(service: DataServiceProtocol = MockDataService()) {
        self.service = service
    }

    // MARK: - Public Interface

    func runSimulation() {
        simulationTask?.cancel()
        simulationTask = Task { [weak self] in
            guard let self else { return }
            isSimulating = true
            errorMessage = nil

            let request = PricingSimulationRequest(
                basePrice: basePrice,
                demandMultiplier: demandMultiplier,
                timeSlot: selectedTimeSlot,
                weatherFactor: weatherFactor
            )

            do {
                let result = try await service.runPricingSimulation(request)
                guard !Task.isCancelled else { return }
                self.simulationResult = result
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
            }

            isSimulating = false
        }
    }

    // MARK: - Computed helpers for UI

    var revenueChangeText: String {
        guard let result = simulationResult else { return "--" }
        let sign = result.revenueVsBaseline >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", result.revenueVsBaseline))%"
    }

    var revenueChangeIsPositive: Bool {
        (simulationResult?.revenueVsBaseline ?? 0) >= 0
    }

    var formattedProjectedRevenue: String {
        guard let result = simulationResult else { return "--" }
        return "¥\(String(format: "%.0f", result.projectedRevenue / 10_000))万"
    }
}
