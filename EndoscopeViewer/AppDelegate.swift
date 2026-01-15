//
//  AppDelegate.swift
//  EndoscopeViewer
//
//  macOS UVC Dental Endoscope Viewer
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Application launched
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Application will terminate
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
