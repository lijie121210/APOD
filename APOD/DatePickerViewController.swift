//
//  DatePickerViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Combine

class DatePickerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @Published var date: Date = Date()
    
    var publishedDate: Published<Date>.Publisher { $date }
    
    var subscriber: Subscribers.Sink<Date, Never>? {
        didSet {
            guard let s = subscriber else {
                return
            }
            publishedDate.receive(on: RunLoop.main).subscribe(s)
        }
    }
    
    deinit {
        print(self, #function)
    }
    
    @IBAction func dateDidChange(_ sender: Any) {
        date = datePicker.date
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        subscriber?.receive(completion: .finished)
    }
}
