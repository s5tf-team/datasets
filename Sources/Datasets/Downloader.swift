import Foundation

/// Downloader: A helper class to download files.
public class Downloader: NSObject {
    private lazy var session = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: nil)
    private var completionHandler: ((URL?, Error?) -> Void)? = nil
    private var semaphore: DispatchSemaphore? = nil

    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `completionHandler`: will be called upon completion. First item might be the local URL, second item might be an error.
    public func download(fileAt url: URL, completionHandler: @escaping (URL?, Error?) -> Void) {
        semaphore = DispatchSemaphore(value: 0)
        session.downloadTask(with: url).resume()
        self.completionHandler = completionHandler
        semaphore!.wait()
    }
}

extension Downloader: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {}

    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        completionHandler?(location, nil)
        semaphore?.signal()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completionHandler?(nil, error)
        semaphore?.signal()
    }
}
