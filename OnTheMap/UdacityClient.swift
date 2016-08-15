//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by felix on 8/11/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation

class UdacityClient {
    var sessionID: String!
    var accountKey: String!
    
    func login(userName: String, password: String, completionHandler: (info: String?, success: Bool) -> Void) {
        
        if userName.isEmpty || password.isEmpty {
            completionHandler(info: "Username or password should not be empty!",  success: false)
            return
        }
        
        var headers = [String:String]()
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        
        let HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        
        HTTPHelper.HTTPRequest(Constants.ApiSecureScheme,
                                    host: Constants.Udacity.ApiHost,
                                    path: Constants.Udacity.ApiPath,
                                    pathExtension: Constants.Udacity.ApiPathExtension,
                                    headers: headers,
                                    HTTPMethod: Constants.HTTPMethod.POST,
                                    HTTPBody: HTTPBody) { (data, statusCode, error) in
                        
                                        guard self.completionHandlerForUdacity(data, error: error, completionHandler: completionHandler) else {
                                            return
                                        }

                                        completionHandler(info: "Login succcessfully, session id: \(self.sessionID)",  success: true)
                                    }
    }
    
    func logoff(completionHandler: (info: String?, success: Bool) -> Void) {
        
        var headers = [String:String]()
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            headers["X-XSRF-TOKEN"] = xsrfCookie.value
        }
        
        HTTPHelper.HTTPRequest(Constants.ApiSecureScheme,
                                    host: Constants.Udacity.ApiHost,
                                    path: Constants.Udacity.ApiPath,
                                    pathExtension: Constants.Udacity.ApiPathExtension,
                                    HTTPMethod: Constants.HTTPMethod.DELETE,
                                    headers: headers ) { (data, statusCode, error) in
                        
                                        guard self.completionHandlerForUdacity(data, error: error, completionHandler: completionHandler) else {
                                            return
                                        }
                        
                                        completionHandler(info: "Logoff succcessfully, session id: \(self.sessionID)",  success: true)
                                    }
    }
    
    private func completionHandlerForUdacity(data: NSData?, error: NSError?, completionHandler: (info: String?, success: Bool) -> Void) -> Bool {
        
        guard (error == nil) else {
            completionHandler(info: "There was an error with your request.",  success: false)
            return false
        }
        
        guard let data = data else {
            completionHandler(info: "No data was returned by the request!",  success: false)
            return false
        }
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            completionHandler(info: "Could not parse the data as JSON: \(data)",  success: false)
        }
        
        guard self.parseSessionID(parsedResult) else {
            if let error = parsedResult["error"] as? String {
                completionHandler(info: error,  success: false)
            }
            
            return false
        }
        
        self.parseAccountKey(parsedResult)
        
        return true
    }
    
    private func parseSessionID(data: AnyObject!) -> Bool{
        if let session = data["session"] as? [String: AnyObject] {
            if let id = session["id"] as? String {
                print("Udacity session id is \(id)")
                sessionID = id
                return true
            }
        }
        return false
    }
    
    private func parseAccountKey(data: AnyObject!) -> Bool{
        if let session = data["account"] as? [String: AnyObject] {
            if let key = session["key"] as? String {
                print("Udacity account key is \(key)")
                accountKey = key
                return true
            }
        }
        return false
    }

}