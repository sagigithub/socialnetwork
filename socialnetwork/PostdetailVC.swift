//
//  PostdetailVC.swift
//  socialnetwork
//
//  Created by Sagi Herman on 30/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostdetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var posttext: UITextField!
    @IBOutlet weak var postimage: UIImageView!
    var post:Post!
    var imagepicker: UIImagePickerController!
    var postkey: String!
    var newimageuploaded:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postkey = post.postkey
        
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        
        posttext.text = post.posttext
        if let url = post.postimageurl {
        let img = FeedVC.imagecache.objectForKey(url) as? UIImage
        postimage.image = img
        }
    }
    
    @IBAction func onpostupdatepressed(sender: AnyObject) {
        print("Making post update")
        //we are not checking if text and pic wasnt updated so then we will not contact the server(we need to save the number of calling to server)...next time
        if postimage.image == UIImage(named: "profilenopic.png") {
            //smart - data with no value is automatically erased
            var newpost:Dictionary<String,AnyObject> = [
                "content":posttext.text!,
                "postphotourl": NSNull()
            ]
            let firebasepost = Dataservice.ds.REF_POSTS.childByAppendingPath(postkey).updateChildValues(newpost)
            print("Post changed")
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            // image was not changed - maybe only text
            if newimageuploaded == false {
            var newpost:Dictionary<String,AnyObject> = [
                "content":posttext.text!
            ]
            let firebasepost = Dataservice.ds.REF_POSTS.childByAppendingPath(postkey).updateChildValues(newpost)
                print("Post changed")
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                //new image uploaded
                
                let img = postimage.image
                    print("Making multipartform")
                    let urlstr = "https://post.imageshack.us/upload_api.php"
                    let url = NSURL(string: urlstr)!
                    let imgdata = UIImageJPEGRepresentation(img!, 0.2)!
                    let keydata = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)
                    let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)
                    Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(data: imgdata, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                        multipartFormData.appendBodyPart(data: keydata!, name: "key")
                        multipartFormData.appendBodyPart(data: keyJSON!, name: "format")
                    }) { encodingResult in
                        print("Sended multipartform")
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { (response) in
                                print("Opening JSON")
                                if let info = response.result.value as? Dictionary<String,AnyObject>{
                                    if let links = info["links"] as? Dictionary<String,AnyObject>{
                                        if let imglink = links["image_link"] as? String{
                                            var newpost:Dictionary<String,AnyObject> = [
                                                "content":self.posttext.text!,
                                                "postphotourl": imglink
                                            ]
                                            let firebasepost = Dataservice.ds.REF_POSTS.childByAppendingPath(self.postkey).updateChildValues(newpost)
                                            print("Post changed")
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                    }
                }
                

            }
        
        

    }
    
    @IBAction func oncancelpressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onimagepressed(sender: AnyObject) {
        presentViewController(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagepicker.dismissViewControllerAnimated(true, completion: nil)
        newimageuploaded = true
        postimage.image = image
    }
    
    @IBAction func onremoveimagepressed(sender: AnyObject) {
        newimageuploaded = false
        postimage.image = UIImage(named: "profilenopic.png")
    }
    
}