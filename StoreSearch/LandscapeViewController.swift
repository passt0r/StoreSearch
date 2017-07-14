//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Dmytro Pasinchuk on 13.07.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    var search: Search!
    private var firstTime = true
    
    private var downloadTasks = [URLSessionDownloadTask]()
    
    //MARK: Methods
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width*CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
    }
    
    private func tileButtons(_ searchResults: [SearchResult]) {
        //calculate how many rows and collums per page and setup correct size properties of items
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth-buttonWidth)/2
        let paddingVert = (itemHeight-buttonHeight)/2
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        var row = 0
        var column = 0
        var x = marginX
        for(index, searchResult) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = 2000+index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: searchResult, andPlaceOn: button)
            
            button.frame = CGRect(x: x+paddingHorz,
                                  y: marginY+CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
            }
            if column == columnsPerPage {
                column = 0
                x += marginX*2
            }
        }
        
        let buttonsPerPage = columnsPerPage*rowsPerPage
        let numPages = 1+(searchResults.count-1)/buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
        
        pageControll.numberOfPages = numPages
        pageControll.currentPage = 0
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.artworkSmallURL) {
            let downloadTask = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    let resizedImage = image.resizedImage(withBounds: CGSize(width: 60, height: 60))
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(resizedImage, for: .normal)
                        }
                    }
                }
            }
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
    }
    
    func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5,
                                 y: scrollView.bounds.midY + 0.5) //add 0.5 to the center point to avoid blurring corners of the spinner at fractional coordinates
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state {
        case .nonSearchedYet, .loading:
            break
        case .noResult:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nothing Found"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit()
        
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2)*2 //make even
        rect.size.height = ceil(rect.size.height/2)*2 //make even
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX,
                               y: scrollView.bounds.midY)
        view.addSubview(label)
    }
    
    deinit {
        for downloadTask in downloadTasks {
            downloadTask.cancel()
        }
        downloadTasks.removeAll()
        //print("***Deinit\(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControll.removeConstraints(pageControll.constraints)
        pageControll.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControll.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControll.frame = CGRect(x: 0,
                                    y: view.frame.size.height - pageControll.frame.size.height,
                                    width: view.frame.size.width,
                                    height: pageControll.frame.size.height)
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .nonSearchedYet:
                break
                
            case .loading:
                showSpinner()
                
            case .noResult:
                showNothingFoundLabel()
                
            case .results(let list):
                tileButtons(list)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let destination = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                destination.searchResult = searchResult
            }
        }
    }
    

}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControll.currentPage = currentPage
    }
    
}
