import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Downloader: A helper class to download files.
public class Downloader {
    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `completionHandler`: will be called upon completion. First item might be the local URL, second item might be an error.
    public func download(fileAt url: URL, completionHandler completion: @escaping (URL?, Error?) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.downloadTask(with: url, completionHandler: { (localURL, _, error) in
            semaphore.signal()
            guard error == nil else { completion(nil, error!); return }
            if let localURL = localURL {
                completion(localURL, nil)
            } else {
                completion(nil, nil)
            }
        }).resume()
        semaphore.wait()
    }
}
