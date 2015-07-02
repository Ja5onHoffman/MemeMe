//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/21/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

let CellIdentifier = "MemeTableCell"

class SentMemesTableViewController: UITableViewController {
    
    var memeArray = [Meme]()
    let store = MemeStore.sharedStore

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        // Caution message but doesn't work otherwise
        if let ar = store.allMemes() as? [Meme] {
            memeArray = ar
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memeArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.imageView?.image = self.memeArray[indexPath.row].memeImage
        cell.textLabel!.text = self.memeArray[indexPath.row].memeName
        return cell
    }
    
    // Editor is instatiated from storyboard instead of using
    // built in transition.
    @IBAction func addNewMeme(sender: UIBarButtonItem) {
        let memeEditor = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        let nav = UINavigationController(rootViewController: memeEditor)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let mdv = segue.destinationViewController as! MemeDetailViewController
            mdv.hidesBottomBarWhenPushed = true
            let cell = sender as! UITableViewCell
            if let index = self.tableView!.indexPathsForSelectedRows()?.first as? NSIndexPath {
                mdv.detailImage = self.memeArray[index.row].memeImage
            }
        }
    }
}
