//
//  ProfileVC.swift
//  socialnetwork
//
//  Created by Sagi Herman on 26/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
class ProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var profilename: UITextField!
    @IBOutlet weak var backfeedbtn: UIButton!
    
    var imagepicker: UIImagePickerController!
    var checksegue: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        
        if checksegue == 1 {
        self.backfeedbtn.hidden = false
        } else { self.backfeedbtn.hidden = true }
    
        let name = Dataservice.ds.username
        let pic = Dataservice.ds.userphotourl
        if name == "" && pic == "" {
            
        } else {
            profilename.text = name
            //cache
            let img = FeedVC.imagecache.objectForKey(pic) as? UIImage
            
            //Download request
            //we will need that if the user didnt send enough posts and they are not showing at the feed... at the first frame and then he want to change image
            if img != nil { profilepic.image = img } else {
                print("we are here download")
                
               var request = Alamofire.request(.GET, pic).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    if err == nil {
                        print("we are here request")
                        
                        if let img = UIImage(data: data!) {
                            print("we are here data")
                            
                            self.profilepic.image = img
                            FeedVC.imagecache.setObject(img, forKey: pic)
                            
                        }
                    }
                })
            }
            
        }

    }


    
    @IBAction func onprofilebtnpressed(sender: AnyObject) {
        presentViewController(imagepicker, animated: true, completion: nil)
    }
    
    @IBAction func onconfirmpressed(sender: AnyObject) {
        if let name = profilename.text where name != "" {
            if let pic = profilepic.image where pic != UIImage(named: "profilenopic.jpg") {
                //uploading pic
                print("Making multipartform")
                let urlstr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlstr)!
                let imgdata = UIImageJPEGRepresentation(pic, 0.2)!
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
                                        self.addprofiletofirebase(imglink, name: name)
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


    func addprofiletofirebase (picurl:AnyObject,name:AnyObject) {
                var profile:Dictionary<String,AnyObject> = [
                    "profilepic":picurl,
                    "profilename":name
                ]
                let firebaseprofile = Dataservice.ds.REF_CURRENT_USER
                firebaseprofile.updateChildValues(profile)
                Dataservice.ds.downloaduserdata()
              performSegueWithIdentifier(SEGUE_PROFILETOFEED, sender: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagepicker.dismissViewControllerAnimated(true, completion: nil)
        profilepic.image = image
    }
    
    
    @IBAction func Onfeedpressed(sender: AnyObject) {
                      performSegueWithIdentifier(SEGUE_PROFILETOFEED, sender: nil)
    }

}
