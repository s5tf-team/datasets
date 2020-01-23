import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Downloader: A helper class to download files.
public class Downloader: NSObject {
    private lazy var session = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: nil)

    private var saveURL: URL?
    private var completionHandler: ((URL?, Error?) -> Void)?
    private var semaphore: DispatchSemaphore?
    private var startingTime: Date?

    private var baseURL: URL = {
        // Create the base directory in the users home directory if non-existent.
        let home = URL(string: NSHomeDirectory())!
        let baseURL = home.appendingPathComponent(".s5tf-datasets")
        if !FileManager.default.fileExists(atPath: baseURL.absoluteString) {
            // Force the creation because if we can't create the path, something is
            // seriously wrong.
            try! FileManager.default.createDirectory(atPath: baseURL.absoluteString,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
        }
        return baseURL
    }()

    /// Downloads a file.
    ///
    /// - Parameters:
    ///   - `fileAt`: the remote url
    ///   - `cacheName`: the directory in the base directory where the file will be saved. This
    ///                  directory should be consistent with subsequent requests to enable caching.
    ///   - `fileName`: the desired file name of the local file.
    ///   - `completionHandler`: will be called upon completion. First item might be the local path,
    ///                          second item might be an error. If the item can't be saved to the local
    ///                          url an error will be returned.
    public func download(fileAt remoteUrl: URL,
                         cacheName: String,
                         fileName: String,
                         completionHandler: @escaping (URL?, Error?) -> Void) {
        // Create a chache directory if non-existent.
        let cacheURL = baseURL.appendingPathComponent(cacheName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: cacheURL.absoluteString) {
            try! FileManager.default.createDirectory(atPath: cacheURL.absoluteString,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
        }

        // Check whether the file is already downloaded.
        let saveURL = cacheURL.appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: saveURL.absoluteString) {
            completionHandler(saveURL, nil)
            return
        } else {
            self.saveURL = saveURL
        }

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
            try FileManager.default.moveItem(at: location, to: URL(string: "file://"+saveURL!.absoluteString)!)
            completionHandler?(saveURL!, nil)
            saveURL = nil
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
        saveURL = nil
        completionHandler?(nil, error)
    }
}
