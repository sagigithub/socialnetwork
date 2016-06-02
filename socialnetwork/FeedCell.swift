//
//  FeedCell.swift
//  
//
//  Created by Sagi Herman on 23/05/2016.
//
//

import UIKit
import Alamofire
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var likenumber: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var likesign: UIImageView!
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var posttext: UITextView!
    @IBOutlet weak var postimage: UIImageView!
    
    var profileimageurl: String?
    
    var post:Post!
    var like_REF: Firebase!
    var request: Request?
    
    override func awakeFromNib() {

        super.awakeFromNib()
        
        //profile image - circle
        profileimage.layer.cornerRadius = profileimage.frame.size.height/2
        profileimage.clipsToBounds = true
        
        //like sign - tap gesture
        let tap = UITapGestureRecognizer(target: self, action: "liketapped:")
        tap.numberOfTapsRequired = 1
        likesign.addGestureRecognizer(tap)
        likesign.userInteractionEnabled = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configurecell (post:Post) {
        

        //save post for other functions
        self.post = post
        
        //making likeref
        self.like_REF = Dataservice.ds.REF_CURRENT_USER.childByAppendingPath("likes").childByAppendingPath(post.postkey)

        //likesign full or empty heart
        //cache for my like sign // also change in liketapped
        if let postlikes = Post.likescache.objectForKey(post.postkey) as? Bool{
            if postlikes {
                self.likesign.image = UIImage(named: "fullheart")
                print("like sign cache")
            } else {
                self.likesign.image = UIImage(named: "emptyheart")
                print("like sign cache")
            }
        } else {
        
        like_REF.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("contact server - likes")
            if let likedontexist = snapshot.value as? NSNull {
                Post.likescache.setObject(false, forKey: post.postkey)
                self.likesign.image = UIImage(named: "emptyheart")
                print("like sign server")

            } else {
                Post.likescache.setObject(true, forKey: post.postkey)
                self.likesign.image = UIImage(named: "fullheart")
                print("like sign server")
            }
            
        })
        }
        
        //like number
        likenumber.text = "\(post.postlikes)"
        
        //post text
        posttext.text = post.posttext
        posttext.scrollRangeToVisible(NSRange(location:0, length:0))

        //profile image - download the post's user data then take url check cache if not download
        let postuser = Dataservice.ds.REF_USERS.childByAppendingPath(post.postuserid)
        postuser.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("contact server - profile image and name")

            if let userdata = snapshot.value as? Dictionary<String,AnyObject> {
                if let name = userdata["profilename"] as? String{
                    //post profile username
                    self.username.text = name
                }
                if let pic = userdata["profilepic"] as? String{
                    self.profileimageurl = pic
                }
                
                //Cache search
                print("post profile image - cache search")
                var img2:UIImage?
                
                if let url2 = self.profileimageurl {
                    img2 = FeedVC.imagecache.objectForKey(url2) as? UIImage
                }
                
                
                //Download request
                
                if img2 != nil { self.profileimage.image = img2!} else {
                    print("post profile image - download")
                    
                    self.request = Alamofire.request(.GET, self.profileimageurl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                        if err == nil {
                            print("post profile image - request")
                            
                            if let img2 = UIImage(data: data!) {
                                print("post profile image - data")
                                
                                self.profileimage.image = img2
                                FeedVC.imagecache.setObject(img2, forKey: self.profileimageurl!)
                                
                            }
                        }
                    })
                }
            }
        })

        
        //postimage - take url and check cache if not - download
        
        if post.postimageurl != nil {
            var img1:UIImage?

            //Cache search
            print("post main image - cache search")

            if let url = post.postimageurl {
                img1 = FeedVC.imagecache.objectForKey(url) as? UIImage
            }
            //Download request

            if img1 != nil { self.postimage.image = img1 } else {
                print("post main image - download")

                request = Alamofire.request(.GET, post.postimageurl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    if err == nil {
                        print("post main image - request")

                        if let img = UIImage(data: data!) {
                            print("post main image - data")

                         self.postimage.image = img
                            FeedVC.imagecache.setObject(img, forKey: self.post.postimageurl!)
                            
                        }
                    }
                })
            }
            postimage.hidden = false
        } else {
            postimage.hidden = true
        }
        
    }
    
    func liketapped (sender:UITapGestureRecognizer) {
        
        if likesign.image == UIImage(named: "emptyheart") {
                //changesign
                self.likesign.image = UIImage(named: "fullheart")
                //change database
                self.post.adjustlikes(true)
                //add connection between post and user in database
                self.like_REF.setValue(true)
                //change cache sign
                Post.likescache.setObject(true, forKey: post.postkey)
            
            } else {
                //changesign
                self.likesign.image = UIImage(named: "emptyheart")
                //change database
                self.post.adjustlikes(false)
                //remove connection between post and user in database
                self.like_REF.removeValue()
                //change cache sign
                Post.likescache.setObject(false, forKey: post.postkey)
        }
    }
    
}
