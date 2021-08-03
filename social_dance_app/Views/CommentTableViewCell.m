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
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
    [self.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

- (void)onProfileTapped:(UITapGestureRecognizer *)sender {
    [self.delegate feedCell:self didTap:self.comment.author];
}

- (void)updateAppearance {
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
