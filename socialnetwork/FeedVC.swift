//
//  FeedVC.swift
//  socialnetwork
//
//  Created by Sagi Herman on 23/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var posttextgrab: UITextField!
    @IBOutlet weak var postbtn: UIButton!
    @IBOutlet weak var cameraimage: UIImageView!
    @IBOutlet weak var tableview:UITableView!
    
    var posts = [Post]()

    static var imagecache = NSCache()
    
    var imagepicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cameraimage.layer.cornerRadius = 5.0
        cameraimage.clipsToBounds = true
        
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.estimatedRowHeight = 350
        
        // Read/Listen from/to posts database
        Dataservice.ds.REF_POSTS.observeEventType(.Value,withBlock: { Snapshot in
            self.posts = []
            if let snapshots = Snapshot.children.allObjects as? [FDataSnapshot]{
                for snap in snapshots {
                    if let postdict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let post = Post(postkey: key, dict: postdict)
                        self.posts.append(post)
                    }
                }
            }
            print("reloading data")
            self.tableview.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as? FeedCell {
            cell.request?.cancel()
            cell.configurecell(post)
            return cell
        } else {
            let cell = FeedCell()
            print("we are here at the first cell")
            cell.configurecell(post)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.postimageurl == nil { return 140 } else { return tableview.estimatedRowHeight }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        let nowuser = NSUserDefaults().valueForKey(KEY_UID)!
        let postuser = post.postuserid
        if nowuser as! String == postuser {
        performSegueWithIdentifier(SEGUE_POST_DETAIL, sender: post)
        }

    }
    
    @IBAction func oncamerapressed(sender: UITapGestureRecognizer) {
        presentViewController(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagepicker.dismissViewControllerAnimated(true, completion: nil)
        cameraimage.image = image
    }
    
    @IBAction func Onpostbtnpressed(sender: AnyObject) {
        //we are not checking if text or/and pic wasnt updated so then we will not contact the server(we need to save the number of calling to server)...next time

        if let txt = posttextgrab.text where txt != "" {
            if let img = cameraimage.image where img != UIImage(named: "camera.png") {
                print("Making multipartform")
                let urlstr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlstr)!
                let imgdata = UIImageJPEGRepresentation(img, 0.2)!
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
                                        self.addpostfirebase(imglink)
                                    }
                                }
                            }
                        })
                    case .Failure(let error):
                        print(error)
                    }
                    }
            } else { addpostfirebase(nil) }
                    }
        }
    
    func addpostfirebase(imgurl:String?){
        print("Making post")
        var post:Dictionary<String,AnyObject> = [
        "content":posttextgrab.text!,
        "likes":0,
        "userid": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)! as! String
        ]
        if imgurl != nil {
            post["postphotourl"] = imgurl
        }
        let firebasepost = Dataservice.ds.REF_POSTS.childByAutoId()
        firebasepost.setValue(post)
        print("Post uploaded")

    }
    

    @IBAction func Onprofilepressed(sender: AnyObject) {
            let number = 1
            performSegueWithIdentifier(SEGUE_FEEDTOPROFILE, sender: number)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedtoprofile" {
            if let profileview = segue.destinationViewController as? ProfileVC {
                if let thenumber = sender as? Int {
                    profileview.checksegue = thenumber
                }
            }
        }
        if segue.identifier == "postdetailvc" {
            if let profileview = segue.destinationViewController as? PostdetailVC {
                if let thepost = sender as? Post {
                    profileview.post = thepost
                }
            }
        }
    }
    
    @IBAction func onchangeaccountpressed(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        Dataservice.ds.username = ""
        Dataservice.ds.userphotourl = ""
        Post.likescache.removeAllObjects()
        performSegueWithIdentifier(SEGUE_FEEDTOLOGIN, sender: nil)
        
    }

    }


