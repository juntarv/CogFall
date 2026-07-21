import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: AppRouter

    @State private var animationsOn = true
    @State private var hapticsOn = true
    @State private var showResetAlert = false

    private var version: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    var body: some View {
        ZStack {
            SceneBackground()
            RotatingGear(material: .dark, duration: 60).frame(width: 180, height: 180)
                .opacity(0.1).position(x: 340, y: 640)

            VStack(spacing: 0) {
                ScreenHeader(eyebrow: "The workbench", title: "Settings",
                             onBack: { router.backToMenu() })

                VStack(spacing: 0) {
                    SettingRow(icon: "sparkles", name: "Animation Intensity",
                               desc: "Drifting gears, glow & particle juice") {
                        Toggle("", isOn: $animationsOn)
                            .labelsHidden()
                            .tint(Palette.brass)
                            .onChange(of: animationsOn) { v in
                                Haptic.medium()
                                store.preferences().animationsOn = v
                                store.save()
                            }
                    }
                    Divider().background(Palette.hairline)
                    SettingRow(icon: "iphone.radiowaves.left.and.right", name: "Haptics",
                               desc: "Taptic feedback on mesh, drop & jam") {
                        Toggle("", isOn: $hapticsOn)
                            .labelsHidden()
                            .tint(Palette.brass)
                            .onChange(of: hapticsOn) { v in
                                Haptic.enabled = v
                                Haptic.medium()
                                store.preferences().hapticsOn = v
                                store.save()
                            }
                    }
                    Divider().background(Palette.hairline)
                    SettingRow(icon: "arrow.counterclockwise", name: "Reset Progress",
                               desc: "Wipe bays, marques & scores", danger: true) {
                        Button(action: { Haptic.heavy(); showResetAlert = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill").font(.system(size: 13))
                                Text("Reset").font(Typo.plate(12)).tracking(1).textCase(.uppercase)
                            }
                            .foregroundColor(Color(hex: "#FFB98C"))
                            .padding(.horizontal, 16).padding(.vertical, 11)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#421A10").opacity(0.55)))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Palette.rust.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.surface2.opacity(0.62), Palette.bg.opacity(0.82)],
                                             startPoint: .top, endPoint: .bottom))
                )
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
                .premiumShadow()
                .padding(.horizontal, 20).padding(.top, 8)

                Spacer()

                VStack(spacing: 8) {
                    GearView(material: .brass).frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 3)
                    Text("CogFall").font(Typo.plate(11)).tracking(3).textCase(.uppercase).foregroundColor(Palette.text3)
                    Text("Version \(version)").font(Typo.display(15)).foregroundColor(Palette.text2)
                }
                .padding(.bottom, 44)
            }
        }
        .onAppear {
            let p = store.preferences()
            animationsOn = p.animationsOn
            hapticsOn = p.hapticsOn
        }
        .alert("Reset all progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { Haptic.light() }
            Button("Reset", role: .destructive) {
                store.resetProgress()
                Haptic.warning()
                router.backToMenu()
            }
        } message: {
            Text("This wipes every bay, marque and score, and returns you to the intro. This cannot be undone.")
        }
    }
}

private struct SettingRow<Trailing: View>: View {
    var icon: String
    var name: String
    var desc: String
    var danger: Bool = false
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(RadialGradient(colors: danger ? [Color(hex: "#5A251A"), Color(hex: "#2A0F0A")]
                                                        : [Color(hex: "#1D5058"), Color(hex: "#0E2C31")],
                                         center: .init(x: 0.38, y: 0.30), startRadius: 1, endRadius: 40))
                    .frame(width: 48, height: 48)
                RoundedRectangle(cornerRadius: 14).strokeBorder(
                    danger ? Palette.rust.opacity(0.5) : Palette.brass.opacity(0.3), lineWidth: 1)
                    .frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 19, weight: .semibold))
                    .foregroundColor(danger ? Color(hex: "#FFB98C") : Palette.brassHi)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(Typo.display(18)).foregroundColor(danger ? Color(hex: "#FFB98C") : Palette.text)
                Text(desc).font(Typo.body(12)).foregroundColor(Palette.text2)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            Spacer()
            trailing()
        }
        .padding(.vertical, 18)
    }
}
