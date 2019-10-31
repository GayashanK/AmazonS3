//
//  ViewController.swift
//  AmazonS3Upload
//
//  Created by Maxim on 12/18/16.
//  Copyright © 2016 maximbilan. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class ViewController: UIViewController {

	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func uploadButtonAction(_ sender: UIButton) {
//		uploadButton.isHidden = true
//		activityIndicator.startAnimating()
//
//		let accessKey = "AKIAWAPT7YJTHBQL6F4Q"
//		let secretKey = "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"
//
//		let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//		let configuration = AWSServiceConfiguration(region:AWSRegionType.USEast1, credentialsProvider:credentialsProvider)
//
//		AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//		let S3BucketName = "dev-asset/userids"
//		let remoteName = "test.jpg"
//		let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
//		let image = UIImage(named: "test")
//		let data = image!.jpegData(compressionQuality: 0.9)
//		do {
//			try data?.write(to: fileURL)
//		}
//		catch {}
//
//		let uploadRequest = AWSS3TransferManagerUploadRequest()!
//        uploadRequest.body = URL(string: "https://s3.amazonaws.com/dev-asset/userid/test.jpg")!
//		uploadRequest.key = remoteName
//		uploadRequest.bucket = S3BucketName
//		uploadRequest.contentType = "image/jpg"
//		uploadRequest.acl = .publicRead
//
//		let transferManager = AWSS3TransferManager.default()
//
//		transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
//			DispatchQueue.main.async {
//				self?.uploadButton.isHidden = false
//				self?.activityIndicator.stopAnimating()
//			}
//
//			if let error = task.error {
//				print("Upload failed with error: (\(error.localizedDescription))")
//			}
//
//			if task.result != nil {
//				let url = AWSS3.default().configuration.endpoint.url
//				let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
//				if let absoluteString = publicURL?.absoluteString {
//					print("Uploaded to:\(absoluteString)")
//				}
//			}
//
//			return nil
//		}
//
//        self.getFolderSize(bucketName: "dev-asset")
        
//        self.loadFileAsync(url: URL(string: "http://www.africau.edu/images/default/sample.pdf")!, completion: {
//            status in
//        })
        
        self.loadFileAsync(url: URL(string: "https://www.fnordware.com/superpng/pnggrad16rgb.png")!, completion: {
            status in
        })
	}
    
    func getFolderSize(bucketName:String!){
        
        let accessKey = "AKIAWAPT7YJTHBQL6F4Q"
        let secretKey = "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"
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region:AWSRegionType.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let s3 = AWSS3.default()
        let getReq : AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        getReq.bucket = bucketName
//        getReq.prefix = "userid" //Folder path to get size
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()

        s3.listObjects(getReq) { (listObjects, error) in

            var total : Int = 0

            if listObjects?.contents != nil {
                for object in (listObjects?.contents)! {
                    do {
                        let s3Object : AWSS3Object = object
                        total += (s3Object.size?.intValue)!
                    }
                }

                print(total)

                let byteCount = total // replace with data.count
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: Int64(byteCount))
                print("File size in MB : \(string)")
            }
            else {
                print("contents is blank")
            }
        }
    }
    
    func downloadFile() {
        if let audioUrl = URL(string: "http://www.africau.edu/images/default/sample.pdf") {
            // create your document folder url
            let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            // your destination file url
            let destination = documentsUrl.appendingPathComponent(audioUrl.lastPathComponent)
            print(destination)
            // check if it exists before downloading it
            if FileManager().fileExists(atPath: destination.path) {
                print("The file already exists at path")
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) in
                    // after downloading your data you need to save it to your destination url
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("pdf"),
                        let location = location, error == nil
                        else {
                            
                            
                            return
                            
                    }
                    do {
                        try FileManager.default.moveItem(at: location, to: destination)
                        print("file saved")
                    } catch {
                        print(error)
                    }
                }).resume()
            }
        }
    }
    
    /// Downloads a file asynchronously
    func loadFileAsync(url: URL, completion: @escaping (Bool) -> Void) {

        // create your document folder url
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        // your destination file url
        let destination = documentsUrl.appendingPathComponent(url.lastPathComponent)

        print("downloading file from URL: \(url.absoluteString)")
        
        if FileManager().fileExists(atPath: destination.path) {
            print("The file already exists at path, deleting and replacing with latest")

            if FileManager().isDeletableFile(atPath: destination.path){
                do{
                    try FileManager().removeItem(at: destination)
                    print("previous file deleted")
                    self.saveFile(url: url, destination: destination) { (complete) in
                        if complete{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }catch{
                    print("current file could not be deleted")
                }
            }
        // download the data from your url
        }else{
            self.saveFile(url: url, destination: destination) { (complete) in
                if complete{
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }


    func saveFile(url: URL, destination: URL, completion: @escaping (Bool) -> Void){
        URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
            // after downloading your data you need to save it to your destination url
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let location = location, error == nil
                else { print("error with the url response"); completion(false); return}
            do {
                try FileManager.default.moveItem(at: location, to: destination)
                print("new file saved")
                self.pickDocument(url: destination)
                completion(true)
            } catch {
                print("file could not be saved: \(error)")
                completion(false)
            }
        }).resume()
    }
    
    func pickDocument(url: URL) {
        DispatchQueue.main.async {
            let picker = UIDocumentPickerViewController(url: url, in: .exportToService)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
	
}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .exportToService {
            DispatchQueue.main.async(execute: {
                let alertMessage = "Successfully uploaded file \(url.lastPathComponent)"
                let alertController = UIAlertController(title: "UIDocumentView", message: alertMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true)
            })

        }
    }
    
}

