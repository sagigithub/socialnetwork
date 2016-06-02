//
//  Post.swift
//  socialnetwork
//
//  Created by Sagi Herman on 23/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Post {
    
    private var _postkey: String!
    private var _postlikes: Int!
    private var _posttext: String!
    private var _postimageurl: String?
    private var _postuserid: String!
    private var _post_REF:Firebase!

    static var likescache = NSCache()

    var postkey: String {
        return _postkey }
    var postlikes: Int {
        return _postlikes}
    var posttext: String {
        return _posttext }
    var postimageurl: String? {
        return _postimageurl }
    var postuserid: String {
        return _postuserid }
    var post_REF: Firebase {
        return _post_REF }

    
    init (postdescription:String, imgurl:String?, userid:String) {
        self._posttext = postdescription
        self._postimageurl = imgurl
        self._postuserid = userid
        //self._postlikes = 0
        //self._postkey = ""
    }
    
    init (postkey:String, dict:Dictionary <String,AnyObject>) {
        self._postkey = postkey
        
        if let likes = dict["likes"] as? Int{
            self._postlikes = likes
        }
        if let id = dict["userid"] as? String{
            self._postuserid = id
        }
        if let photourl = dict["postphotourl"] as? String{
            self._postimageurl = photourl
        }
        if let content = dict["content"] as? String{
            self._posttext = content
        }
        
        self._post_REF = Dataservice.ds.REF_POSTS.childByAppendingPath(self.postkey)
        
    }
    
    func adjustlikes(addlike:Bool) {
        if addlike { _postlikes = _postlikes+1 }
        else { _postlikes = _postlikes-1 }
        _post_REF.childByAppendingPath("likes").setValue(_postlikes)
    }

}
