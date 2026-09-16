# Seneste byg — GRØN — appen blev bygget

- dato: 2026-09-16 22:04 UTC
- gren: jarvis
- sha: 06bf4f1b6a6bffb838b8d77c237e85e7bbc217a9
- kørsel: https://github.com/lubbe05/jarvis-notch/actions/runs/35155427375
- artifact: boringNotch-jarvis-06bf4f1 (zip, og dmg hvis den lykkedes)
- signering: OK — alt signeret med ad hoc, ingen indlejret del har et team-id
- udgivelse: jarvis-v20260916-06bf4f1 — https://github.com/lubbe05/jarvis-notch/releases/tag/jarvis-v20260916-06bf4f1

## Fejl og advarsler (de første 200 linjer)

```
2026-09-16 22:02:25.576 appintentsmetadataprocessor[20012:60244] warning: Metadata extraction skipped. No AppIntents.framework dependency found.
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:17:17: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:30:34: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:33:20: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:33:40: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:33:13: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:43:27: warning: conformance of 'NSImage' to 'Sendable' is unavailable; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:30:26: warning: non-sendable type 'Task<NSImage?, Never>' cannot exit actor-isolated context in call to nonisolated property 'value'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:30:34: warning: non-sendable type 'NSImage?' of nonisolated property 'value' cannot be sent to actor-isolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:43:22: warning: non-sendable type 'Task<NSImage?, Never>' cannot exit actor-isolated context in call to nonisolated property 'value'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:43:27: warning: non-sendable type 'NSImage?' of nonisolated property 'value' cannot be sent to actor-isolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ThumbnailService.swift:59:26: warning: non-sendable result type 'NSImage?' cannot be sent from nonisolated context in call to instance method 'accessSecurityScopedResource(accessor:)'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/Services/ImageProcessingService.swift:201:20: warning: no calls to throwing functions occur within 'try' expression
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Onboarding/SparkleView.swift:58:13: warning: initialization of immutable value 'area' was never used; consider replacing with assignment to '_' or removing it
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Onboarding/SparkleView.swift:59:13: warning: immutable value 'baseBirthRate' was never used; consider replacing with '_' or removing it
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:39:54: warning: non-sendable result type 'NSImage?' cannot be sent from actor-isolated context in call to instance method 'thumbnail(for:size:)'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:225:13: warning: initialization of immutable value 'selectedFolderURLs' was never used; consider replacing with assignment to '_' or removing it
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:491:36: warning: no 'async' operations occur within 'await' expression
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:564:45: warning: no calls to throwing functions occur within 'try' expression
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:575:23: warning: 'catch' block is unreachable because no errors are thrown in 'do' block
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:815:21: warning: no 'async' operations occur within 'await' expression
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:845:21: warning: no 'async' operations occur within 'await' expression
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:703:31: warning: main actor-isolated property 'indexOfSelectedItem' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:709:31: warning: call to main actor-isolated instance method 'validateVisibleColumns()' in a synchronous nonisolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:710:48: warning: main actor-isolated property 'directoryURL' can not be referenced from a nonisolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Shelf/ViewModels/ShelfItemViewModel.swift:711:31: warning: main actor-isolated property 'directoryURL' can not be mutated from a nonisolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/YouTube Music Controller/YouTubeMusicController.swift:221:23: warning: capture of 'self' with non-sendable type 'YouTubeMusicController?' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/YouTube Music Controller/YouTubeMusicController.swift:224:23: warning: capture of 'self' with non-sendable type 'YouTubeMusicController?' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/YouTube Music Controller/YouTubeMusicController.swift:327:23: warning: capture of 'self' with non-sendable type 'YouTubeMusicController?' in a '@Sendable' closure
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/YouTube Music Controller/YouTubeMusicController.swift:327:23: warning: capture of 'self' with non-sendable type 'YouTubeMusicController?' in an isolated closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/YouTube Music Controller/YouTubeMusicController.swift:449:29: warning: capture of 'self' with non-sendable type 'YouTubeMusicController?' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/SpotifyController.swift:147:42: warning: capture of 'self' with non-sendable type 'SpotifyController?' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/MediaControllers/SpotifyController.swift:156:25: warning: capture of 'self' with non-sendable type 'SpotifyController?' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/managers/MusicManager.swift:320:54: warning: non-sendable result type 'NSAppleEventDescriptor?' cannot be sent from nonisolated context in call to class method 'execute'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/managers/MusicManager.swift:387:65: warning: non-sendable result type 'NSAppleEventDescriptor?' cannot be sent from nonisolated context in call to class method 'execute'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/managers/MusicManager.swift:728:54: warning: non-sendable result type 'NSAppleEventDescriptor?' cannot be sent from nonisolated context in call to class method 'execute'; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/extensions/NSScreen+UUID.swift:61:19: warning: call to main actor-isolated instance method 'rebuildCache()' in a synchronous nonisolated context; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/components/Onboarding/OnboardingView.swift:160:38: warning: result of call to 'ensureAccessibilityAuthorization(promptIfNeeded:)' is unused
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:102:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:3:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'AsyncXPCConnection'
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:103:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:113:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:114:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:122:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:132:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:133:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:141:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:153:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:154:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:168:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:169:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:184:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:185:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:201:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:202:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:216:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:217:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:232:43: warning: type 'RemoteXPCService<any BoringNotchXPCHelperProtocol>' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/XPCHelperClient/XPCHelperClient.swift:233:17: warning: capture of 'self' with non-sendable type 'XPCHelperClient' in a '@Sendable' closure; this is an error in the Swift 6 language mode
/Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/extensions/NSItemProvider+LoadHelpers.swift:44:21: warning: capture of 'self' with non-sendable type 'NSItemProvider' in a '@Sendable' closure
2026-09-16 22:03:53.380 appintentsmetadataprocessor[23312:69112] warning: Metadata extraction skipped. No AppIntents.framework dependency found.
```

