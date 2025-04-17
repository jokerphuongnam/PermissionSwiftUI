import UserNotifications
import LocalAuthentication
import HealthKit
import CoreMotion
import Contacts
import Photos
import AVFoundation
import PushKit

@MainActor @preconcurrency public protocol PermissionWorker: Sendable {
    var authorize: AuthorizedPermission { get async throws }
}

@available(iOS 10.0, *)
extension PermissionWorker where Self == NotificationPermission {
    @MainActor @preconcurrency public static func notification(options: UNAuthorizationOptions, name: String = "Notification", retryWhenDeniedOnFirstTime retry: Bool = true) -> NotificationPermission {
        if PermissionWorkerDI.notification == nil {
            PermissionWorkerDI.notification = NotificationPermission(options: options, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if options != PermissionWorkerDI.notification.options {
            PermissionWorkerDI.notification = NotificationPermission(options: options, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.notification
    }
}

@available(iOS, introduced: 14.0, deprecated: 16.0)
extension PermissionWorker where Self == NearbyPermission {
    @MainActor @preconcurrency public static func nearBy(name: String = "Nearby Interaction") -> NearbyPermission {
        if PermissionWorkerDI.nearBy == nil {
            PermissionWorkerDI.nearBy = NearbyPermission(name: name)
        }
        return PermissionWorkerDI.nearBy
    }
    
    @MainActor @preconcurrency public static var nearBy: NearbyPermission {
        if PermissionWorkerDI.nearBy == nil {
            PermissionWorkerDI.nearBy = NearbyPermission(name: "Nearby Interaction")
        }
        return PermissionWorkerDI.nearBy
    }
}

@available(iOS 11.0, *)
extension PermissionWorker where Self == NFCPermission {
    @MainActor @preconcurrency public static func nfc(alertMessage: String, name: String = "NFC") -> NFCPermission {
        if PermissionWorkerDI.nfc == nil {
            PermissionWorkerDI.nfc = NFCPermission(alertMessage: alertMessage, name: name)
        } else if alertMessage != PermissionWorkerDI.nfc.alertMessage {
            PermissionWorkerDI.nfc = NFCPermission(alertMessage: alertMessage, name: name)
        }
        return PermissionWorkerDI.nfc
    }
}

@available(iOS 8.0, *)
extension PermissionWorker where Self == VoipPermission {
    @MainActor @preconcurrency public static func voip(queue: DispatchQueue = .main, desiredPushTypes: Set<PKPushType>, name: String = "PushKit (VoIP)") -> VoipPermission {
        if PermissionWorkerDI.voip == nil {
            PermissionWorkerDI.voip = VoipPermission(queue: queue, desiredPushTypes: desiredPushTypes, name: name)
        } else if desiredPushTypes != PermissionWorkerDI.voip.desiredPushTypes {
            PermissionWorkerDI.voip = VoipPermission(queue: queue, desiredPushTypes: desiredPushTypes, name: name)
        }
        return PermissionWorkerDI.voip
    }
}

@available(iOS 8.0, *)
extension PermissionWorker where Self == CameraPermission {
    @MainActor @preconcurrency public static func camera(for mediaType: AVMediaType, name: String = "Camera", retryWhenDeniedOnFirstTime retry: Bool = true) -> CameraPermission {
        if PermissionWorkerDI.camera == nil {
            PermissionWorkerDI.camera = CameraPermission(for: mediaType, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if mediaType != PermissionWorkerDI.camera.mediaType {
            PermissionWorkerDI.camera = CameraPermission(for: mediaType, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.camera
    }
}

@available(iOS, introduced: 8.0)
extension PermissionWorker where Self == MicrophonePermission {
    @MainActor @preconcurrency public static func microphone(name: String = "Microphone", retryWhenDeniedOnFirstTime retry: Bool = true) -> MicrophonePermission {
        if PermissionWorkerDI.microphone == nil {
            PermissionWorkerDI.microphone = MicrophonePermission(name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.microphone
    }
    
    @MainActor @preconcurrency public static var microphone: MicrophonePermission {
        if PermissionWorkerDI.microphone == nil {
            PermissionWorkerDI.microphone = MicrophonePermission(name: "Microphone")
        }
        return PermissionWorkerDI.microphone
    }
}

extension PermissionWorker where Self == CarPlayPermission {
    @MainActor @preconcurrency public static func carPlay(name: String = "CarPlay") -> CarPlayPermission {
        if PermissionWorkerDI.carPlay == nil {
            PermissionWorkerDI.carPlay = CarPlayPermission(name: name)
        }
        return PermissionWorkerDI.carPlay
    }
    
    @MainActor @preconcurrency public static var carPlay: CarPlayPermission {
        if PermissionWorkerDI.carPlay == nil {
            PermissionWorkerDI.carPlay = CarPlayPermission(name: "CarPlay")
        }
        return PermissionWorkerDI.carPlay
    }
}

@available(iOS 14, *)
extension PermissionWorker where Self == PhotoLibraryPermission {
    @MainActor @preconcurrency public static func photoLibrary(for accessLevel: PHAccessLevel, name: String = "Photo Library", retryWhenDeniedOnFirstTime retry: Bool = true) -> PhotoLibraryPermission {
        if PermissionWorkerDI.photoLibrary == nil {
            PermissionWorkerDI.photoLibrary = PhotoLibraryPermission(for: accessLevel, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if accessLevel != PermissionWorkerDI.photoLibrary.accessLevel {
            PermissionWorkerDI.photoLibrary = PhotoLibraryPermission(for: accessLevel, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.photoLibrary
    }
}

@available(iOS 14.0, *)
extension PermissionWorker where Self == LocationPermission {
    @MainActor @preconcurrency public static func location(for location: LocationPermissionType, name: String = "Location", retryWhenDeniedOnFirstTime retry: Bool = true) -> LocationPermission {
        if PermissionWorkerDI.location == nil {
            PermissionWorkerDI.location = LocationPermission(for: location, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if location != PermissionWorkerDI.location.location {
            PermissionWorkerDI.location = LocationPermission(for: location, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.location
    }
}

@available(iOS 13.1, *)
extension PermissionWorker where Self == BluetoothPermission {
    @MainActor @preconcurrency public static func bluetooth(name: String = "Bluetooth", retryWhenDeniedOnFirstTime retry: Bool = true) -> BluetoothPermission {
        if PermissionWorkerDI.bluetooth == nil {
            PermissionWorkerDI.bluetooth = BluetoothPermission(name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.bluetooth
    }
    
    @MainActor @preconcurrency public static var bluetooth: BluetoothPermission {
        if PermissionWorkerDI.bluetooth == nil {
            PermissionWorkerDI.bluetooth = BluetoothPermission(name: "Bluetooth")
        }
        return PermissionWorkerDI.bluetooth
    }
}

@available(iOS 9.0, *)
extension PermissionWorker where Self == ContactsPermission {
    @MainActor @preconcurrency public static func contacts(for entityType: CNEntityType = .contacts, name: String = "Contacts", retryWhenDeniedOnFirstTime retry: Bool = true) -> ContactsPermission {
        if PermissionWorkerDI.contacts == nil {
            PermissionWorkerDI.contacts = ContactsPermission(for: entityType, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if entityType != PermissionWorkerDI.contacts.entityType {
            PermissionWorkerDI.contacts = ContactsPermission(for: entityType, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.contacts
    }
    
    @MainActor @preconcurrency public static var contacts: ContactsPermission {
        self.contacts()
    }
}

@available(iOS 6.0, *)
extension PermissionWorker where Self == EventKitPermission {
    @MainActor @preconcurrency public static func reminder(name: String = "Reminders", retryWhenDeniedOnFirstTime retry: Bool = true) -> EventKitPermission {
        if PermissionWorkerDI.reminder == nil {
            PermissionWorkerDI.reminder = EventKitPermission(for: .reminder, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.reminder
    }
    
    @MainActor @preconcurrency public static var reminder: EventKitPermission {
        if PermissionWorkerDI.reminder == nil {
            PermissionWorkerDI.reminder = EventKitPermission(for: .reminder, name: "Reminders")
        }
        return PermissionWorkerDI.reminder
    }
    
    @MainActor @preconcurrency public static func calendar(name: String = "Calendar", retryWhenDeniedOnFirstTime retry: Bool = true) -> EventKitPermission {
        if PermissionWorkerDI.calendar == nil {
            PermissionWorkerDI.calendar = EventKitPermission(for: .event, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.calendar
    }
    
    @MainActor @preconcurrency public static var calendar: EventKitPermission {
        if PermissionWorkerDI.calendar == nil {
            PermissionWorkerDI.calendar = EventKitPermission(for: .event, name: "Calendar")
        }
        return PermissionWorkerDI.calendar
    }
}

@available(iOS, introduced: 8.0)
public extension PermissionWorker where Self == MotionPermission {
    @MainActor @preconcurrency public static func motion(from: Date, to: Date, queue: OperationQueue = .current ?? .main, name: String = "Motion & Fitness", retryWhenDeniedOnFirstTime retry: Bool = true, completion: ((_ activities: [CMMotionActivity]) -> Void)? = nil) -> MotionPermission {
        if PermissionWorkerDI.motion == nil {
            PermissionWorkerDI.motion = MotionPermission(from: from, to: to, queue: queue, name: name, retryWhenDeniedOnFirstTime: retry, completion: completion)
        } else if from.timeIntervalSince1970 != PermissionWorkerDI.motion.from.timeIntervalSince1970 || to.timeIntervalSince1970 != PermissionWorkerDI.motion.to.timeIntervalSince1970 {
            PermissionWorkerDI.motion = MotionPermission(from: from, to: to, queue: queue, name: name, retryWhenDeniedOnFirstTime: retry, completion: completion)
        }
        return PermissionWorkerDI.motion
    }
    
    @MainActor @preconcurrency public static var motion: MotionPermission {
        motion(from: Date(), to: Date())
    }
}

@available(iOS 10.0, *)
public extension PermissionWorker where Self == SpeechPermission {
    @MainActor @preconcurrency public static func speech(name: String = "Speech Recognition") -> SpeechPermission {
        if PermissionWorkerDI.speech == nil {
            PermissionWorkerDI.speech = SpeechPermission(name: name)
        }
        return PermissionWorkerDI.speech
    }
    
    @MainActor @preconcurrency public static var speech: SpeechPermission {
        if PermissionWorkerDI.speech == nil {
            PermissionWorkerDI.speech = SpeechPermission(name: "Speech Recognition")
        }
        return PermissionWorkerDI.speech
    }
}

@available(iOS 9.3, *)
extension PermissionWorker where Self == MediaLibraryPermission {
    @MainActor @preconcurrency public static func mediaLibrary(name: String = "Media Library", retryWhenDeniedOnFirstTime retry: Bool = true) -> MediaLibraryPermission {
        if PermissionWorkerDI.mediaLibrary == nil {
            PermissionWorkerDI.mediaLibrary = MediaLibraryPermission(name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.mediaLibrary
    }
    
    @MainActor @preconcurrency public static var mediaLibrary: MediaLibraryPermission {
        if PermissionWorkerDI.mediaLibrary == nil {
            PermissionWorkerDI.mediaLibrary = MediaLibraryPermission(name: "Media Library")
        }
        return PermissionWorkerDI.mediaLibrary
    }
}

@available(iOS 15.0, watchOS 8.0, macOS 13.0, *)
extension PermissionWorker where Self == HealthKitPermission {
    @MainActor @preconcurrency public static func healthKit(toShare typesToShare: Set<HKSampleType>, toRead typesToRead: Set<HKObjectType>, name: String) -> HealthKitPermission {
        if PermissionWorkerDI.motion == nil {
            PermissionWorkerDI.healthKit = HealthKitPermission(toShare: typesToShare, toRead: typesToRead, name: name)
        } else if typesToShare != PermissionWorkerDI.healthKit.typesToShare || typesToRead != PermissionWorkerDI.healthKit.typesToRead {
            PermissionWorkerDI.healthKit = HealthKitPermission(toShare: typesToShare, toRead: typesToRead, name: name)
        }
        return PermissionWorkerDI.healthKit
    }
}

@available(iOS 8.0, *)
extension PermissionWorker where Self == HomeKitPermission {
    @MainActor @preconcurrency public static func homeKit(queue: DispatchQueue, name: String = "HomeKit") -> HomeKitPermission {
        if PermissionWorkerDI.homeKit == nil {
            PermissionWorkerDI.homeKit = HomeKitPermission(queue: queue, name: name)
        }
        return PermissionWorkerDI.homeKit
    }
    
    @MainActor @preconcurrency public static var homeKit: HomeKitPermission {
        if PermissionWorkerDI.homeKit == nil {
            PermissionWorkerDI.homeKit = HomeKitPermission(queue: .main, name: "HomeKit")
        }
        return PermissionWorkerDI.homeKit
    }
}

@available(iOS 10.0, *)
extension PermissionWorker where Self == SiriPermission {
    @MainActor @preconcurrency public static func siri(name: String = "Siri", retryWhenDeniedOnFirstTime retry: Bool = true) -> SiriPermission {
        if PermissionWorkerDI.siri == nil {
            PermissionWorkerDI.siri = SiriPermission(name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.siri
    }
    
    @MainActor @preconcurrency public static var siri: SiriPermission {
        if PermissionWorkerDI.siri == nil {
            PermissionWorkerDI.siri = SiriPermission(name: "Siri")
        }
        return PermissionWorkerDI.siri
    }
}

@available(iOS 10.0, *)
extension PermissionWorker where Self == TrackingPermission {
    @MainActor @preconcurrency public static func tracking(name: String = "Tracking", retryWhenDeniedOnFirstTime retry: Bool = true) -> TrackingPermission {
        if PermissionWorkerDI.tracking == nil {
            PermissionWorkerDI.tracking = TrackingPermission(name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.tracking
    }
    
    @MainActor @preconcurrency public static var tracking: TrackingPermission {
        if PermissionWorkerDI.tracking == nil {
            PermissionWorkerDI.tracking = TrackingPermission(name: "Tracking")
        }
        return PermissionWorkerDI.tracking
    }
}

@available(iOS 8.0, *)
extension PermissionWorker where Self == BiometricPermission {
    @MainActor @preconcurrency public static func biometric(_ policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics, localizedReason: String, name: String = "Biometric", retryWhenDeniedOnFirstTime retry: Bool = true) -> BiometricPermission {
        if PermissionWorkerDI.biometric == nil {
            PermissionWorkerDI.biometric = BiometricPermission(policy: policy, localizedReason: localizedReason, name: name, retryWhenDeniedOnFirstTime: retry)
        } else if policy != PermissionWorkerDI.biometric.policy || localizedReason != PermissionWorkerDI.biometric.localizedReason {
            PermissionWorkerDI.biometric = BiometricPermission(policy: policy, localizedReason: localizedReason, name: name, retryWhenDeniedOnFirstTime: retry)
        }
        return PermissionWorkerDI.biometric
    }
}
