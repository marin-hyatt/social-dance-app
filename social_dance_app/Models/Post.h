//
//  Post.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "PFObject.h"
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) PFFileObject *videoFile;
@property (nonatomic, strong) Song *song;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;

+ (void) postUserVideo: ( PFFileObject * _Nullable )videoFile withCaption: ( NSString * _Nullable )caption withSong:(Song * _Nullable )song withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
