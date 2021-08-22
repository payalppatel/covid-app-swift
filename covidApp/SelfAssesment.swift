//
//  SelfAssesment.swift
//  covidApp
//
//  Created by Payal on 27/04/21.
//

import Foundation
import UIKit

var form:[formData] = []
var questions = ["Enter Your Full Name:",
                 "Enter your Age:",
                 "Are you experiencing any symptoms of covid?",
                 "Have you been in contact with any other covid patient?",
                 "Have you travelled outside country in last few days?"]


class SelfAssesment: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var display: UILabel!
    
    // click event to display appropriate message after submitting the form
    @IBAction func onClickButton(_ sender: Any) {
    
        
        if form[2].answerText == "no" || form[3].answerText == "no"{
            display.text = "You are good in health. Stay Home! Stay Safe!"
        }else{
            display.text = "Feels you need to see a doctor."
        }
        form.removeAll()
    }

    

    // Return number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customCell
        
        cell.question.text = questions[indexPath.row]
        cell.answerInput.tag = indexPath.row
        
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// custom cell
class customCell: UITableViewCell {
    
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answerInput: UITextField!
    
    @IBAction func answerGiven(_ sender: UITextField) {
        
        let tag = Int(sender.tag)
        
        form.append(formData(question: questions[tag], answerText: sender.text!))
  
    }
    
}

// class contains to elements to store form data 
class formData{
    var question: String?
    var answerText: String?
    
    init(question: String, answerText: String) {
        self.question = question
        self.answerText = answerText
    }
}
