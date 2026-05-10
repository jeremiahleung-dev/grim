import HealthKit

class HealthService {
    private let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard Self.isAvailable else { completion(false); return }
        let types: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.workoutType()
        ]
        store.requestAuthorization(toShare: nil, read: types) { ok, _ in
            DispatchQueue.main.async { completion(ok) }
        }
    }

    func fetchSnapshot(completion: @escaping (HealthSnapshot) -> Void) {
        guard Self.isAvailable else { completion(HealthSnapshot()); return }
        var snap = HealthSnapshot()
        let group = DispatchGroup()

        group.enter()
        fetchAvgSleep { snap.avgSleepHours = $0; group.leave() }

        group.enter()
        fetchAvgSteps { snap.avgDailySteps = $0; group.leave() }

        group.enter()
        fetchRestingHR { snap.restingHeartRate = $0; group.leave() }

        group.enter()
        fetchWorkoutMinutes { snap.weeklyWorkoutMinutes = $0; group.leave() }

        group.notify(queue: .main) { completion(snap) }
    }

    // MARK: - Private queries

    private func fetchAvgSleep(completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil); return
        }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else { completion(nil); return }
            let seconds = samples
                .filter { $0.value != HKCategoryValueSleepAnalysis.inBed.rawValue }
                .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let avg = (seconds / 3600.0) / 7.0
            DispatchQueue.main.async { completion(avg > 0 ? avg : nil) }
        }
        store.execute(query)
    }

    private func fetchAvgSteps(completion: @escaping (Int?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil); return
        }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
            let total = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async { completion(total > 0 ? Int(total / 7) : nil) }
        }
        store.execute(query)
    }

    private func fetchRestingHR(completion: @escaping (Double?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil); return
        }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .discreteAverage) { _, stats, _ in
            let bpm = stats?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            DispatchQueue.main.async { completion(bpm > 0 ? bpm : nil) }
        }
        store.execute(query)
    }

    private func fetchWorkoutMinutes(completion: @escaping (Int?) -> Void) {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let workouts = samples as? [HKWorkout] else { completion(nil); return }
            let mins = Int(workouts.reduce(0.0) { $0 + $1.duration } / 60.0)
            DispatchQueue.main.async { completion(mins > 0 ? mins : nil) }
        }
        store.execute(query)
    }
}

struct HealthSnapshot {
    var avgSleepHours: Double?
    var avgDailySteps: Int?
    var restingHeartRate: Double?
    var weeklyWorkoutMinutes: Int?

    var isEmpty: Bool {
        avgSleepHours == nil && avgDailySteps == nil && restingHeartRate == nil && weeklyWorkoutMinutes == nil
    }

    var summaryString: String {
        var parts: [String] = []
        if let s = avgSleepHours  { parts.append(String(format: "%.1f hrs sleep/night avg", s)) }
        if let s = avgDailySteps  { parts.append("\(s.formatted()) steps/day avg") }
        if let h = restingHeartRate { parts.append(String(format: "%.0f bpm resting HR", h)) }
        if let w = weeklyWorkoutMinutes { parts.append("\(w) workout mins this week") }
        return parts.joined(separator: ", ")
    }
}
