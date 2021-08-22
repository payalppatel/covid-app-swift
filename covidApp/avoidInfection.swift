//
//  avoidInfection.swift
//  covidApp
//
//  Created by Payal on 28/04/21.
//

import Foundation
import UIKit

class avoidInfection: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    // create an array of type list
    var listSteps: [list] = []
    
    // function to append data in list array
    func appendData()  {
        
        listSteps.append(list(image: UIImage(named: "washhands")!, message: "Wash your hands with soap and water for atleast 20 seconds"))
        listSteps.append(list(image: UIImage(named: "notouch")!, message: "Avoid touching your eyes, nose or mouth"))
        listSteps.append(list(image: UIImage(named: "mask")!, message: "Wear your mask"))
        listSteps.append(list(image: UIImage(named: "social")!, message: "Maintain safe distance"))
        listSteps.append(list(image: UIImage(named: "cough")!, message: "Cover your mouth while sneeze or cough"))
        listSteps.append(list(image: UIImage(named: "stayhome")!, message: "Stay Home Stay Safe"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        appendData()
    }
    
    // return count of number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listSteps.count
    }
    
    // to locate the correct data in the particular view in cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! listAvoidInfection
        
        cell.displayImage.image = listSteps[indexPath.row].image
        cell.message.text = listSteps[indexPath.row].message
        
        return cell
    }
}

// custom class for custom cell
class listAvoidInfection: UITableViewCell {
    
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var message: UILabel!
}

// class list for two elements 
class list{
    var image: UIImage
    var message: String
    
    init(image: UIImage, message: String) {
        self.image = image
        self.message = message
    }
    
}
