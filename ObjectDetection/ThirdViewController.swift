//
//  ThirdViewController.swift
//  ObjectDetection
//
//  Created by Kana Kim on 2021/05/31.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var informLabel: UILabel!
    @IBOutlet weak var ingreLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var dishImage: UIImageView!
    
    var idx: Int!
    var clss: Int!
    var linkURL: URL!
    var imgURL: URL?
    var image: UIImage?
    
    private var colors = [UIColor.init(red: 0.58, green: 0.50, blue: 1.0, alpha: 1.0),
                          UIColor.init(red: 0.53, green: 0.99, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 0.96, green: 0.58, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 1.0, green: 1.0, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 1.0, green: 1.0, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 0.96, green: 0.50, blue: 0.75, alpha: 1.0),
                          UIColor.init(red: 1.0, green: 1.0, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 0.96, green: 0.58, blue: 0.50, alpha: 1.0),
                          UIColor.init(red: 0.53, green: 0.99, blue: 0.50, alpha: 1.0)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filePath = Bundle.main.path(forResource: "recipes", ofType: "json")
        let jsonStr = try! String(contentsOfFile: filePath!)
        let data = jsonStr.data(using: .utf8)
        if let data = data, let recipes = try? JSONDecoder().decode([Recipes].self, from: data){
            nameLabel?.text = recipes[idx].name
            informLabel?.text = recipes[idx].information
            ingreLabel?.text = recipes[idx].ingredients
            linkURL = URL(string: recipes[idx].link)
            imgURL = URL(string: recipes[idx].img)
        }else{
            print("There is no data")
        }
        nameLabel?.textColor = colors[clss]
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.openSite(sender:)))
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(gesture)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: self.imgURL!)
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
                if let iv = self.dishImage {
                    iv.image = self.image
                }
            }
        }
    }
    
    @IBAction func openSite(sender: UITapGestureRecognizer){
        UIApplication.shared.open(linkURL)
    }
    
    
}

