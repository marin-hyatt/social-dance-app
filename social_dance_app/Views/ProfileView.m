//
//  ProfileView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileView.h"

@implementation ProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    // Sets username
    self.usernameLabel.text = self.user.username;
    
    // Sets profile picture
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
    
//    PFFileObject * postImage = self.user[@"profilePhoto"];
//    NSURL * imageURL = [NSURL URLWithString:postImage.url];
//    [self.profilePicture setImageWithURL:imageURL];
}

@end
