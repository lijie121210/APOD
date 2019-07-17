//
//  DatePickerViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Foundation
import Combine

class DatePickerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - init
    
    @Published var initDate: Date = Date()
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            let _ = $initDate
                .receive(on: RunLoop.main)
                .assign(to: \.date, on: datePicker)
        }
    }
    
    // MARK: - Update
    
    var currentDate = CurrentValueSubject<Date, Error>(Date())
    
    func bind(_ updation: @escaping (Date) -> Void) {
        let _ = currentDate.sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .finished:
                if let date = self?.currentDate.value {
                    updation(date)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { print("Subscribers.Sink date: ", $0) }
    }
    
    deinit {
        print(self, #function)
        
        if #available(iOS 13.0, *) {
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func dateDidChange(_ sender: Any) {
        currentDate.send(datePicker.date)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        
        if format.string(from: currentDate.value) == format.string(from: initDate) {
            currentDate.send(completion: .failure(CocoaError(.userCancelled)))
        } else {
            currentDate.send(completion: .finished)
        }
    }
}
