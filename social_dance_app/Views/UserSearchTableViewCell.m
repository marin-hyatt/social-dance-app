//
//  UserSearchTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/27/21.
//

#import "UserSearchTableViewCell.h"
#import "UIManager.h"

@implementation UserSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateAppearance {
    self.usernameLabel.text = self.user[@"username"];
    
    PFFileObject *file = self.user[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:file];
}

@end
