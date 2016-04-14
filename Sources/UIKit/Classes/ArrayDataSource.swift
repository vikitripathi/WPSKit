//
//  ArrayDataSource.swift
//  WPSKit
//
//  Created by Kirby Turner on 4/13/16.
//  Copyright © 2016 White Peak Software, Inc. All rights reserved.
//

import UIKit

public class ArrayDataSource: NSObject, DataSource, UICollectionViewDataSource, UITableViewDataSource {
  
  public var array:[[AnyObject]] = [[]]
  
  public let defaultCellIdentifier: String?

  public let sectionHeaderTitles: [String]?
  
  public var configureCell: ((cell: AnyObject, indexPath: NSIndexPath, item: AnyObject) -> Void)!
  
  public var cellIdentifier: ((indexPath: NSIndexPath, item: AnyObject) -> String)!
  
  public var canEdit: ((indexPath: NSIndexPath) -> Bool)!
  
  public var commitEditingStyle: ((tableView: UITableView, editingStyle: UITableViewCellEditingStyle, indexPath: NSIndexPath) -> Void)!
  
  public var canMoveItem: ((indexPath: NSIndexPath) -> Bool)!
  
  public var moveItem: ((tableView: UITableView, sourceIndexPath: NSIndexPath, destinationIndexPath: NSIndexPath) -> Void)!
  
  public var configureSupplementaryView: ((view: AnyObject, kind: String, indexPath: NSIndexPath) -> Void)!
  
  public var reuseIdentifierForSupplementaryView: ((kind: String, indexPath: NSIndexPath) -> String)!

  init(defaultCellIdentifier: String? = nil, sectionHeaderTitles: [String]? = nil) {
    self.defaultCellIdentifier = defaultCellIdentifier
    self.sectionHeaderTitles = sectionHeaderTitles
  }
}

// MARK: - DataSource

public extension ArrayDataSource {
  
  /**
   Returns the object found at the provided index path.
   
   - parameter indexPath: The index path to the object.
   
   - return Returns the object.
   */
  public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
    guard indexPath.section < array.count else {
      return nil
    }
    
    guard indexPath.row < array[indexPath.section].count else {
      return nil
    }
    
    return array[indexPath.section][indexPath.row]
  }
  
  /**
   Adds an array of objects to the speified section.
   
   - parameters array:    An array of objects to add to the section.
   - parameters section:  The section to which the objects are added.
   */
  public func addObjects(array: [AnyObject], toSection: Int) {
    
  }

  func cellIdentifierAtIndexPath(indexPath: NSIndexPath) -> String {
    var id = defaultCellIdentifier
    if let cellIdentifier = cellIdentifier {
      if let item = objectAtIndexPath(indexPath) {
        id = cellIdentifier(indexPath: indexPath, item: item)
      }
    }
    if id == nil {
      fatalError("You did not set the cell identifier!")
    }
    return id!
  }
}

// MARK: - UICollectionViewDataSource

extension ArrayDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
}

// MARK: - UITableViewDataSource

extension ArrayDataSource {
  
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return array.count
  }
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section < array.count else {
      return 0
    }

    return array[section].count
  }
  
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let identifier = cellIdentifierAtIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    if let configureCell = configureCell {
      let item = objectAtIndexPath(indexPath)
      configureCell(cell: cell, indexPath: indexPath, item: item!)
    }
    return cell
  }
  
  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let titles = sectionHeaderTitles else {
      return nil
    }
    
    guard section < titles.count else {
      return nil
    }
    
    return titles[section]
  }
  
  public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    var edit = false
    if let canEdit = canEdit {
      edit = canEdit(indexPath: indexPath)
    }
    return edit
  }

  public func tableView(tableView: UITableView, editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if let commitEditingStyle = commitEditingStyle {
      commitEditingStyle(tableView: tableView, editingStyle: editingStyle, indexPath: indexPath)
    }
  }
  
  public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    var canMove = false
    if let canMoveItem = canMoveItem {
      canMove = canMoveItem(indexPath: indexPath)
    }
    return canMove
  }

  public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    if let moveItem = moveItem {
      moveItem(tableView: tableView, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
  }
}