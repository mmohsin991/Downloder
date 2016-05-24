//
//  ViewController.swift
//  Downloder
//
//  Created by Mohsin on 24/05/2016.
//  Copyright © 2016 CruxSolutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController , DownloaderDelegate, UIDocumentInteractionControllerDelegate{

    
    let downloader = Downloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageUrl = NSURL(string: "http://www.planwallpaper.com/static/images/colorful-triangles-background_yB0qTG6.jpg")
        let musicUrl = NSURL(string: "http://www.noiseaddicts.com/samples_1w72b820/2537.mp3")
        let fileUrl = NSURL(string: "http://publications.gbdirect.co.uk/c_book/thecbook.pdf")
        let dropBox = NSURL(string: "https://www.dropbox.com/s/kpcs7ev8639c940/Home.jpg")
        let backEndLess = NSURL(string: "https://api.backendless.com/B11387D5-BE29-9B3F-FF8F-54EBA2E14800/v1/files/media/5cRK8oK8i.jpg")
        
        
        
        //        Downloader().loadFileAsync(imageUrl!) { (path, error) -> Void in
        //            print("path \(path)")
        //            print("error \(error)")
        //        }
        
        self.downloader.downloaderDelegate = self
        self.downloader.downloadFile(musicUrl!)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func downloadDidCompleted(url : NSURL) {
        print("file saved path : \(url.path)")
        self.showFileWithPath(url.path!)
    }
    
    func showFileWithPath(path: String){
        let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(path)
        if isFileFound == true{
            let viewer = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreviewAnimated(true)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController{
        return UIViewController()
    }
    
    
    
    @IBAction func pause(sender: AnyObject) {
        if self.downloader.downloadTask != nil{
            self.downloader.downloadTask.suspend()
        }
    }
    @IBAction func resume(sender: AnyObject) {
        if self.downloader.downloadTask != nil{
            self.downloader.downloadTask.resume()
        }
    }
    @IBAction func cancel(sender: AnyObject) {
        if self.downloader.downloadTask != nil{
            self.downloader.downloadTask.cancel()
        }
    }


}

