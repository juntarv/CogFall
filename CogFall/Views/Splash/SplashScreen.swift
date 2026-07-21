import SwiftUI

/// Purely visual splash — no logic, no timers, no Core Data. Only an entry animation.
struct SplashScreen: View {
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            SceneBackground()

            VStack(spacing: 26) {
                ZStack {
                    RotatingGear(material: .brass, duration: 16, clockwise: true)
                        .frame(width: 190, height: 190)
                        .shadow(color: Palette.power.opacity(0.4), radius: 26)
                    RotatingGear(material: .steel, duration: 12, clockwise: false)
                        .frame(width: 108, height: 108)
                        .offset(x: -86, y: -70)
                    RotatingGear(material: .brass, duration: 20, clockwise: false)
                        .frame(width: 78, height: 78)
                        .offset(x: 78, y: 64)
                    Circle().fill(RadialGradient(colors: [Color(hex: "#3A2408"), Color(hex: "#160D03")],
                                                 center: .init(x: 0.4, y: 0.32), startRadius: 1, endRadius: 40))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "gearshape.fill").font(.system(size: 24)).foregroundColor(Palette.brassHi))
                }
                .frame(width: 240, height: 240)
                .scaleEffect(hasAppeared ? 1 : 0.7)
                .opacity(hasAppeared ? 1 : 0)

                VStack(spacing: 12) {
                    Text("COGFALL")
                        .font(Typo.display(56))
                        .foregroundStyle(Palette.brassPlate)
                        .liftedText()
                    Text("The gravity machine shop")
                        .font(Typo.plate(11)).tracking(4).textCase(.uppercase)
                        .foregroundColor(Palette.text2)
                }
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 14)
            }

            VStack {
                Spacer()
                VStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Palette.text.opacity(0.12)).frame(width: 150, height: 4)
                        Capsule().fill(LinearGradient(colors: [Palette.brassDeep, Palette.brassHi],
                                                      startPoint: .leading, endPoint: .trailing))
                            .frame(width: hasAppeared ? 150 : 20, height: 4)
                    }
                    Text("Winding the mainspring")
                        .font(Typo.plate(10)).tracking(3).textCase(.uppercase)
                        .foregroundColor(Palette.text2)
                }
                .padding(.bottom, 90)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { hasAppeared = true }
        }
    }
}
