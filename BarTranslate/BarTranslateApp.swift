//
//  BarTranslateApp.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//

import Cocoa
import SwiftUI
import HotKey

@main
struct BarTranslateApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    // Rendering a WindowGroup enables macOS default keyboard shortcuts (e.g. copy/paste) on macOS versions <= Monterey.
    // The WindowGroup serves no other purpose, and is thus automatically closed on startup (see 'applicationDidFinishLaunching').
    WindowGroup {
      EmptyView()
    }.commands {
      // Although the empty window group is closed on startup, the user could still force it to open using the shortcut '⌘ + N'.
      // This shouldn't be possible, thus that keyboard shortcut is disabled here.
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
    Settings {
      SettingsView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  static private(set) var instance: AppDelegate!
  
  var popover: NSPopover!
  var statusBarItem: NSStatusItem!
  var hotkeyToggleApp: HotKey!
  var hotkeyToggleSettings: HotKey!
  
  @AppStorage("translationProvider") private var translationProvider: TranslationProvider = DefaultSettings.translationProvider
  @AppStorage("showHideKey") private var showHideKey: String = DefaultSettings.ToggleApp.key.description
  @AppStorage("showHideModifier") private var showHideModifier: String = DefaultSettings.ToggleApp.modifier.description
  
  override init() {
    super.init()
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideKey", options: .new, context: nil)
    UserDefaults.standard.addObserver(self, forKeyPath: "showHideModifier", options: .new, context: nil)
  }
  
  deinit {
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideKey")
    UserDefaults.standard.removeObserver(self, forKeyPath: "showHideModifier")
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "showHideKey" || keyPath == "showHideModifier" {
      setupToggleAppHotkeys()
    }
  }
  
  func setupToggleAppHotkeys() {
    
    let key = Key(string: showHideKey) ?? DefaultSettings.ToggleApp.key
    let mod = Key(string: showHideModifier) ?? DefaultSettings.ToggleApp.modifier
    
    hotkeyToggleApp = HotKey(
      key: key,
      modifiers: keyToNSEventModifierFlags(key: mod),
      keyDownHandler: {
        self.togglePopover(nil)
      }
    )
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    
    // Immediately close the main (empty) app window defined in 'BarTranslateApp'.
    if let window = NSApplication.shared.windows.first {
      window.close()
    }
    
    let contentView = ContentView()
    
    // Application Bubble
    let popover = NSPopover()
    popover.contentSize = NSSize(width: Constants.AppSize.width, height: Constants.AppSize.height)
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: contentView)
    self.popover = popover
    
    // Setup status bar item
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "MenuIcon")
      button.action = #selector(togglePopover(_:))
    }
    
    setupToggleAppHotkeys()
  }
  
  // Show or hide BarTranslate
  @objc func togglePopover(_ sender: AnyObject?) {
    if let button = self.statusBarItem.button {
      if self.popover.isShown {
        self.popover.performClose(sender)
      } else {
        if sender == nil {
          simulateCommandC();
        }
        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        simulateCommandA();
        simulateCommandV();
      }
    }
  }
  
  func simulateCommandC() {
      let source = CGEventSource(stateID: .hidSystemState)

      // 创建Command按下事件
      let commandDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
      commandDown?.flags = .maskCommand

      // 创建C按键按下事件
      let cKeyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
      cKeyDown?.flags = .maskCommand

      // 创建C按键释放事件
      let cKeyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
      cKeyUp?.flags = .maskCommand

      // 创建Command释放事件
      let commandUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

      // 发送事件
      commandDown?.post(tap: .cghidEventTap)
      cKeyDown?.post(tap: .cghidEventTap)
      cKeyUp?.post(tap: .cghidEventTap)
      commandUp?.post(tap: .cghidEventTap)
  }

  
  func simulateCommandA() {
      let source = CGEventSource(stateID: .hidSystemState)

      // 创建Command按下事件
      let commandDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
      commandDown?.flags = .maskCommand

      // 创建A按键按下事件
      let aKeyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: true)
      aKeyDown?.flags = .maskCommand

      // 创建A按键释放事件
      let aKeyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: false)
      aKeyUp?.flags = .maskCommand

      // 创建Command释放事件
      let commandUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

      // 发送事件
      commandDown?.post(tap: .cghidEventTap)
      aKeyDown?.post(tap: .cghidEventTap)
      aKeyUp?.post(tap: .cghidEventTap)
      commandUp?.post(tap: .cghidEventTap)
  }
  
  func simulateCommandV() {
      let source = CGEventSource(stateID: .hidSystemState)
    
      // 创建Command按下事件
      let commandDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
      commandDown?.flags = .maskCommand

      // 创建V按键按下事件
      let vKeyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
      vKeyDown?.flags = .maskCommand

      // 创建V按键释放事件
      let vKeyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
      vKeyUp?.flags = .maskCommand

      // 创建Command释放事件
      let commandUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
      commandUp?.flags = .maskCommand

      // 发送事件
      commandDown?.post(tap: .cghidEventTap)
      vKeyDown?.post(tap: .cghidEventTap)
      vKeyUp?.post(tap: .cghidEventTap)
      commandUp?.post(tap: .cghidEventTap)
  }
}

