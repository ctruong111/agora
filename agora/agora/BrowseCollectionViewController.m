//
//  BrowseCollectionViewController.m
//  agora
//
//  Created by Ethan Gates on 2/13/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

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
    
    if(![PFUser currentUser]){                                                          // Not Logged in
        LoginViewController *logInController = [[LoginViewController alloc] init];
        [logInController setDelegate:self];
        
        [self presentViewController:logInController animated:YES completion:nil];
    }else{
        // continue with load
        
        // populate array
        [ParseInterface getFromParse:@"RECENTS" withSkip:0 completion:^(NSArray * result) {
            [[self activitySpinner] stopAnimating];         // automatiicaly started via Storyboard
            [self setPostsArray:[[NSMutableArray alloc] initWithArray:result]];
            [[self collectionView] reloadData];
        }];
    }
}

- (void)logInViewController:(PFLogInViewController *)controller didLogInUser:(PFUser *)user {
    // Login procedure
    [controller dismissViewControllerAnimated:YES completion:nil];
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error){
            [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"facebookId"];
            [[PFUser currentUser] save];
        }else{
            NSLog(@"%@", error);
        }
    }];
    
    [self viewDidLoad];     // Call viewDidLoad again to load browseCollectionView
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    // Logout procedure
    [logInController dismissViewControllerAnimated:YES completion:nil];
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
    [[postCell priceLabel] setText:[[postForCell price] stringValue]];
    [[postCell imageView] setImage:[postForCell thumbnail]];
    
    [postCell setBackgroundColor:[UIColor grayColor]];
    
    return postCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString: @"viewPostSegue"]){
        DetailedPostViewController* destination = [segue destinationViewController];
        NSIndexPath* path = [[self collectionView] indexPathForCell:sender];
        Post* selectedPost = [[self postsArray] objectAtIndex:path.row];
        
        destination.post = [ParseInterface getFromParseIndividual:[selectedPost objectId]];
    }
}

@end
