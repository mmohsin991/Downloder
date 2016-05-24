//
//  Downloader.swift
//  temp
//
//  Created by Mohsin on 30/03/2016.
//  Copyright © 2016 Mohsin. All rights reserved.
//

import UIKit

protocol DownloaderDelegate {
    func downloadDidCompleted(url : NSURL)
}


class Downloader : NSObject , NSURLSessionDownloadDelegate{
    
    
    var downloadTask: NSURLSessionDownloadTask!
    var backgroundSession: NSURLSession!
    var downloaderDelegate : DownloaderDelegate?
    
    var documentsUrl : NSURL!
    var destinationUrl : NSURL!
    
    
    
    
    func loadFileSync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        
        let destinationUrl = (documentsUrl?.URLByAppendingPathComponent(url.lastPathComponent!))!
        
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                completion(path: destinationUrl.path!, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }
    
    
    func loadFileAsync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let destinationUrl = (documentsUrl?.URLByAppendingPathComponent(url.lastPathComponent!))!
        
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        }
        else {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"

            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl, atomically: true) {
                                print("file saved [\(destinationUrl.path!)]")
                                completion(path: destinationUrl.path!, error:error)
                            } else {
                                print("error saving file")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                completion(path: destinationUrl.path!, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error?.localizedDescription)");
                    completion(path: destinationUrl.path!, error:error)
                }
                
            })
            task.resume()

        }
    }
    

    
    func downloadFile(url: NSURL){
        
        self.documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        self.destinationUrl = (documentsUrl?.URLByAppendingPathComponent(url.lastPathComponent!))!
        
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            self.downloaderDelegate?.downloadDidCompleted(self.destinationUrl)
        }
        else {
//            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
//            let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "GET"
            
            let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession")
            self.backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            
            downloadTask = backgroundSession.downloadTaskWithURL(url)
            downloadTask.resume()
            
        }
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.destinationUrl)
            self.downloaderDelegate?.downloadDidCompleted(self.destinationUrl)
            // show file
        }catch{
            print("An error occurred while moving file to destination url")
        }
        
        print(__FUNCTION__)
        print("session=\(session)")
        print("downloadTask=\(downloadTask)")
        print("location=\(location)")
    }
    
    /* Sent periodically to notify the delegate of download progress. */
    @available(iOS 7.0, *)
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        print(__FUNCTION__)
        
        print("total : \(round(Double(totalBytesExpectedToWrite)/1048576.0)) MB")
        print("\(round((Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))*100.0)) %")
        
    }
    
    /* Sent when a download has been resumed. If a download failed with an
    * error, the -userInfo dictionary of the error will contain an
    * NSURLSessionDownloadTaskResumeData key, whose value is the resume
    * data.
    */
    @available(iOS 7.0, *)
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        print(__FUNCTION__)
        print("session=\(session)")
        print("downloadTask=\(downloadTask)")
        print("expectedTotalBytes=\(expectedTotalBytes)")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
            downloadTask = nil
            if (error != nil) {
                print(error?.description)
            }else{
                print("The task finished transferring data successfully")
            }
    }
    
    
    

}