## Signeringen (ad hoc) og team-id-tjekket

```
== 1. indlejrede binærer, dybeste først ==
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc/Contents/MacOS/Installer: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc/Contents/MacOS/Installer  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc/Contents/MacOS/Downloader: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc/Contents/MacOS/Downloader  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app/Contents/MacOS/Updater: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app/Contents/MacOS/Updater  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc/Contents/MacOS/BoringNotchXPCHelper: replacing existing signature
   OK   Contents/XPCServices/BoringNotchXPCHelper.xpc/Contents/MacOS/BoringNotchXPCHelper  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/Sparkle: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Sparkle  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter: replacing existing signature
   OK   Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Lottie.framework/Versions/A/Lottie: replacing existing signature
   OK   Contents/Frameworks/Lottie.framework/Versions/A/Lottie  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources/MediaRemoteAdapterTestClient: replacing existing signature
   OK   Contents/Resources/MediaRemoteAdapterTestClient  (ingen rettigheder)

== 2. indlejrede bundter, dybeste først ==
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/B: replacing existing signature
   OK   Contents/Frameworks/Sparkle.framework/Versions/B  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A: replacing existing signature
   OK   Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Lottie.framework/Versions/A: replacing existing signature
   OK   Contents/Frameworks/Lottie.framework/Versions/A  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc: replacing existing signature
   OK   Contents/XPCServices/BoringNotchXPCHelper.xpc  (rettigheder beholdt)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources/KeyboardShortcuts_KeyboardShortcuts.bundle: replacing existing signature
   OK   Contents/Resources/KeyboardShortcuts_KeyboardShortcuts.bundle  (ingen rettigheder)
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources/Defaults_Defaults.bundle: replacing existing signature
   OK   Contents/Resources/Defaults_Defaults.bundle  (ingen rettigheder)

== 3. selve appen ==
   rettighederne er hentet ud af Xcodes egen signatur
   --- appens rettigheder ---
       <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>com.apple.security.app-sandbox</key><true/><key>com.apple.security.automation.apple-events</key><true/><key>com.apple.security.device.camera</key><true/><key>com.apple.security.files.bookmarks.app-scope</key><true/><key>com.apple.security.files.bookmarks.document-scope</key><true/><key>com.apple.security.files.user-selected.read-write</key><true/><key>com.apple.security.get-task-allow</key><true/><key>com.apple.security.network.client</key><true/><key>com.apple.security.network.server</key><true/><key>com.apple.security.personal-information.calendars</key><true/><key>com.apple.security.temporary-exception.apple-events</key><array><string>com.spotify.client</string><string>com.apple.Music</string></array><key>com.apple.security.temporary-exception.mach-lookup.global-name</key><array><string>theboringteam.boringnotch-spks</string><string>theboringteam.boringnotch-spki</string></array></dict></plist>
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app: replacing existing signature
   appen er signeret (0 signeringsfejl indtil nu)

== 4. codesign --verify --deep --strict ==
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/.
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/Autoupdate
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/Autoupdate
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/XPCServices/Downloader.xpc
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/XPCServices/Installer.xpc
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/Updater.app
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/XPCServices/Downloader.xpc
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/XPCServices/Installer.xpc
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/Updater.app
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework/Versions/Current/.
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/Current/.
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/Current/.
--prepared:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Lottie.framework/Versions/Current/.
--validated:/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Lottie.framework/Versions/Current/.
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app: valid on disk
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app: satisfies its Designated Requirement
   resultat: OK

== 5. team-id på hver eneste del (skal stå «not set») ==
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc/Contents/MacOS/Installer  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1054 flags=0x2(adhoc) hashes=22+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc/Contents/MacOS/Downloader  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=926 flags=0x2(adhoc) hashes=18+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app/Contents/MacOS/Updater  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1340 flags=0x2(adhoc) hashes=31+7 location=embedded
   OK   Contents/XPCServices/BoringNotchXPCHelper.xpc/Contents/MacOS/BoringNotchXPCHelper  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=967 flags=0x2(adhoc) hashes=19+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Sparkle  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=3732 flags=0x2(adhoc) hashes=110+3 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=2828 flags=0x2(adhoc) hashes=77+7 location=embedded
   OK   Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1400 flags=0x2(adhoc) hashes=37+3 location=embedded
   OK   Contents/Frameworks/Lottie.framework/Versions/A/Lottie  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=18250 flags=0x2(adhoc) hashes=564+3 location=embedded
   OK   Contents/Resources/MediaRemoteAdapterTestClient  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=830 flags=0x2(adhoc) hashes=19+2 location=embedded
   OK   Contents/MacOS/boringNotch  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=92658 flags=0x2(adhoc) hashes=2885+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1054 flags=0x2(adhoc) hashes=22+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=926 flags=0x2(adhoc) hashes=18+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1340 flags=0x2(adhoc) hashes=31+7 location=embedded
   OK   Contents/Frameworks/Sparkle.framework/Versions/B  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=3732 flags=0x2(adhoc) hashes=110+3 location=embedded
   OK   Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=1400 flags=0x2(adhoc) hashes=37+3 location=embedded
   OK   Contents/Frameworks/Lottie.framework/Versions/A  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=18250 flags=0x2(adhoc) hashes=564+3 location=embedded
   OK   Contents/XPCServices/BoringNotchXPCHelper.xpc  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=967 flags=0x2(adhoc) hashes=19+7 location=embedded
   OK   Contents/Resources/KeyboardShortcuts_KeyboardShortcuts.bundle  ->  TeamIdentifier=not set
        CodeDirectory v=20100 size=222 flags=0x2(adhoc) hashes=1+3 location=embedded
   OK   Contents/Resources/Defaults_Defaults.bundle  ->  TeamIdentifier=not set
        CodeDirectory v=20100 size=204 flags=0x2(adhoc) hashes=1+3 location=embedded
   OK   boringNotch.app  ->  TeamIdentifier=not set
        CodeDirectory v=20400 size=92658 flags=0x2(adhoc) hashes=2885+7 location=embedded

== 6. de tre, Lauritz' fejlbesked handlede om ==
--- boringNotch.app
Identifier=theboringteam.boringnotch
Format=app bundle with Mach-O thin (arm64)
CodeDirectory v=20400 size=92658 flags=0x2(adhoc) hashes=2885+7 location=embedded
Signature=adhoc
TeamIdentifier=not set
    --- kravet appen skal opfylde for at TCC kender den igen ---
--- Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter
Identifier=com.vandenbe.MediaRemoteAdapter
Format=bundle with Mach-O universal (x86_64 arm64)
CodeDirectory v=20400 size=1400 flags=0x2(adhoc) hashes=37+3 location=embedded
Signature=adhoc
TeamIdentifier=not set
    --- kravet appen skal opfylde for at TCC kender den igen ---
--- Contents/XPCServices/BoringNotchXPCHelper.xpc
Identifier=theboringteam.boringnotch.BoringNotchXPCHelper
Format=bundle with Mach-O thin (arm64)
CodeDirectory v=20400 size=967 flags=0x2(adhoc) hashes=19+7 location=embedded
Signature=adhoc
TeamIdentifier=not set
    --- kravet appen skal opfylde for at TCC kender den igen ---

SIGNERINGEN ER I ORDEN: alt er ad hoc, ingen indlejret del har et team-id.
BEMÆRK: uden certifikat skifter appens mærke ved hvert byg, og macOS
        beder om Accessibility igen. Sæt JARVIS_CERT_P12 og
        JARVIS_CERT_PASSWORD — se JARVIS-OPSKRIFT.md.
```

