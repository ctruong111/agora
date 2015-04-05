//
//  BrowseCollectionViewController.m
//  agora
//
//  Created by Ethan Gates on 2/13/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "AddPostButton.h"
#import "AddPostViewController.h"
#import "BrowseCollectionViewController.h"
#import "DetailedPostViewController.h"
#import "LoginViewController.h"
#import "PostCollectionViewCell.h"

@interface BrowseCollectionViewController () 

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property NSMutableArray* postsArray;

@end

@implementation BrowseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _category = @"RECENTS";
    
    // Let LoginViewController controll login
    LoginViewController *logInController = [[LoginViewController alloc] init];
    [logInController setLoginDelegate:self];
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    AddPostButton* addButton = [[AddPostButton alloc] initWithFrame:CGRectMake(250, 490, 66, 66)];
    [addButton addTarget:self action:@selector(pressedAddButton) forControlEvents:UIControlEventTouchDown];
    [[self view] addSubview:addButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString: @"viewPostSegue"]){
        DetailedPostViewController* destination = [segue destinationViewController];
        NSIndexPath* path = [[self collectionView] indexPathForCell:sender];
        Post* selectedPost = [[self postsArray] objectAtIndex:path.row];
        
    }else{
        // continue with load
        [self reloadDataWithCategory:@"RECENTS"];
    }
    
    
}

-(void) reloadData {
    [self reloadDataWithCategory:@"RECENTS"];
}

- (void) reloadDataWithCategory:(NSString*) cat {
    // populate array
    [ParseInterface getFromParse:cat withSkip:0 completion:^(NSArray * result) {
        [[self activitySpinner] stopAnimating];         // automatiicaly started via Storyboard
        [self setPostsArray:[[NSMutableArray alloc] initWithArray:result]];
        [[self collectionView] reloadData];
    }];
    
    if ([cat isEqualToString:@"RECENTS"]) {
        self.title = @"All";
    } else {
        self.title = cat;
    }
}

-(UIBarButtonItem*) threeLineBarButtonItem {
    return NULL;
}

- (void)pressedAddButton{
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    AddPostViewController* addView = [story instantiateViewControllerWithIdentifier:@"Add Post"];
    [addView setDelgate:self];
    [self presentViewController:addView animated:YES completion:^{
        [[self activitySpinner] startAnimating];
    }];
}

#pragma mark - AddPostDelegate

- (void)addPostController:(AddPostViewController *)addPostController didFinishWithPost:(Post *)addedPost{
    [addPostController dismissViewControllerAnimated:YES completion:nil];
    
    if(addedPost){
        [self refreshCollectionViewData];
    }else{
        // No post was made
        [[self activitySpinner] stopAnimating];
    }
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)loginViewController didLogin:(BOOL)login{
    if(login){
        [loginViewController dismissViewControllerAnimated:YES completion:nil];
        [self refreshCollectionViewData];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"agora"
    message:@"Login Error" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[self postsArray] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostCollectionViewCell* postCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"postCell" forIndexPath:indexPath];
    Post* postForCell = [[self postsArray] objectAtIndex:[indexPath row]];
    
    // Cell config
    [[postCell layer] setCornerRadius:5.0f];
    
    [[postCell titleLabel] setText:[postForCell title]];
    [[postCell titleLabel] setTextColor:[UIColor whiteColor]];
    [[postCell priceLabel] setText:[@"$" stringByAppendingString:[[postForCell price] stringValue]]];
    [[postCell priceLabel] setTextColor:[UIColor whiteColor]];
    //[[postCell imageView] setImage:[postForCell thumbnail]];
    indexPath.row == 0?[[postCell imageView] setImage:[UIImage imageNamed:@"soccer"]]:NULL;
    
    [postCell.gradient setBackgroundColor:[UIColor clearColor]];
    if ([postCell.gradient.layer.sublayers count] == 0) {
        [self addGradientBGForView:postCell.gradient];
    }
    
    [postCell.contentView bringSubviewToFront:postCell.titleLabel];
    
    return postCell;
}

- (void) addGradientBGForView:(UIView*) view {
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor, [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor, nil];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    [view.layer addSublayer:gradient];
    
}

@end
