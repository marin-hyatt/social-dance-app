//
//  UIManager.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "UIManager.h"
#import "Parse/Parse.h"

@implementation UIManager

+ (void)updateProfilePicture:(UIImageView *)profilePictureView withPFFileObject:(PFFileObject *)file {
    profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2;
    profilePictureView.layer.masksToBounds = true;
    NSURL *imageURL = [NSURL URLWithString:file.url];
    [profilePictureView setImageWithURL:imageURL];
}

+ (void)presentAlertWithMessage:(NSString *)message overViewController:(UIViewController *)vc withHandler:(void (^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self executeAlertBlock:handler];
    }];
    
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:^{
    }];
}

+ (void)executeAlertBlock:(void (^)(void))handler {
    handler();
}

@end
