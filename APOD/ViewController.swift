//
//  ViewController.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Combine
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var date = Date() {
        didSet {
            // load(date: date)
        }
    }
    
    let disposeBag = DisposeBag()
    
    let fetcher = APODResultFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualEffectView.layer.cornerRadius = 20
        
        load(date: date)
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
            
            // Using Assign
            let _ = destination.publishedDate
                .receive(on: DispatchQueue.main)
                .assign(to: \.date, on: self)
            
            // Using Sink
            let sub: Subscribers.Sink<Date, Never> = Subscribers.Sink(receiveCompletion: { [weak self] (completion) in
                print("Subscribers.Sink completion")
                
                if let s = self {
                    s.load(date: s.date)
                }
            }) { (date) in
                print("Subscribers.Sink date: ", date.description)
            }
            destination.subscriber = sub
            
        default:
            break
        }
    }

    private func load(date: Date = Date()) {
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
                onCompleted: {
                    print("APOD result observable completed")
            },
                onDisposed: {
                    print("APOD result observable disposed")
            })
            .disposed(by: disposeBag)
    }
    
    private func clearUI() {
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
            return
        }
        let observable = fetcher.downloadImage(URLPath: result.bestChoice)
        observable
            .retry(3)
            .map { UIImage(data: $0) }
            .subscribe(
                onNext: { [weak self] (image) in
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                },
                onError: { print("Image observable error: \($0.localizedDescription)") },
                onCompleted: { print("Image observable completed") }) {
                    print("Image observable disposed")
        }
        .disposed(by: disposeBag)
    }
}

