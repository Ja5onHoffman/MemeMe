//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/21/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

let reuseIdentifier = "SentMemesCell"

class SentMemesCollectionViewController: UICollectionViewController, UICollectionViewDataSource {
    
    var memeArray = [Meme]()
    let store = MemeStore.sharedStore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = 103
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 2.0
        layout.minimumLineSpacing = 2.0
        layout.sectionInset = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.memeArray = store.allMemes()
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memeArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        let cellRect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
        let imageView = UIImageView(frame: cellRect)
        cell.addSubview(imageView)
        println("width: \(cell.frame.size.width), height: \(cell.frame.size.height)")
        imageView.image = self.memeArray[indexPath.row].memeImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill

        return cell
    }

    // MARK: UICollectionViewDelegate
    
    @IBAction func addNewMeme(sender: UIBarButtonItem) {
        let memeEditor = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        self.navigationController?.presentViewController(memeEditor, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let mdv = segue.destinationViewController as! MemeDetailViewController
            mdv.hidesBottomBarWhenPushed = true
            let cell = sender as! UICollectionViewCell
            if let index = self.collectionView!.indexPathsForSelectedItems().first as? NSIndexPath {
                mdv.detailImage = self.memeArray[index.row].memeImage
            }
        }
    }
}


extension SentMemesCollectionViewController: UICollectionViewDelegateFlowLayout {
    

}
















