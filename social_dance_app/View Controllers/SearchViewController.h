//
//  SearchViewController.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController
@property NSString *searchQuery;
@property BOOL isTag;
- (void)searchPostsWithQuery:(NSString *)query isTag:(BOOL)isTag;

@end

NS_ASSUME_NONNULL_END
