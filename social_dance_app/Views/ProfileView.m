//
//  ProfileView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileView.h"
#import "UIImageView+AFNetworking.h"

@implementation ProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearanceWithFollowerCount:(int)followerCount {
    // Sets username
    self.usernameLabel.text = self.user.username;
    
    // Sets profile picture
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
    
    self.numFollowersLabel.text = [NSString stringWithFormat:@"%d", followerCount];

    PFFileObject * postImage = self.user[@"profilePicture"];
    NSURL * imageURL = [NSURL URLWithString:postImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
}

@end
