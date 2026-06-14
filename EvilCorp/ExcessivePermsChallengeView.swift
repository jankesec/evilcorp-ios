import SwiftUI
import AVFoundation
import Contacts
import CoreLocation
import Photos

struct ExcessivePermsChallengeView: View {
    @State private var cameraStatus = "?"
    @State private var micStatus = "?"
    @State private var contactsStatus = "?"
    @State private var photosStatus = "?"
    @State private var locationStatus = "?"
    @State private var output = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("App requests 5 privacy permissions without legitimate need. After grant, contacts are dumped and location tracked in background -- all logged via NSLog.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                Button(action: requestAll) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.shield.fill").font(.system(size: 10))
                        Text("REQUEST ALL PERMISSIONS").font(.system(size: 11, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                VStack(spacing: 6) {
                    PermRow(icon: "camera.fill", label: "Camera", status: cameraStatus, color: Color(red: 0, green: 0.83, blue: 1))
                    PermRow(icon: "mic.fill", label: "Microphone", status: micStatus, color: Color(red: 0, green: 0.83, blue: 1))
                    PermRow(icon: "person.2.fill", label: "Contacts", status: contactsStatus, color: Color(red: 0, green: 0.83, blue: 1))
                    PermRow(icon: "photo.fill", label: "Photos", status: photosStatus, color: Color(red: 0, green: 0.83, blue: 1))
                    PermRow(icon: "location.fill", label: "Location (Always)", status: locationStatus, color: Color(red: 0, green: 0.83, blue: 1))
                }
                .padding(12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)

                if !output.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(red: 0, green: 1, blue: 0.25)).frame(width: 6, height: 6)
                            Text("OUTPUT").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(Color(white: 0.4))
                        }
                        Text(output)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.25))
                            .textSelection(.enabled)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0, green: 1, blue: 0.25).opacity(0.2), lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                HStack(spacing: 0) {
                    Rectangle().fill(Color(red: 0, green: 0.83, blue: 1)).frame(width: 3)
                    Text("[!] Camera & Mic: No camera/mic feature in app\n[!] Contacts: Dumped to NSLog after grant\n[!] Location: Always tracking, never stops\n[!] All requested at once -- no gradual consent\n[!] Check: idevicesyslog | grep CONTACT_DUMP")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(white: 0.5))
                        .padding(12)
                }
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }.padding()
        }.background(Color(red: 0.04, green: 0.04, blue: 0.06))
        .onAppear { refreshStatuses() }
    }

    func requestAll() {
        AVCaptureDevice.requestAccess(for: .video) { _ in DispatchQueue.main.async { refreshStatuses() } }
        AVCaptureDevice.requestAccess(for: .audio) { _ in DispatchQueue.main.async { refreshStatuses() } }
        CNContactStore().requestAccess(for: .contacts) { ok, _ in
            if ok { dumpContacts() }
            DispatchQueue.main.async { refreshStatuses() }
        }
        PHPhotoLibrary.requestAuthorization { _ in DispatchQueue.main.async { refreshStatuses() } }
        let lm = CLLocationManager()
        lm.requestAlwaysAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { refreshStatuses() }
        output = "[+] All 5 permissions requested\n[+] Contacts dumped via NSLog\n[+] Location tracking started\n[!] Check idevicesyslog | grep CONTACT_DUMP"
    }

    func dumpContacts() {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let req = CNContactFetchRequest(keysToFetch: keys)
        try? store.enumerateContacts(with: req) { contact, _ in
            let name = "\(contact.givenName) \(contact.familyName)"
            let phone = contact.phoneNumbers.first?.value.stringValue ?? "N/A"
            NSLog("[CONTACT_DUMP] %@ | Phone: %@", name, phone)
        }
    }

    func refreshStatuses() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video) == .authorized ? "Granted" : "Denied"
        micStatus = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized ? "Granted" : "Denied"
        contactsStatus = CNContactStore.authorizationStatus(for: .contacts) == .authorized ? "Granted" : "Denied"
        photosStatus = PHPhotoLibrary.authorizationStatus() == .authorized ? "Granted" : "Denied"
        locationStatus = CLLocationManager.authorizationStatus() == .authorizedAlways ? "Granted" : "Denied"
    }
}

struct PermRow: View {
    let icon: String; let label: String; let status: String; let color: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 11)).frame(width: 22)
            Text(label).font(.system(size: 11, design: .monospaced)).foregroundColor(.white)
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(status == "Granted" ? .red : Color(white: 0.4))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background((status == "Granted" ? Color.red : Color.white).opacity(0.1))
                .cornerRadius(4)
        }
    }
}
