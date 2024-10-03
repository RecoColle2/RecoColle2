//
//  AboutViewController.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2023/10/09.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var gazou: UIImageView!
    @IBOutlet weak var about: UILabel!
    
    @IBAction func goButton(_ sender: UIButton) {
        let url = NSURL(string: "https://www.discogs.com")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sampleImage = UIImage(named: "about.jpg")
        gazou.image = sampleImage
        
        about.numberOfLines = 2;
        about.text="You can display Discogs in your browser and register data by sharing."

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
