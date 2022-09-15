//
//  ViewController.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import UIKit
import ModelLibrary
import Combine

protocol ViewControllerProtocol: AnyObject {
    func didReceive(videos: [VideoSourceItemRepresentable])
}

class ViewController: UITableViewController {
    
    
    var videoItems = [VideoSourceItemRepresentable]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var presenter: VideoPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = VideoPresenter()
        presenter?.viewProtocol = self
        presenter?.fetchVideos()
    }
}

extension ViewController: ViewControllerProtocol {
    func didReceive(videos: [VideoSourceItemRepresentable]) {
        videoItems = videos
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        videoItems.isEmpty ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "videoCellIdentifier", for: indexPath) as? VideoItemCell else {
            return UITableViewCell()
        }
        let item = videoItems[indexPath.row]
        cell.configure(withModel: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
