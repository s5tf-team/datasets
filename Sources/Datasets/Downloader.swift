import Foundation

/// Downloader: A helper class to download files.
public class Downloader: NSObject {
    private lazy var session = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: nil)
    private var completionHandler: ((URL?, Error?) -> Void)? = nil
    private var semaphore: DispatchSemaphore?
    private var startingTime: Date?

    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `completionHandler`: will be called upon completion. First item might be the local URL,
    ///                          second item might be an error.
    public func download(fileAt url: URL, completionHandler: @escaping (URL?, Error?) -> Void) {
        // Start a new download task. Use a semaphore to wait for the download progress to finish
        // before we continue execution.
        semaphore = DispatchSemaphore(value: 0)
        session.downloadTask(with: url).resume()
        self.completionHandler = completionHandler
        startingTime = Date()
        semaphore!.wait()
    }
}

extension Downloader: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        // Generate a progress bar.
        let totalProgressBarWidth = 40
        let progressBarWidth = Int(progress * Float(totalProgressBarWidth))
        let progressBar = "[" + String(repeating: "-", count: progressBarWidth) +
                           String(repeating: " ", count: totalProgressBarWidth - progressBarWidth) + "]"

        // Calculate ETA.
        let eta: Any
        if let startingTime = startingTime {
            let now = Date()
            let elapsedTime = Float(now.timeIntervalSince(startingTime)) // In seconds.
            eta = Int((1 - progress) / (progress / elapsedTime))
        } else { eta = "Not Available"}

        // Create bar. Append an empty string to the end. This avoids a bug where shorter strings (decreasing ETA)
        // would partly keep the output of the previous print.
        let bar = "\(progressBar) \(Int(progress*100))% ETA: \(eta)s" + String(repeating: " ", count: 10)

        // Replace the pervious line with the new info.
        fflush(stdout)
        print(bar, terminator: "\r")
    }

    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        print("\n") // Keep the progress bar.
        startingTime = nil
        completionHandler?(location, nil)
        semaphore?.signal()
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        print("\n") // Keep the progress bar.
        startingTime = nil
        completionHandler?(nil, error)
        semaphore?.signal()
    }
}
