//  Created by Dan Lopez on 10/8/14.
//  Copyright (c) 2014 DevHut. All rights reserved.

#import "SearchViewController.h"
#import "MovieViewController.h"

@interface SearchViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSBundle *bundle = [NSBundle mainBundle];
    MovieViewController *movieVC = [[MovieViewController alloc]initWithNibName:@"MovieViewController"
                                                                        bundle:bundle
                                                                    searchText:self.searchTextField.text];
    [self presentViewController:movieVC animated:YES completion:^{
        self.searchTextField.text = @"";
    }];
    
    return YES;
}

@end
