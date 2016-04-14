//
// NSURL+WPSKit.swift
//
// Created by Kirby Turner.
// Copyright 2016 White Peak Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

extension NSURL {
  
  // -------------------------------------------------------------------
  // MARK: - User Domain
  // -------------------------------------------------------------------
    
  /**
   Returns the URL to the user directory.
   
   This will create the directory if it does not exists.
   
   - parameter searchDirectory:   The search path directory. The supported values are described in `NSSearchPathDirectory`.
   - parameter pathComponent:     The path component to add to the URL, in its original form (not URL encoded).
   - parameter isDirectory:       If `true`, a trailing slash is appended after pathComponent. The default is `true`.
   
   - returns A new URL with pathComponent appended if provided.
   */
  public static func userDomainURL(directory: NSSearchPathDirectory, pathComponent: String?, isDirectory: Bool = true) throws -> NSURL? {
    let fm = NSFileManager.defaultManager()
    guard var url = fm.URLsForDirectory(directory, inDomains: .UserDomainMask).last else {
      return nil
    }
    
    if isDirectory {
      if let pathComponent = pathComponent {
        url = url.URLByAppendingPathComponent(pathComponent)
      }
    }
    
    // Create the directory.
    if let path = url.path {
      try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
    }
    
    // Add the path component if it is not a directory.
    if isDirectory == false {
      if let pathComponent = pathComponent {
        url = url.URLByAppendingPathComponent(pathComponent)
      }
    }
    
    return url
  }
  
  // -------------------------------------------------------------------
  // MARK: - Document Directory
  // -------------------------------------------------------------------
  
  /**
   Returns the URL to the user's document directory.
   
   - returns A URL containing the path.
   */
  public static func documentDirectoryURL() -> NSURL? {
    return try! self.documentDirectoryURL(nil, isDirectory: true)
  }
  
  /**
   Returns the URL to the user's document directory with `pathComponent` appended.

   This will create the directory if it does not exists.
   
   - parameter pathComponent: The path component to add to the path, in its original form (not URL encoded).
   - parameter isDirectory:    If `true`, a trailing slash is appended after pathComponent. The default is `true`.
   
   - returns A URL containing the path with `pathComponent` appended.
   */
  public static func documentDirectoryURL(pathComponent: String?, isDirectory: Bool = true) throws -> NSURL? {
    return try self.userDomainURL(.DocumentDirectory, pathComponent: pathComponent, isDirectory: isDirectory)
  }
  
  // -------------------------------------------------------------------
  // MARK: - Cache Directory
  // -------------------------------------------------------------------
  
  /**
   Returns the URL to the user's cache directory.
   
   - returns A URL containing the path.
   */
  public static func cacheDirectoryURL() -> NSURL? {
    return try! self.cacheDirectoryURL(nil, isDirectory: true)
  }
  
  /**
   Returns the URL to the user's cache directory with `pathComponent` appended.
   
   This will create the directory if it does not exists.
   
   - parameter pathComponent: The path component to add to the path, in its original form (not URL encoded).
   - parameter isDirectory:    If `true`, a trailing slash is appended after pathComponent. The default is `true`.
   
   - returns A URL containing the path with `pathComponent` appended.
   */
  public static func cacheDirectoryURL(pathComponent: String?, isDirectory: Bool = true) throws -> NSURL? {
    return try self.userDomainURL(.CachesDirectory, pathComponent: pathComponent, isDirectory: isDirectory)
  }
  
  // -------------------------------------------------------------------
  // MARK: - Temporary Directory
  // -------------------------------------------------------------------
  
  /**
   Returns the URL to the user's temporary directory.
   
   - returns A URL containing the path.
   */
  public static func temporaryDirectoryURL() -> NSURL? {
    return try! self.temporaryDirectoryURL(nil, isDirectory: true)
  }
  
  /**
   Returns the URL to the user's temporary directory with `pathComponent` appended.
   
   This will create the directory if it does not exists.
   
   - parameter pathComponent: The path component to add to the path, in its original form (not URL encoded).
   - parameter isDirectory:    If `true`, a trailing slash is appended after pathComponent. The default is `true`.
   
   - returns A URL containing the path with `pathComponent` appended.
   */
  public static func temporaryDirectoryURL(pathComponent: String?, isDirectory: Bool = true) throws -> NSURL? {
    let tmp = NSTemporaryDirectory()
    var url = NSURL(fileURLWithPath: tmp)

    if isDirectory {
      if let pathComponent = pathComponent {
        url = url.URLByAppendingPathComponent(pathComponent)
      }
    }
    
    // Create the directory.
    if let path = url.path {
      try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
    }
    
    // Add the path component if it is not a directory.
    if isDirectory == false {
      if let pathComponent = pathComponent {
        url = url.URLByAppendingPathComponent(pathComponent)
      }
    }
    
    return url
  }
  
}