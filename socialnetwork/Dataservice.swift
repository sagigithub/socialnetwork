//
//  Dataservice.swift
//  socialnetwork
//
//  Created by Sagi Herman on 18/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "http://socialnetworkswift.firebaseio.com"

class Dataservice {
    
    static let ds = Dataservice()
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_CURRENT_USER: Firebase {
        let uid = NSUserDefaults().valueForKey(KEY_UID)!
        let user = Firebase(url: "\(URL_BASE)/users").childByAppendingPath(uid as! String)
        return user!
    }
    
    private var _username = ""
    private var _userphotourl = ""
    
    
    
    var REF_BASE:Firebase {
        return _REF_BASE }
    var REF_POSTS:Firebase {
        return _REF_POSTS }
    var REF_USERS:Firebase {
        return _REF_USERS }
    var REF_CURRENT_USER:Firebase {
        return _REF_CURRENT_USER }
    
    var username:String {
        get{ return _username }
        set{ _username = newValue }
    }
    var userphotourl:String {
        get{ return _userphotourl }
        set{ _userphotourl = newValue }
    }
    
    
    func createfirebaseuser (uid:String, user:Dictionary<String,String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func downloaduserdata () {
        self.REF_CURRENT_USER.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userdata = snapshot.value as? Dictionary<String,AnyObject> {
                if let name = userdata["profilename"] as? String{
                    print("downloaded username")
                    self.username = name
                    print(self.username)

                }
                if let pic = userdata["profilepic"] as? String{
                    print("downloaded userpic")
                    self.userphotourl = pic
                    print(self.userphotourl)

                }
                
            }

        })
        print(userphotourl)
        print(username)
    }
}