## Pakningen (zip og dmg)

```
== signaturen ==
Executable=/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch
Identifier=theboringteam.boringnotch
Format=app bundle with Mach-O thin (arm64)
CodeDirectory v=20400 size=92658 flags=0x2(adhoc) hashes=2885+7 location=embedded
Signature=adhoc
Info.plist entries=35
TeamIdentifier=not set
Sealed Resources version=2 rules=13 files=55
Internal requirements count=0 size=12
Using badge icon for DMG volume.
Creating DMG via dmgbuild: app=/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app output=/Users/runner/work/_temp/ud/boringNotch-jarvis-06bf4f1.dmg volume=boringNotch Jarvis
total 35328
drwxr-xr-x   4 runner  staff      128 Sep 16 22:04 .
drwxr-xr-x  20 runner  staff      640 Sep 16 22:04 ..
-rw-r--r--@  1 runner  staff  9925598 Sep 16 22:04 boringNotch-jarvis-06bf4f1.dmg
-rw-r--r--   1 runner  staff  8157270 Sep 16 22:04 boringNotch-jarvis-06bf4f1.zip
```

## Udgivelsen (Release) og de vedhæftede filer

```
https://github.com/lubbe05/jarvis-notch/releases/tag/jarvis-v20260916-06bf4f1

== udgivelsen jarvis-v20260916-06bf4f1 ==
https://github.com/lubbe05/jarvis-notch/releases/tag/jarvis-v20260916-06bf4f1
== vedhæftede filer ==
boringNotch-jarvis-06bf4f1.dmg  9925598 bytes
boringNotch-jarvis-06bf4f1.zip  8157270 bytes
```

