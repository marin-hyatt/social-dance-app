//
//  CommentTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "CommentTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"
#import "DateTools.h"

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
    
    self.timestampLabel.text = [NSString stringWithFormat:@"%@", self.comment.createdAt];
    
    double timeInterval = self.comment.createdAt.timeIntervalSinceNow;
    
    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

    int oneWeek = 604800;
    if (fabs(timeInterval) > oneWeek) {
        self.timestampLabel.text = [formatter stringFromDate:self.comment.createdAt];
    } else {
        self.timestampLabel.text = timeAgoDate.shortTimeAgoSinceNow;
    }
    
    PFFileObject *postImage = self.comment.author[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:postImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
