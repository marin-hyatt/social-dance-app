//
//  EditProfileView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "EditProfileView.h"
#import "UIImageView+AFNetworking.h"

@implementation EditProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    PFFileObject * profileImage = self.user[@"profilePicture"];
    NSURL * imageURL = [NSURL URLWithString:profileImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
    
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
}

@end
