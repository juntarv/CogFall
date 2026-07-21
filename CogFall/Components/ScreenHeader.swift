import SwiftUI

/// Shared header: back button + engraved eyebrow + title + optional trailing view.
struct ScreenHeader: View {
    var eyebrow: String
    var title: String
    var onBack: () -> Void
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 14) {
            CircleArtButton(systemIcon: "chevron.left", size: 46, action: onBack)
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrow).eyebrow()
                Text(title).font(Typo.display(26)).foregroundColor(Palette.text).liftedText()
            }
            Spacer()
            if let trailing { trailing }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}
