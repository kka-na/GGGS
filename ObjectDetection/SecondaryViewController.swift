//
//  SecondaryViewController.swift
//  ObjectDetection
//
//  Created by Kana Kim on 2021/05/30.
//

import UIKit

struct Recipes : Codable{
    var vegetable: String
    var name: String
    var information: String
    var ingredients: String
    var link: String
    var img: String
}
class SecondaryViewController: UIViewController {
    var idx: Int!
    var fileName: String!
    @IBOutlet weak var textLabel: UILabel!
    private var image : UIImage?
    @IBOutlet weak var rate01: UILabel!
    @IBOutlet weak var rate02: UILabel!
    @IBOutlet weak var rate03: UILabel!
    @IBOutlet weak var rate04: UILabel!
    @IBOutlet weak var rate05: UILabel!
    @IBOutlet weak var vegImage: UIImageView!
    
    private var inferencer = ObjectDetector()
    
    
    private var vegImages = ["veges/book.png", "veges/cabbage.png", "veges/carrot.png", "veges/garlic.png", "veges/onion.png", "veges/pepper.png", "veges/potato.png", "veges/tomato.png", "veges/zuchinni.png"]
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
        let class_name = inferencer.classes[idx]
        let filePath = Bundle.main.path(forResource: "recipes", ofType: "json")
        let jsonStr = try! String(contentsOfFile: filePath!)
        let data = jsonStr.data(using: .utf8)
        let decoder = JSONDecoder()
        if let data = data, let recipes = try? decoder.decode([Recipes].self, from: data){
            rate01?.text = recipes[(idx*5)-5].name
            rate02?.text = recipes[(idx*5)-4].name
            rate03?.text = recipes[(idx*5)-3].name
            rate04?.text = recipes[(idx*5)-2].name
            rate05?.text = recipes[(idx*5)-1].name
        }else{
            print("There is no data")
        }
        textLabel?.textColor = colors[idx]
        textLabel?.text = class_name
        image = UIImage(named: vegImages[idx])!
        if let iv = vegImage {
            iv.image = image
        }
        
        let gesture01 = MyTapGesture2(target: self, action: #selector(self.handleTap(sender:)))
        gesture01.idx = (idx*5)-5
        gesture01.clss = idx
        rate01.isUserInteractionEnabled = true
        rate01.addGestureRecognizer(gesture01)
        
        let gesture02 = MyTapGesture2(target: self, action: #selector(self.handleTap(sender:)))
        gesture02.idx = (idx*5)-4
        gesture02.clss = idx
        rate02.isUserInteractionEnabled = true
        rate02.addGestureRecognizer(gesture02)
        
        let gesture03 = MyTapGesture2(target: self, action: #selector(self.handleTap(sender:)))
        gesture03.idx = (idx*5)-3
        gesture03.clss = idx
        rate03.isUserInteractionEnabled = true
        rate03.addGestureRecognizer(gesture03)
        
        let gesture04 = MyTapGesture2(target: self, action: #selector(self.handleTap(sender:)))
        gesture04.idx = (idx*5)-2
        gesture04.clss = idx
        rate04.isUserInteractionEnabled = true
        rate04.addGestureRecognizer(gesture04)
        
        let gesture05 = MyTapGesture2(target: self, action: #selector(self.handleTap(sender:)))
        gesture05.idx = (idx*5)-1
        gesture05.clss = idx
        rate05.isUserInteractionEnabled = true
        rate05.addGestureRecognizer(gesture05)
        
    }
    
    @IBAction func handleTap(sender: MyTapGesture2){
        let idx:Int = sender.idx
        let classidx:Int = sender.clss
        let vc = ThirdViewController(nibName: "ThirdViewController", bundle: nil)
        vc.idx = idx
        vc.clss = classidx
        navigationController?.pushViewController(vc, animated: true)
    }
}

class MyTapGesture2: UITapGestureRecognizer{
    var clss = Int()
    var idx = Int()
}
