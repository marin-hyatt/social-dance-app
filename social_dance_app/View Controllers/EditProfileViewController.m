//
//  EditProfileViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "EditProfileViewController.h"
#import "EditProfileView.h"

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet EditProfileView *editProfileView;
- (IBAction)onChangeProfilePictureButtonTapped:(UIButton *)sender;
- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.editProfileView.user = self.user;
    [self.editProfileView updateAppearance];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage *resizedOriginalImage = [self resizeImage:originalImage withSize: CGSizeMake(originalImage.size.width * 0.6, originalImage.size.height * 0.6)];
    
    [self.editProfileView.profilePictureView setImage:resizedOriginalImage];

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender {
    if (self.editProfileView.profilePictureView.image) {
        NSData *imageData = UIImagePNGRepresentation(self.editProfileView.profilePictureView.image);
        
        if (imageData) {
            PFFileObject *file = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
            PFUser *user = self.user;
            user[@"profilePicture"] = file;
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Profile picture updated!");
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSLog(@"Error: %@", error.description);
                }
            }];
        }
    }
}

- (IBAction)onChangeProfilePictureButtonTapped:(UIButton *)sender {
    [self showImagePicker];
}

-(void) showImagePicker {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
@end
