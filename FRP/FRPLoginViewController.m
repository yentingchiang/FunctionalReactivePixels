//
//  FRPLoginViewController.m
//  FRP
//
//  Created by Ash Furrow on 10/18/2013.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "FRPLoginViewController.h"

// Utilities
#import "FRPPhotoImporter.h"
#import <SVProgressHUD/SVProgressHUD.h>

// View Model
#import "FRPLoginViewModel.h"

@interface FRPLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, strong) FRPLoginViewModel *viewModel;

@end

@implementation FRPLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Configure navigation item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
    
    // Reactive Stuff
    @weakify(self);
    RAC(self.viewModel, username) = self.usernameTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordTextField.rac_textSignal;
    self.navigationItem.rightBarButtonItem.rac_command = self.viewModel.loginCommand;
    [self.viewModel.loginCommand.executionSignals subscribeNext:^(id x) {
        [x subscribeCompleted:^{
            @strongify(self);
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    [self.viewModel.loginCommand.errors subscribeNext:^(id x) {
        NSLog(@"Login error: %@", x);
    }];
    
    self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
    }];
}

@end
