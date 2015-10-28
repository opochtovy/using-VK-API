//
//  OPLoginViewController.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// Task of that class - to show UIWebView and when a user successfully login by OAuth protocol we have to get a response with access_token

#import <UIKit/UIKit.h>

@class OPAccessToken;

typedef void(^OPLoginCompletionBlock)(OPAccessToken *token);

@interface OPLoginViewController : UIViewController

- (id)initWithCompletionBlock:(OPLoginCompletionBlock) completionBlock;

@end
