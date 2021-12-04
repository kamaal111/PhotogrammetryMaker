//
//  main.swift
//  PhotogrammetryMaker
//
//  Created by Kamaal M Farah on 12/06/2021.
//

import Foundation
import RealityKit
import Combine

struct PhotogrammetryMaker {

    init() { }

    func run() {
        guard let rootURL = URL.projectRoot else {
            print(Errors.rootURLNotFound)
            Foundation.exit(1)
        }
        let photogrammetrySessionResult = makePhotogrammetrySession(rootURL: rootURL)
        let photogrammetrySession: PhotogrammetrySession
        switch photogrammetrySessionResult {
        case .failure(let failure):
            print(failure)
            Foundation.exit(1)
        case .success(let success): photogrammetrySession = success
        }

        Task {
            do {
                for try await output in photogrammetrySession.outputs {
                    switch output {
                    case .processingComplete: print("processingComplete")
                    case .requestComplete(let request, let result):
                        print(request)
                        print(result)
                        print("requestComplete")
                    case .inputComplete:
                        print("inputComplete")
                    case .requestError(let request, let error):
                        print(request)
                        print(error)
                        print("requestError")
                    case .requestProgress(let request, fractionComplete: let fractionComplete):
                        print(request)
                        print(fractionComplete)
                        print("requestProgress")
                    case .processingCancelled:
                        print("processingCancelled")
                    case .invalidSample(id: let id, reason: let reason):
                        print(id)
                        print(reason)
                        print("invalidSample")
                    case .skippedSample(id: let id):
                        print(id)
                        print("skippedSample")
                    case .automaticDownsampling:
                        print("automaticDownsampling")
                    @unknown default:
                        print("unknown case")
                        print(output)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    private func processPhotogrammetrySession(session: PhotogrammetrySession, outputURL: URL) -> Errors? {
        let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .full)
        do {
            try session.process(requests: [request])
        } catch {
            return .general(error: error)
        }
        return nil
    }

    private func makePhotogrammetrySession(rootURL: URL) -> Result<PhotogrammetrySession, Errors> {
        let imagesDirectoryURLResult = getImagesDirectoryURL(rootURL: rootURL)
        let imagesDirectoryURL: URL
        switch imagesDirectoryURLResult {
        case .failure(let failure): return .failure(failure)
        case .success(let success): imagesDirectoryURL = success
        }
        let sessionConfiguration = makePhotogrammetrySessionConfiguration()
        let session: PhotogrammetrySession
        do {
            session = try PhotogrammetrySession(input: imagesDirectoryURL.fileURLPath, configuration: sessionConfiguration)
        } catch {
            return .failure(.general(error: error))
        }
        return .success(session)
    }

    private func makePhotogrammetrySessionConfiguration() -> PhotogrammetrySession.Configuration {
        let sessionConfiguration = PhotogrammetrySession.Configuration()
        return sessionConfiguration
    }

    private func getImagesDirectoryURL(rootURL: URL) -> Result<URL, Errors> {
        let imagesDirectoryURL = rootURL.appendingPathComponent("Rock36Images", isDirectory: true)
        let contentsOfImagesDirectory: [URL]
        do {
            contentsOfImagesDirectory = try FileManager.default.contentsOfDirectory(at: imagesDirectoryURL, includingPropertiesForKeys: nil, options: [])
        } catch {
            return .failure(.general(error: error))
        }
        guard !contentsOfImagesDirectory.isEmpty else {
            return .failure(.emptyDirectory)
        }
        return .success(imagesDirectoryURL)
    }

    private enum Errors: Error {
        case rootURLNotFound
        case general(error: Error)
        case emptyDirectory
    }

}

extension URL {
    var fileURLPath: URL {
        URL(fileURLWithPath: self.absoluteString)
    }

    static let projectRoot = URL(string: #file)?
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

// MARK: - Main

PhotogrammetryMaker().run()
