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

extension Date {
    
    func equalTo(_ date: Date, format: String = "yyyy-MM-dd") -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self) == formatter.string(from: date)
    }
}

class DatePickerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - init
    
    @Published var initDate: Date = Date()
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            //datePicker.date = initDate
            let _ = $initDate
                .receive(on: RunLoop.main)
                .print()
                .assign(to: \.date, on: datePicker)
        }
    }
    
    // MARK: - Update
    
    private lazy var currentDate = CurrentValueSubject<Date, Never>(Date())
    
    lazy var selectedDatePublisher: AnyPublisher<Date, Never> = {
        return currentDate
            .subscribe(on: RunLoop.main)
            .removeDuplicates()
            .filter { [weak self] (newDate) -> Bool in
                guard let this = self else {
                    return false
                }
                return !newDate.equalTo(this.initDate)
            }
            .last()
            .eraseToAnyPublisher()
    }()
    
    deinit {
        print(self, #function)
    }
    
    @IBAction func dateDidChange(_ sender: Any) {
        currentDate.send(datePicker.date)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        currentDate.send(completion: .finished)
    }
}
