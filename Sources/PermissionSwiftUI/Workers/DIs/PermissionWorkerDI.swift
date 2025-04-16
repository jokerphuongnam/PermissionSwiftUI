import UserNotifications
import NearbyInteraction
import CoreNFC

@MainActor
enum PermissionWorkerDI {
    @MainActor static var notification: NotificationPermission!
    @MainActor static var nearBy: NearbyPermission!
    @MainActor static var nfc: NFCPermission!
    @MainActor static var voip: VoipPermission!
    @MainActor static var camera: CameraPermission!
    @MainActor static var microphone: MicrophonePermission!
    @MainActor static var carPlay: CarPlayPermission!
    @MainActor static var photoLibrary: PhotoLibraryPermission!
    @MainActor static var location: LocationPermission!
    @MainActor static var bluetooth: BluetoothPermission!
    @MainActor static var contacts: ContactsPermission!
    @MainActor static var calendar: EventKitPermission!
    @MainActor static var reminder: EventKitPermission!
    @MainActor static var motion: MotionPermission!
    @MainActor static var speech: SpeechPermission!
    @MainActor static var mediaLibrary: MediaLibraryPermission!
    @MainActor static var healthKit: HealthKitPermission!
    @MainActor static var homeKit: HomeKitPermission!
    @MainActor static var siri: SiriPermission!
    @MainActor static var tracking: TrackingPermission!
    @MainActor static var biometric: BiometricPermission!
}
