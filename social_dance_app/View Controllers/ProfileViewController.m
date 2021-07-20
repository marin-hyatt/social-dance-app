//
//  ProfileViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileViewController.h"
#import "ProfileView.h"
#import "Parse/Parse.h"
#import "ProfileCollectionViewCell.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet ProfileView *profileView;
@property (strong, nonatomic) NSArray *feed;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileCollectionView.delegate = self;
    self.profileCollectionView.dataSource = self;
    
    self.profileView.user = self.user;
    [self.profileView updateAppearance];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCollectionViewCell *cell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell" forIndexPath:indexPath];
    
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
