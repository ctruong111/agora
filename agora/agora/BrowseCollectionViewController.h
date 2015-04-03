//
//  BrowseCollectionViewController.h
//  agora
//
//  Created by Ethan Gates on 2/13/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPostViewController.h"
#import "ParseInterface.h"
#import "SlideItemCVC.h"

@interface BrowseCollectionViewController : SlideItemCVC <AddPostDelegate>

- (void)viewDidLoadAfterLogin;

@end
