//
//  AppDelegate.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import <SpotifyiOS/SpotifyiOS.h>
#import "APIManager.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Connecting to Parse backend
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"zVL08kNrweRta8rt4nst3UFJnMnOWZG2byENCDmf";
        configuration.clientKey = @"kDERu6tpqihAOIrFMzGpJe0hOWqv6fpyauniU04l";
        configuration.server = @"https://parseapi.back4app.com";
    }];
    
    [Parse initializeWithConfiguration:config];
    
    // TODO: add ability to refresh access token instead of exchanging for a new token every time
//    [[APIManager shared] refreshTokenIfNeededWithCompletion:^(BOOL success, NSError *error) {
//        if (success) {
//            NSLog(@"Success!");
//        }
//    }];
    [NSURLCache sharedURLCache].diskCapacity = 1000 * 1024 * 1024; // 1000 MB
    // Override point for customization after application launch.
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
