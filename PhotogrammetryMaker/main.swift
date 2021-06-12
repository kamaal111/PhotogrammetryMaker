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

    private init() { }

    static func main() {
        guard let rootURL = URL.projectRoot else { return }
        let imagesDirectoryURL = rootURL.appendingPathComponent("Rock36Images")
        let contentsOfImagesDirectory: [URL]
        do {
            contentsOfImagesDirectory = try FileManager.default.contentsOfDirectory(at: imagesDirectoryURL, includingPropertiesForKeys: nil, options: [])
        } catch {
            print(error)
            Foundation.exit(1)
        }
        guard !contentsOfImagesDirectory.isEmpty else {
            print("no images found in directory")
            Foundation.exit(1)
        }
        let outPutURL = rootURL.appendingPathComponent("NewObject.usdz")
        let request = PhotogrammetrySession.Request.modelFile(url: outPutURL,
                                                              detail: .full)
//        let sessionConfiguration = PhotogrammetrySession.Configuration()
//        let session: PhotogrammetrySession
        do {
            let session = try PhotogrammetrySession(input: imagesDirectoryURL.fileURLPath)
            print(session)
        } catch {
            print("session")
            print(error)
            Foundation.exit(1)
        }
//        var subscriptions = Set<AnyCancellable>()
//        session.output
//            .receive(on: DispatchQueue.global())
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let failure):
//                    print(failure)
//                    Foundation.exit(1)
//                case .finished: break
//                }
//            }, receiveValue: { output in
//                switch output {
//                case .processingComplete: print("processingComplete")
//                case .requestComplete(let request, let result):
//                    print(request)
//                    print(result)
//                    print("requestComplete")
//                case .inputComplete:
//                    print("inputComplete")
//                case .requestError(let request, let error):
//                    print(request)
//                    print(error)
//                    print("requestError")
//                case .requestProgress(let request, fractionComplete: let fractionComplete):
//                    print(request)
//                    print(fractionComplete)
//                    print("requestProgress")
//                case .processingCancelled:
//                    print("processingCancelled")
//                case .invalidSample(id: let id, reason: let reason):
//                    print(id)
//                    print(reason)
//                    print("invalidSample")
//                case .skippedSample(id: let id):
//                    print(id)
//                    print("skippedSample")
//                case .automaticDownsampling:
//                    print("automaticDownsampling")
//                @unknown default:
//                    print("unknown case")
//                    print(output)
//                }
//            })
//            .store(in: &subscriptions)
//
//        do {
//            try session.process(requests: [request])
//        } catch {
//            print(error)
//            Foundation.exit(1)
//        }
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

PhotogrammetryMaker.main()
