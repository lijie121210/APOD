//
//  ViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var actionfContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!
    
    var date = Date()
    
    let disposeBag = DisposeBag()
    
    let fetcher = APODResultFetcher()
    
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
            destination.bind { [weak self] (date) in
                print("destination.completion date: ", date)
                self?.date = date
                self?.load(date: date)
            }
            
        default:
            break
        }
    }

    private func load(date: Date = Date()) {
        DispatchQueue.main.async {
            self.networkIndicator.isHidden = false
        }
        let apodResult = fetcher.request(date: date)
        apodResult
            .subscribe(
                onNext: { [weak self] (result) in
                    print("APOD result observable result: \(result)")
                    DispatchQueue.main.async {
                        self?.updateUI(result: result)
                    }
                },
                onError: { [weak self] (error) in
                    print("APOD result observable error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.clearUI()
                    }
                },
                onCompleted: { print("APOD result observable completed") },
                onDisposed: { print("APOD result observable disposed") })
            .disposed(by: disposeBag)
    }
    
    private func clearUI() {
        networkIndicator.isHidden = true
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
            return
        }
        let observable = fetcher.downloadImage(URLPath: result.bestChoice)
        observable
            .retry(1)
            .map { UIImage(data: $0) }
            .subscribe(
                onNext: { [weak self] (image) in
                    DispatchQueue.main.async {
                        self?.networkIndicator.isHidden = true
                        self?.imageView.image = image
                    }
                },
                onError: {
                    print("Image observable error: \($0.localizedDescription)")
                    DispatchQueue.main.async { [weak self] in
                        self?.networkIndicator.isHidden = true
                    }
                },
                onCompleted: {
                    print("Image observable completed")
                }) {
                    print("Image observable disposed")
                }
            .disposed(by: disposeBag)
    }
}

