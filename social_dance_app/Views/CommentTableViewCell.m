//
//  CommentTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "CommentTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self updateAppearance];
}

-(void)updateAppearance {
    self.commentTextLabel.text = self.comment.text;
    self.usernameLabel.text = self.comment.author.username;
    
    PFFileObject *postImage = self.comment.author[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:postImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
