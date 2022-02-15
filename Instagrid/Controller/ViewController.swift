//
//  ViewController.swift
//  Instagrid
//
//  Created by Sam on 08/02/2022.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var layouts: [UIButton]!
    @IBOutlet var gridBox: [UIButton]!
    @IBOutlet weak var arrow: UIImageView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var grid: UIView!
    
    var buttonSwitch: UIButton = UIButton()
    var swipeGesture: UISwipeGestureRecognizer!
    
    enum Layouts {
        case layout1, layout2, layout3
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        layoutSelect(.layout2)
        
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(share(_:)))
       
        grid.addGestureRecognizer(swipeGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeDeviceOrientation),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func layoutSelect(_ layoutDisplay: Layouts) {
        switch layoutDisplay {
        case .layout1:
            layouts[0].setImage(UIImage(named: "Selected"), for: .normal)
            layouts[1].setImage(UIImage(named: "Default Image"), for: .normal)
            layouts[2].setImage(UIImage(named: "Default Image"), for: .normal)
            gridBox[0].isHidden = false
            gridBox[1].isHidden = true
            gridBox[2].isHidden = false
            gridBox[3].isHidden = false
        case .layout2:
            layouts[0].setImage(UIImage(named: "Default Image"), for: .normal)
            layouts[1].setImage(UIImage(named: "Selected"), for: .normal)
            layouts[2].setImage(UIImage(named: "Default Image"), for: .normal)
            gridBox[0].isHidden = false
            gridBox[1].isHidden = false
            gridBox[2].isHidden = false
            gridBox[3].isHidden = true
        case .layout3:
            layouts[0].setImage(UIImage(named: "Default Image"), for: .normal)
            layouts[1].setImage(UIImage(named: "Default Image"), for: .normal)
            layouts[2].setImage(UIImage(named: "Selected"), for: .normal)
            gridBox[0].isHidden = false
            gridBox[1].isHidden = false
            gridBox[2].isHidden = false
            gridBox[3].isHidden = false
        }
    }
    func loadPhotos() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.isEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let newPicture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            buttonSwitch.setImage(newPicture, for: .normal)
            buttonSwitch.imageView?.contentMode = .scaleAspectFill
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pushPhotoButtons(_ sender: UIButton) {
        loadPhotos()
        let tag = sender.tag
        if tag == 0 {
            buttonSwitch = gridBox[0]
        } else if tag == 1 {
            buttonSwitch = gridBox[1]
        } else if tag == 2 {
            buttonSwitch = gridBox[2]
        } else if tag == 3 {
            buttonSwitch = gridBox[3]
        }
    }
     
    @IBAction func pushLayoutButtons(_ sender: UIButton) {
        let tag = sender.tag
        if tag == 4 {
            layoutSelect(.layout1)
        } else if tag == 5 {
            layoutSelect(.layout2)
        } else if tag == 6 {
            layoutSelect(.layout3)
        }
    }
    
    @objc func changeDeviceOrientation() {
        if UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft {
            swipeLabel.text = "Swipe left to share"
            arrow.image = UIImage(named: "Arrow Left")
            swipeGesture.direction = .left
        } else {
            swipeLabel.text = "Swipe up to share"
            arrow.image = UIImage(named: "Arrow Up")
            swipeGesture.direction = .up
        }
    }
    
    @objc func share(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .recognized {
            gridAnimation()
            sharePhotos()
        }
    }
    
    func saveImageGrid(with view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    func sharePhotos() {
        let sharingImage = saveImageGrid(with: grid)
        let items = [sharingImage]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
        activityVC.completionWithItemsHandler = { (_, _, _, _) in
            self.reverseGridAnimation()
        }
    }
    
    func gridAnimation() {
        let gridAnim = CGAffineTransform(scaleX: 0.4, y: 0.4)
        if UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft {
            let swipeLeftAnimation = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.grid.transform = gridAnim.concatenating(swipeLeftAnimation)
            })
            arrow.isHidden = true
            swipeLabel.isHidden = true
        } else {
            let swipeUpAnimation = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.grid.transform = gridAnim.concatenating(swipeUpAnimation)
            })
            arrow.isHidden = true
            swipeLabel.isHidden = true
        }
    }

    func reverseGridAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.grid.transform = .identity
        })
        arrow.isHidden = false
        swipeLabel.isHidden = false
    }
}
