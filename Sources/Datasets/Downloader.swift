import Foundation

/// Downloader: A helper class to download files.
public class Downloader: NSObject {
    private lazy var session = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: nil)
    private var localPath: String?
    private var completionHandler: ((URL?, Error?) -> Void)?
    private var semaphore: DispatchSemaphore?
    private var startingTime: Date?

    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `to`: the local path
    ///   - `completionHandler`: will be called upon completion. First item might be the local path,
    ///                          second item might be an error. If the item can't be saved to the local
    ///                          url an error will be returned.
    public func download(fileAt remoteUrl: URL,
                         to localPath: String,
                         completionHandler: @escaping (URL?, Error?) -> Void) {
        self.localPath = localPath
        download(fileAt: remoteUrl, completionHandler: completionHandler)
    }

    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `completionHandler`: will be called upon completion. First item might be the local path,
    ///                          second item might be an error. If the item can't be saved to the local
    ///                          url an error will be returned.
    public func download(fileAt remoteUrl: URL, completionHandler: @escaping (URL?, Error?) -> Void) {
        // Start a new download task. Use a semaphore to wait for the download progress to finish
        // before we continue execution.
        semaphore = DispatchSemaphore(value: 0)
        session.downloadTask(with: remoteUrl).resume()
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
        semaphore?.signal()
        startingTime = nil

        // Move the file to the desired local URL.
        do {
            let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            if localPath == nil { localPath = location.lastPathComponent}
            let savedURL = documentsURL.appendingPathComponent(localPath!)
            completionHandler?(savedURL, nil)
            try FileManager.default.moveItem(at: location, to: savedURL)
            localPath = nil
        } catch {
            completionHandler?(nil, error)
        }
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        print("\n") // Keep the progress bar.
        semaphore?.signal()
        startingTime = nil
        completionHandler?(nil, error)
    }
}
