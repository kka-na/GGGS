//
//  GetRecipteList.swift
//  ObjectDetection
//
//  Created by Kana Kim on 2021/05/29.
//

import AVFoundation
import UIKit

class GetRecipeList: UIViewController {
    private var imageViewList =  UIImageView()
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func onBackClicked(_: Any) {
        navigationController?.popViewController(animated: true)
    }
}

