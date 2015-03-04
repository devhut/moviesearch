//  Created by Dan Lopez on 10/8/14.
//  Copyright (c) 2014 DevHut. All rights reserved.

#import "MovieViewController.h"

@interface MovieViewController () {
    dispatch_queue_t _movieQueue;
    NSString *_searchText;
}

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

- (UIImage*)fetchPhotoWithURL:(NSURL*)url;
- (void)updateUIForError;
- (IBAction)backTapped:(id)sender;

@end

@implementation MovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
           searchText:(NSString*)searchText {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _searchText = searchText;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Generally - this probably isn't the best approach to async fetch data.
     In this case, we are just fetching one movie/dictionary, so this will work just fine! 
     Good code to review for those who might just be starting with iOS/Objective-C.
     Feel free to alter this code to your liking :) */
    
    [self.activityIndicator startAnimating];
    
    // execute this code on a different thread
    _movieQueue = dispatch_queue_create("com.movieQueue", NULL);
    dispatch_async(_movieQueue, ^{
        // format the URL and fetch with dataWtihContents
        NSString *JSONURL = @"http://www.omdbapi.com/?i=&t=";
        NSString *format = [_searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        JSONURL = [JSONURL stringByAppendingString:format];
        NSError *error;
        NSURL *movieURL = [NSURL URLWithString:JSONURL];
        NSData *movieData = [NSData dataWithContentsOfURL:movieURL];
        /* JSONObjectWithData can't take a nil param, 
         so check for it just incase dataWithContentsOfURL returns nil */
        if (movieData) {
            NSDictionary *movie = [NSJSONSerialization JSONObjectWithData:movieData
                                                                  options:0
                                                                    error:&error];
            if (error) {
                // error turning the data response into a dictionary
                NSLog(@"ERROR --> %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIForError];
                });
            } else {
                // no error - extract the data and use it for our UI
                NSString *movieTitle = movie[@"Title"];
                NSString *posterURLString = movie[@"Poster"];
                NSString *cast = movie[@"Actors"];
                NSString *plot = movie[@"Plot"];
                NSURL *posterURL = [NSURL URLWithString:posterURLString];
                UIImage *posterImage = [self fetchPhotoWithURL:posterURL];
                NSString *detailsText = [NSString stringWithFormat:@"Staring %@.\n\n%@", cast, plot];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // of course, all UI updates are on the main thread!
                    self.navItem.title = movieTitle;
                    self.posterImageView.image = posterImage;
                    self.detailsTextView.text = detailsText;
                    [self.activityIndicator stopAnimating];
                });
            }
        } else {
            // dataWithContentsOfURL returned nil
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIForError];
            });
        }
    });
}

- (UIImage*)fetchPhotoWithURL:(NSURL*)url {
    // again: check to see if imageData is nil
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *theImage;
    if (imageData) {
        theImage = [UIImage imageWithData:imageData];
    } else {
        theImage = [UIImage imageNamed:@"blockbuster"];
    }
    return theImage;
}

- (void)updateUIForError {
    self.detailsTextView.text = @"Opps, try searching again. Sorry!";
    self.posterImageView.image = [UIImage imageNamed:@"blockbuster"];
    [self.activityIndicator stopAnimating];
}

- (IBAction)backTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
