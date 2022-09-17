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
    var videoSubject: PassthroughSubject<[VideoSourceItem], Never> { get }

    /*
     With Combine, you can replace this pattern by using a Subject. A subject allows you to imperatively publish a new element at any time
     by calling the send() method. Adopt this pattern by using a private PassthroughSubject or CurrentValueSubject, then expose this publicly
     as an AnyPublisher:
     */
    //func didReceive(videos: [VideoSourceItem])
}

class ViewController: UITableViewController {
    enum Sections: Hashable {
        case main
    }
    var snapshot = NSDiffableDataSourceSnapshot<Sections, VideoSourceItem>()
    var dataSource: UITableViewDiffableDataSource<Sections, VideoSourceItem>?
    private var subscriptions = Set<AnyCancellable>()
    private lazy var privateVideoSubjects = PassthroughSubject<[VideoSourceItem], Never>()
    private var videoItems: [VideoSourceItem]?
    var presenter: VideoPresenterProtocol?
    /*
    var videoItems = [VideoSourceItem]() {
        didSet {
            snapshot.appendSections([.main])
            snapshot.appendItems(videoItems, toSection: .main)
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = VideoPresenter() // cordinator pattern should assemble this
        presenter?.viewProtocol = self
        setupSubscriptions()
        configureTableView()
        presenter?.fetchVideos()
    }
    
    deinit {
        self.subscriptions.removeAll()
    }
}


extension ViewController: ViewControllerProtocol {
    var videoSubject: PassthroughSubject<[VideoSourceItem], Never> {
        privateVideoSubjects
    }
}


//MARK: - Tableview delegate
extension ViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}

private extension ViewController {
    func configureTableView() {
        self.tableView.dataSource = dataSource
        dataSource = UITableViewDiffableDataSource<Sections, VideoSourceItem>(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: VideoSourceItem) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "videoCellIdentifier", for: indexPath) as? VideoItemCell,
                  let item = self.videoItems?[indexPath.row] else {
                return UITableViewCell()
            }
            cell.configure(withModel: item)
            return cell
        }
    }
    
    func setupSubscriptions() {
        videoSubject.sink { [weak self] items in
            self?.videoItems = items
            self?.snapshot.appendSections([.main])
            self?.snapshot.appendItems(items, toSection: .main)
            self?.dataSource?.apply(self!.snapshot, animatingDifferences: true)
        }.store(in: &subscriptions)
    }
}
