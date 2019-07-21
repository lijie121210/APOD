//
//  ViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Foundation
import Combine
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var actionfContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!
    @IBOutlet weak var datePickerButton: UIButton!
    
    var date = Date()
    
    var datePickerCancellable: AnyCancellable?

    let disposeBag = DisposeBag()
    
    let fetcher = APODResultFetcher()
    
    deinit {
        if let cancellable = datePickerCancellable {
            cancellable.cancel()
            datePickerCancellable = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load(date: date)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        actionfContainer.layer.cornerRadius = 20
        visualEffectView.layer.cornerRadius = 20
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "pickerDateSegueID":
            guard let destination = segue.destination as? DatePickerViewController else {
                return
            }
            destination.preferredContentSize = CGSize(width: view.bounds.width - 20, height: 300)
            destination.popoverPresentationController?.delegate = destination
            destination.initDate = date
            datePickerCancellable = destination.selectedDatePublisher
                .print()
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] date in
                        self?.date = date
                        self?.load(date: date)
                    }
                )
            
        default:
            break
        }
    }

    private func load(date: Date = Date()) {
        networkIndicator.isHidden = false
        datePickerButton.isEnabled = false
        
        let apodResult = fetcher.request(date: date)
            .debug()
            .share(replay: 1, scope: .forever)
        
        apodResult
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] in self?.updateUI(result: $0) },
                onError: { [weak self] _ in self?.clearUI() }
            )
            .disposed(by: disposeBag)
        
        apodResult
            .filter { $0.isImage }
            .flatMapLatest { [weak self] (result) -> Observable<Data> in
                guard let this = self else {
                    return Observable.of(Data()).share(replay: 1, scope: .forever)
                }
                return this.fetcher.downloadImage(URLPath: result.bestChoice)
            }
            .debug()
            .observeOn(MainScheduler.instance)
            .map { $0.isEmpty ? nil : UIImage(data: $0) }
            .subscribe(
                onNext: { [weak self] (image) in self?.imageView.image = image },
                onCompleted: { [weak self] in
                    self?.networkIndicator.isHidden = true
                    self?.datePickerButton.isEnabled = true
                })
            .disposed(by: disposeBag)
    }
    
    private func clearUI() {
        networkIndicator.isHidden = true
        datePickerButton.isEnabled = true
        titleLabel.text = "No Data"
        detailLabel.text = nil
        imageView.image = nil
    }
    
    private func updateUI(result: APODResult) {
        titleLabel.text = result.title
        detailLabel.text = result.explanation
        imageView.image = nil
        
        guard result.isImage else {
            print("Not a image")
            networkIndicator.isHidden = true
            datePickerButton.isEnabled = true
            return
        }

    }
}

