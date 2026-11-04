// Listen for device connections, without reading keyboard input.
import Foundation
import IOKit.hid

guard CommandLine.arguments.count == 2,
      FileManager.default.isReadableFile(atPath: CommandLine.arguments[1]) else {
    fputs("Usage: watch_mxboard /path/to/apply_mxboard.sh (readable script required)\n", stderr)
    exit(1)
}
let scriptPath = CommandLine.arguments[1]
let applyQueue = DispatchQueue(label: "local.dotfiles.mxboard.apply")

func applyMapping() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = [scriptPath, "--runtime-only"]
    process.standardOutput = FileHandle.nullDevice
    do {
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            fputs("MX Board mapping script exited with status \(process.terminationStatus)\n", stderr)
        }
    } catch {
        fputs("MX Board mapping failed: \(error)\n", stderr)
    }
}

func deviceConnected() {
    // The HID event service can appear slightly after the device callback.
    // Retry during enumeration so the first application is not lost.
    for delay in [0.0, 0.2, 1.0, 3.0] {
        applyQueue.asyncAfter(deadline: .now() + delay) { applyMapping() }
    }
}

let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
IOHIDManagerSetDeviceMatching(manager, [
    kIOHIDVendorIDKey: 1130,
    kIOHIDProductIDKey: 180,
    kIOHIDPrimaryUsagePageKey: 1,
    kIOHIDPrimaryUsageKey: 6,
] as CFDictionary)
IOHIDManagerRegisterDeviceMatchingCallback(manager, { _, result, _, _ in
    if result == kIOReturnSuccess {
        fputs("MX Board connected; applying mappings.\n", stderr)
        deviceConnected()
    }
}, nil)
IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
// Scheduling is sufficient for device notifications; do not open input devices.
deviceConnected()
CFRunLoopRun()
