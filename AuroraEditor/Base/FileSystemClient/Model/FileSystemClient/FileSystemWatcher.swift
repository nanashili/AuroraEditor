//
//  FileSystemWatcher.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Darwin

class FileSystemWatcher {
    private var fileDescriptor: Int32 = -1
    private var kqueue: Int32 = -1
    private var eventSource: DispatchSourceFileSystemObject?
    private let fileManager = FileManager.default
    private let path: String
    private var subdirectoryWatchers: [FileSystemWatcher] = []
    var onFileChange: (String, DispatchSource.FileSystemEvent) -> Void

    init?(path: String, // swiftlint:disable:this function_body_length
          excludedPaths: [String] = ["node_modules"],
          onFileChange: @escaping (String, DispatchSource.FileSystemEvent) -> Void) {
        self.path = path
        self.onFileChange = onFileChange
        self.fileDescriptor = open(path, O_EVTONLY)

        guard self.fileDescriptor != -1 else {
            Log.error("Unable to start watching \(path).")
            return nil
        }

        self.kqueue = Darwin.kqueue()
        guard self.kqueue != -1 else {
            Log.error("Failed to create kqueue for \(path).")
            close(self.fileDescriptor)
            return nil
        }

        var event = kevent()
        setupKevent(&event,
                    fileDescriptor: self.fileDescriptor,
                    filter: Int16(EVFILT_VNODE),
                    flags: UInt16(EV_ADD | EV_ENABLE | EV_CLEAR),
                    fflags: UInt32(NOTE_DELETE |
                                   NOTE_WRITE |
                                   NOTE_EXTEND |
                                   NOTE_ATTRIB |
                                   NOTE_LINK |
                                   NOTE_RENAME |
                                   NOTE_REVOKE))

        let status = kevent(self.kqueue, &event, 1, nil, 0, nil)
        guard status != -1 else {
            Log.error("Failed to register kqueue event for \(path).")
            cleanupResources()
            return nil
        }

        eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor,
                                                                eventMask: [.write,
                                                                            .delete,
                                                                            .extend,
                                                                            .attrib,
                                                                            .link,
                                                                            .rename,
                                                                            .revoke],
                                                                queue: DispatchQueue.global())

        eventSource?.setEventHandler { [weak self] in
            guard let self = self else { return }
            Log.info("File change detected at \(self.path)")
            self.onFileChange(self.path, DispatchSource.FileSystemEvent(rawValue: UInt(event.fflags)))
            self.reloadSubdirectoryWatchers(excludedPaths: excludedPaths)
        }

        eventSource?.setCancelHandler { [weak self] in
            self?.cleanupResources()
        }

        eventSource?.resume()
        reloadSubdirectoryWatchers(excludedPaths: excludedPaths)
    }

    private func setupKevent(_ event: inout kevent,
                             fileDescriptor: Int32,
                             filter: Int16,
                             flags: UInt16,
                             fflags: UInt32) {
        event.ident = UInt(fileDescriptor)
        event.filter = filter
        event.flags = flags
        event.fflags = fflags
        event.data = 0
        event.udata = nil
    }

    func watchFile(_ filePath: String, onChange: @escaping () -> Void) {
        let fileDirectory = open(filePath, O_EVTONLY)
        guard fileDirectory != -1 else {
            Log.error("Unable to open file: \(filePath)")
            return
        }

        var kev = kevent()
        kev.ident = UInt(fileDirectory)
        kev.filter = Int16(EVFILT_VNODE)
        kev.flags = UInt16(EV_ADD | EV_ENABLE | EV_ONESHOT)
        kev.fflags = UInt32(NOTE_DELETE | NOTE_WRITE | NOTE_EXTEND)
        kev.data = 0
        kev.udata = nil

        let kqueue = Darwin.kqueue()
        guard kqueue != -1 else {
            Log.error("Unable to create kqueue for file: \(filePath)")
            close(fileDirectory)
            return
        }

        let status = kevent(kqueue, &kev, 1, nil, 0, nil)
        if status == -1 {
            Log.error("Failed to register kqueue event for file: \(filePath)")
            close(fileDirectory)
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDirectory,
                                                               eventMask: .write,
                                                               queue: DispatchQueue.global())
        source.setEventHandler {
            Log.info("Change detected in file: \(filePath)")
            onChange()
            close(fileDirectory) // Clean up after the file has been modified
        }
        source.resume()
    }

    private func cleanupResources() {
        if fileDescriptor != -1 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
        if kqueue != -1 {
            close(kqueue)
            kqueue = -1
        }
    }

    deinit {
        stopWatching()
    }

    func stopWatching() {
        eventSource?.cancel()
        subdirectoryWatchers.forEach { $0.stopWatching() }
    }

    private func reloadSubdirectoryWatchers(excludedPaths: [String]) {
        subdirectoryWatchers.forEach { $0.stopWatching() }
        subdirectoryWatchers = []

        let directoryURL = URL(fileURLWithPath: path)
        let directoryEnumerator = fileManager.enumerator(at: directoryURL,
                                                         includingPropertiesForKeys: [.isDirectoryKey],
                                                         options: [.skipsHiddenFiles],
                                                         errorHandler: { (url, error) -> Bool in
            Log.error("Directory enumeration error at \(url): \(error)")
            return true  // Continue enumeration even if there is an error at this URL.
        })

        while let fileURL = directoryEnumerator?.nextObject() as? URL {
            guard !excludedPaths.contains(fileURL.lastPathComponent) else {
                continue
            }

            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                if resourceValues.isDirectory == true {
                    if let watcher = FileSystemWatcher(path: fileURL.path,
                                                       excludedPaths: excludedPaths,
                                                       onFileChange: { path, event in
                        self.onFileChange(path, event)
                    }) {
                        subdirectoryWatchers.append(watcher)
                    }
                }
            } catch {
                Log.error("Failed to get resource values for \(fileURL): \(error)")
            }
        }
    }
}
