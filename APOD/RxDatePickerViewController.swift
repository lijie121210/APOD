//
//  RxDatePickerViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/16.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class RxDatePickerViewController: UIViewController {

    var disposeBag = DisposeBag()

    // MARK: - init
    
    var behaviorInitDate = BehaviorSubject(value: Date())
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            behaviorDate.bind { [weak self] (date) in
                self?.datePicker.date = date
            }
            .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Update
    
    var behaviorDate = BehaviorSubject(value: Date())
    
    func bind(_ updation: @escaping (Date) -> Void) {
        behaviorDate
            .asSingle()
            .subscribe(onSuccess: { [weak self] (date) in
                guard let value = try? self?.behaviorInitDate.value() else {
                    return
                }
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                guard format.string(from: date) != format.string(from: value) else {
                    return
                }
                updation(date)
            }, onError: { (error) in
                
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print(self, #function)
    }
    
    @IBAction func dateDidChange(_ sender: Any) {
        behaviorDate.onNext(datePicker.date)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        behaviorDate.onCompleted()
    }}
