import SwiftUI

struct DOBPickerView: View {
    @Binding var dob: Date

    var body: some View {
        DatePicker(
            "",
            selection: $dob,
            in: ...Date(),
            displayedComponents: .date
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .colorScheme(.dark)
        .tint(Theme.accent)
    }
}
