//
//  DetailedPostViewController.m
//  agora
//
//  Created by Kalvin Loc on 3/19/15.
//  Copyright (c) 2015 Ethan. All rights reserved.
//

#import "DetailedPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#define post [self post]

@interface DetailedPostViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *catagoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@property (weak, nonatomic) IBOutlet FBProfilePictureView *FBSellerImageView;
@property (weak, nonatomic) IBOutlet UIButton *FBSellerNameButton;
@property (weak, nonatomic) IBOutlet UILabel *FBMutalFriendsLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;

@end

@implementation DetailedPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self scrollView] setContentSize:[[self contentView] frame].size];
    
    [[self mainImageView] setImage:[post headerPhoto]];
    
    // configure title, description and price
    [[self titleLabel] setText:[post title]];
    [[self catagoryLabel] setText:[post category]];
    [[self priceLabel] setText:[[post price] stringValue]];
    
    // Configure buttons
    CGColorRef buttonColor = [[UIColor blueColor] CGColor];
    [[self shareButton] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [[[self shareButton] layer] setBorderWidth:1.5f];
    [[[self shareButton] layer] setCornerRadius:4.0f];
    [[[self shareButton] layer] setBorderColor:buttonColor];
    
    [[self contactButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self contactButton] setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [[[self contactButton] titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [[[self contactButton] layer] setBorderWidth:2.0f];
    [[[self contactButton] layer] setBackgroundColor:buttonColor];
    [[[self contactButton] layer] setCornerRadius:4.0f];
    [[[self contactButton] layer] setBorderColor:buttonColor];
    
    [[[self FBSellerImageView] layer] setCornerRadius:[[self FBSellerImageView] frame].size.height/2];
    [[[self FBSellerImageView] layer] setMasksToBounds:YES];
    [[[self FBSellerImageView] layer] setBorderWidth:0];
    
    // configure FBSeller info
    [FBRequestConnection startWithGraphPath:[post creatorFacebookId] completionHandler:^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        if(!error){
            //NSString* college = [[[[result objectForKey:@"education"] objectAtIndex:2] objectForKey:@"school"] objectForKey:@"name"];
            //NSLog(@"College: %@", college);
            [[self FBSellerImageView] setProfileID:result[@"id"]];
            [[self FBSellerNameButton] setTitle:result[@"name"] forState:UIControlStateNormal];
            [[self FBSellerNameButton] setTitle:result[@"name"] forState:UIControlStateSelected];
        }else{
            NSLog(@"Error Grabing FB Data in Detail");
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    // get amount of mutual friends (TODO: show excerpt of what friends?)
    if(!([[post creatorFacebookId] isEqualToString:[[PFUser currentUser] objectForKey:@"facebookId"]])){
        [FBRequestConnection startWithGraphPath:[post creatorFacebookId] parameters:@{@"fields": @"context.fields(mutual_friends)",} HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, FBGraphObject* result, NSError *error){
                                  NSString* commonFriends = result[@"context"][@"mutual_friends"][@"summary"][@"total_count"];
                                  [[self FBMutalFriendsLabel] setText:[NSString stringWithFormat:@"%@ mutual friends", commonFriends]];
                              }
         ];
    }else{
        [[self FBMutalFriendsLabel] setText:@""];
    }
    
    // configure description textField
    [[self descriptionTextField] setText:[post itemDescription]];
}

#pragma mark - IB Actions

- (IBAction)clickedShare:(id)sender {
    // open share action sheet
}

- (IBAction)clickedContact:(id)sender {
    // open FB messager to user
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@", [post creatorFacebookId]]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }else{
        // Did not install FB MSGER or misc error. What Do
    }
}

- (IBAction)clickedFBSellerName:(id)sender {
    // Open seller's facebook page
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", [post creatorFacebookId]]];
    [[UIApplication sharedApplication] openURL:url];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", [post creatorFacebookId]]]];
    }
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* postCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    return postCell;
}

@end
