import Contacts

class ContactsService {
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { ok, _ in
            DispatchQueue.main.async { completion(ok) }
        }
    }

    func fetchUpcomingBirthdays(days: Int = 14) -> [String] {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var results: [(name: String, daysAway: Int)] = []

        try? store.enumerateContacts(with: request) { contact, _ in
            guard let bday = contact.birthday else { return }
            let thisYear = cal.component(.year, from: Date())
            var comps = bday
            comps.year = thisYear
            guard let candidate = cal.date(from: comps) else { return }
            let target = candidate < today
                ? (cal.date(byAdding: .year, value: 1, to: candidate) ?? candidate)
                : candidate
            let diff = cal.dateComponents([.day], from: today, to: target).day ?? 999
            if diff <= days {
                let name = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }.joined(separator: " ")
                if !name.isEmpty { results.append((name, diff)) }
            }
        }

        return results.sorted { $0.daysAway < $1.daysAway }.map {
            $0.daysAway == 0
                ? "\($0.name)'s birthday is today"
                : "\($0.name)'s birthday in \($0.daysAway) day\($0.daysAway == 1 ? "" : "s")"
        }
    }
}
