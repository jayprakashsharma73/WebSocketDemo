//
//  SentMessageTableViewCell.swift
//  WebSocketDemo
//
//  Created by Jay Prakash Sharma on 25/03/23.
//

import UIKit

class SentMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var sentMessageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
