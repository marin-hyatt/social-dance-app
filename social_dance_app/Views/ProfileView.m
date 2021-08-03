//
//  ProfileView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileView.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@implementation ProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    self.usernameLabel.text = self.user.username;

    PFFileObject *postImage = self.user[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:postImage];
}

@end
