//
//  ViewController.swift
//  socialnetwork
//
//  Created by Sagi Herman on 18/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var usertextemail: MaterialText!
    @IBOutlet weak var usertextpassword: MaterialText!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            let profile = Dataservice.ds.REF_CURRENT_USER.childByAppendingPath("profilename").observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let checkexist = snapshot.value as? NSNull {
                    self.performSegueWithIdentifier(SEGUE_LOGINTOPROFILE, sender: nil)
                } else {
                    Dataservice.ds.downloaduserdata()
                    self.performSegueWithIdentifier(SEGUE_LOGINTOFEED, sender: nil) }
                })
        }
    }
    
    @IBAction func onFBpressed(sender: AnyObject) {
        //Get Facebook accesstoken
        let facebooklogin = FBSDKLoginManager()
        facebooklogin.logInWithReadPermissions(["email"]) { (facebookresults:FBSDKLoginManagerLoginResult!, facebookerror:NSError!) in
            if facebookerror != nil {
                print("Facebook login failed. Error \(facebookerror)")
            } else {
                let accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully loged in with Facebook. \(accesstoken)")
                
                //Connect Firebase-Facebook with the accesstoken
                Dataservice.ds.REF_BASE.authWithOAuthProvider("facebook", token: accesstoken, withCompletionBlock: { error, authData in
                    if error != nil { print("Login failed. \(error)") }
                    else {
                        print("Logged in ! \(authData)")
                        
                        
                        //Createuser in database if new user
                        Dataservice.ds.REF_USERS.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value , withBlock: { snapshot in
                            
                            if let checkaccount = snapshot.value as? NSNull {
                            let user = ["provider":authData.provider!]
                            Dataservice.ds.createfirebaseuser(authData.uid, user: user)
                            }
                        
                        //Save accesstoken for next time
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        Dataservice.ds.downloaduserdata()
                            if let checkaccount = snapshot.value as? NSNull {
                                self.performSegueWithIdentifier(SEGUE_LOGINTOPROFILE, sender: nil) }
                            else {
                                self.performSegueWithIdentifier(SEGUE_LOGINTOFEED, sender: nil)
                            }
                        
                        })
                        
                    }
                })
            }
        }
        
    }

    @IBAction func onloginpressed(sender: AnyObject) {
        if let email = usertextemail.text where usertextemail.text != "" {
            if let pass = usertextpassword.text where usertextpassword.text != "" {
                
                //First login try
                Dataservice.ds.REF_BASE.authUser(email, password: pass, withCompletionBlock: { error, authData in
                    if error != nil { print(error)
                    if error.code == STATUSACCOUNT_NONEXIST {
                        
                        //Create new user and then sign in
                        Dataservice.ds.REF_BASE.createUser(email, password: pass, withValueCompletionBlock: { error, result in
                            if error != nil { self.showerroralert("Could not create user", msg: "Try again") } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                print("SIGN UP result\(result[KEY_UID])")
                                Dataservice.ds.REF_BASE.authUser(email, password: pass, withCompletionBlock: { err, authdata in
                                
                                    //Createuser in database
                                    let user = ["provider":authdata.provider!]
                                    Dataservice.ds.createfirebaseuser(authdata.uid, user: user)
                                    self.performSegueWithIdentifier(SEGUE_LOGINTOPROFILE, sender: nil)

                                })
                            }
                        })
                    }
                    }
                    else {
                        
                        //First login try succeeded
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        print("SIGN IN authdata\(authData.uid)")
                        Dataservice.ds.downloaduserdata()
                        self.performSegueWithIdentifier(SEGUE_LOGINTOFEED, sender: nil)
                    }
                })
                
            } else { showerroralert("Wrong Email/Password", msg: "Try again") }
        } else { showerroralert("Wrong Email/Password", msg: "Try again") }
    }
    func showerroralert (title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    

}

