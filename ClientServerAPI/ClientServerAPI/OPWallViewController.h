//
//  OPWallViewController.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

// ! - we have to plug in the framework AFNetworking -> read instruction at https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking

// What do we need in AFNetworking? - First, we need an access from our app to the server (VK API)  -> we should create a class that responds for data transmission  -> singleton to communicate with the server !!! -> OPServerManager

#import <UIKit/UIKit.h>

@interface OPWallViewController : UITableViewController

@end
