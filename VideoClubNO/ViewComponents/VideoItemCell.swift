//
//  VideoItemCell.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 15/9/22.
//

import Foundation
import UIKit
import Combine
import ModelLibrary

class VideoItemCell: UITableViewCell {
    
    private var model: VideoSourceItemRepresentable?
    {
       didSet {
           self.titleLabel.text = model?.title
           self.descriptionLabel.text = model?.description
           self.thumbNail.loadImageFromURL(url: model?.thumbnail ?? "")
       }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbNail: UIImageViewURL!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(withModel model: VideoSourceItemRepresentable) {
        self.model = model
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbNail.image = nil
        setIcon()
    }
    
    private func setIcon() {
        if let vm = self.model {
            self.thumbNail.loadImageFromURL(url: vm.thumbnail)
        }
    }
}