## Slutningen af loggen (sidste 80 linjer)

```
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-macos14.0 -isysroot /Applications/Xcode_16.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -Os -L/Users/runner/work/_temp/dd/Build/Intermediates.noindex/EagerLinkingTBDs/Release -L/Users/runner/work/_temp/dd/Build/Products/Release -F/Users/runner/work/_temp/dd/Build/Intermediates.noindex/EagerLinkingTBDs/Release -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release/PackageFrameworks -F/Users/runner/work/_temp/dd/Build/Products/Release -F/Users/runner/work/jarvis-notch/jarvis-notch/mediaremote-adapter -iframework /Applications/Xcode_16.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk/System/Library/PrivateFrameworks -filelist /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch.LinkFileList -Xlinker -rpath -Xlinker @executable_path/../Frameworks -dead_strip -Xlinker -object_path_lto -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch_lto.o -Xlinker -dependency_info -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch_dependency_info.dat -fobjc-link-runtime -L/Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L/usr/lib/swift -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch.swiftmodule -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -Wl,-no_warn_duplicate_libraries -framework MediaRemoteAdapter -framework Sparkle -framework Lottie -Xlinker -no_adhoc_codesign -o /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/MacroVisionKit.build/Release/MacroVisionKit.build/Objects-normal/arm64/MacroVisionKit.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/Collections.build/Objects-normal/arm64/Collections.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/InternalCollectionsUtilities.build/Objects-normal/arm64/InternalCollectionsUtilities.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/BitCollections.build/Objects-normal/arm64/BitCollections.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/DequeModule.build/Objects-normal/arm64/DequeModule.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/HashTreeCollections.build/Objects-normal/arm64/HashTreeCollections.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/HeapModule.build/Objects-normal/arm64/HeapModule.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/OrderedCollections.build/Objects-normal/arm64/OrderedCollections.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swift-collections.build/Release/_RopeModule.build/Objects-normal/arm64/_RopeModule.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/SkyLightWindow.build/Release/SkyLightWindow.build/Objects-normal/arm64/SkyLightWindow.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/Lottie.build/Release/_LottieStub.build/Objects-normal/arm64/_LottieStub.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/LaunchAtLogin.build/Release/LaunchAtLogin.build/Objects-normal/arm64/LaunchAtLogin.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/KeyboardShortcuts.build/Release/KeyboardShortcuts.build/Objects-normal/arm64/KeyboardShortcuts.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/Defaults.build/Release/Defaults.build/Objects-normal/arm64/Defaults.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/AsyncXPCConnection.build/Release/AsyncXPCConnection.build/Objects-normal/arm64/AsyncXPCConnection.swiftmodule -Xlinker -add_ast_path -Xlinker /Users/runner/work/_temp/dd/Build/Intermediates.noindex/swiftui-introspect.build/Release/SwiftUIIntrospect.build/Objects-normal/arm64/SwiftUIIntrospect.swiftmodule

Copy /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework /Users/runner/work/jarvis-notch/jarvis-notch/mediaremote-adapter/MediaRemoteAdapter.framework (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -exclude Headers -exclude PrivateHeaders -exclude Modules -exclude \*.tbd -resolve-src-symlinks -remove-static-executable /Users/runner/work/jarvis-notch/jarvis-notch/mediaremote-adapter/MediaRemoteAdapter.framework /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks

CodeSign /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    
    Signing Identity:     "Sign to Run Locally"
    
    /usr/bin/codesign --force --sign - -o runtime --timestamp\=none --preserve-metadata\=identifier,entitlements,flags --generate-entitlement-der /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A
/Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A: replacing existing signature

Copy /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc /Users/runner/work/_temp/dd/Build/Products/Release/BoringNotchXPCHelper.xpc (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -exclude Headers -exclude PrivateHeaders -exclude Modules -exclude \*.tbd -resolve-src-symlinks -remove-static-executable /Users/runner/work/_temp/dd/Build/Products/Release/BoringNotchXPCHelper.xpc /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices

ProcessInfoPlistFile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Info.plist /Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/Info.plist (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-infoPlistUtility /Users/runner/work/jarvis-notch/jarvis-notch/boringNotch/Info.plist -producttype com.apple.product-type.application -genpkginfo /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/PkgInfo -expandbuildsettings -platform macosx -additionalcontentfile /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/assetcatalog_generated_info.plist -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Lottie.framework -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks/Sparkle.framework -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources/Defaults_Defaults.bundle -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources/KeyboardShortcuts_KeyboardShortcuts.bundle -scanforprivacyfile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/XPCServices/BoringNotchXPCHelper.xpc -o /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Info.plist

ExtractAppIntentsMetadata (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/appintentsmetadataprocessor --toolchain-dir /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --module-name boringNotch --sdk-root /Applications/Xcode_16.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk --xcode-version 16F6 --platform-family macOS --deployment-target 14.0 --bundle-identifier theboringteam.boringnotch --output /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Resources --target-triple arm64-apple-macos14.0 --binary-file /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch --dependency-file /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch_dependency_info.dat --stringsdata-file /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/ExtractedAppShortcutsMetadata.stringsdata --source-file-list /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch.SwiftFileList --metadata-file-list /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/boringNotch.DependencyMetadataFileList --static-metadata-file-list /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/boringNotch.DependencyStaticMetadataFileList --swift-const-vals-list /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/Objects-normal/arm64/boringNotch.SwiftConstValuesFileList --compile-time-extraction --deployment-aware-processing --validate-assistant-intents --no-app-shortcuts-localization
2026-09-16 22:03:53.377 appintentsmetadataprocessor[23312:69112] Starting appintentsmetadataprocessor export
2026-09-16 22:03:53.380 appintentsmetadataprocessor[23312:69112] warning: Metadata extraction skipped. No AppIntents.framework dependency found.

CopySwiftLibs /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-swiftStdLibTool --copy --verbose --sign - --scan-executable /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch --scan-folder /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks --scan-folder /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/PlugIns --scan-folder /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Library/SystemExtensions --scan-folder /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Extensions --scan-folder /Users/runner/work/jarvis-notch/jarvis-notch/mediaremote-adapter/MediaRemoteAdapter.framework --platform macosx --toolchain /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/Frameworks --strip-bitcode --strip-bitcode-tool /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/bitcode_strip --emit-dependency-info /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/SwiftStdLibToolInputDependencies.dep --filter-for-swift-os

GenerateDSYMFile /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app.dSYM /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    /Applications/Xcode_16.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app/Contents/MacOS/boringNotch -o /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app.dSYM

CodeSign /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    
    Signing Identity:     "Sign to Run Locally"
    
    /usr/bin/codesign --force --sign - -o runtime --entitlements /Users/runner/work/_temp/dd/Build/Intermediates.noindex/boringNotch.build/Release/boringNotch.build/boringNotch.app.xcent --timestamp\=none --generate-entitlement-der /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app

RegisterExecutionPolicyException /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-RegisterExecutionPolicyException /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app

Validate /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    builtin-validationUtility /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app -no-validate-extension -infoplist-subpath Contents/Info.plist

Touch /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    /usr/bin/touch -c /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app

RegisterWithLaunchServices /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app (in target 'boringNotch' from project 'boringNotch')
    cd /Users/runner/work/jarvis-notch/jarvis-notch
    /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -f -R -trusted /Users/runner/work/_temp/dd/Build/Products/Release/boringNotch.app

note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target '_RopeModule' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target '_LottieStub' from project 'Lottie')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'SwiftUIIntrospect' from project 'swiftui-introspect')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'SkyLightWindow' from project 'SkyLightWindow')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'OrderedCollections' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'MacroVisionKit' from project 'MacroVisionKit')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'LaunchAtLogin' from project 'LaunchAtLogin')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'KeyboardShortcuts' from project 'KeyboardShortcuts')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'InternalCollectionsUtilities' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'HeapModule' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'HashTreeCollections' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'DequeModule' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'Defaults' from project 'Defaults')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'Collections' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'BoringNotchXPCHelper' from project 'boringNotch')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'BitCollections' from project 'swift-collections')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'AsyncXPCConnection' from project 'AsyncXPCConnection')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'boringNotch' from project 'boringNotch')
** BUILD SUCCEEDED **

```
