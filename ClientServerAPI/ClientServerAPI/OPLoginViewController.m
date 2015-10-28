//
//  OPLoginViewController.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// Task of that class - to show UIWebView and when a user successfully login by OAuth protocol we have to get a response with access_token

#import "OPLoginViewController.h"
#import "OPAccessToken.h"

@interface OPLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) OPLoginCompletionBlock completionBlock;

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation OPLoginViewController

- (id)initWithCompletionBlock:(OPLoginCompletionBlock) completionBlock {
    
    self = [super init];
    
    if (self) {
        
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect webViewRect = self.view.bounds;
    webViewRect.origin = CGPointZero;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewRect];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    // UIBarButtonItem cancel
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";

    NSString *urlString = @"https://oauth.vk.com/authorize?"
    @"client_id=4444622&" // - ID of created app description in VK API
    @"scope=139286&" // needed masks (+ 2 + 4 + 16 + 131072 + 8192) to get an access to needed rights (friends, photos, video, docs, wall) (scope=friends,photos,video,docs,wall )
    @"redirect_uri=https://oauth.vk.com/blank.html&"
    @"display=mobile&"
    @"v=5.37&"
    @"response_type=token";
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    self.webView.delegate = nil;
}

#pragma mark - UIWebViewDelegate

// that method contains code for getting access_token from server response after sending request
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // next we need to get access_token from server response
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        OPAccessToken *token = [[OPAccessToken alloc] init];
        
        NSString *query = [[request URL] description];
        
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            
            query = [array lastObject];
        }
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs) {
            
            NSArray *values = [pair componentsSeparatedByString:@"="];
            
            if ([values count] == 2) {
                
                NSString *key = [values firstObject];
                
                if ([key isEqualToString:@"access_token"]) {
                    
                    token.token = [values lastObject];
                    
                } else if ([key isEqualToString:@"expires_in"]) {
                    
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    
                } else if ([key isEqualToString:@"user_id"]) {
                    
                    token.userID = [values lastObject];
                }
                
            }
        }
        
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)item {
    
    if (self.completionBlock) {
        
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
