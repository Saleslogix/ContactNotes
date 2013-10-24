//
//  SSLoginViewController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/24/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSLoginViewController.h"
#import "SSSDataManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSAppController.h"
#import "SSUserDefaults.h"


@interface SSLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *URLField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;

@end

@implementation SSLoginViewController

@synthesize applicationController, userDefaults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inputContainer.layer.cornerRadius = 4.0;
    self.loginButton.layer.cornerRadius = 4.0;
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userNameField.text = self.userDefaults.userName;
    self.passwordField.text = self.userDefaults.password;
    self.URLField.text = self.userDefaults.sDataURL.absoluteString;
    [self updateControls];
}

- (void)logIn
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging In…", nil) maskType:SVProgressHUDMaskTypeClear];
    
    [self.applicationController verifyUsername:self.userNameField.text password:self.passwordField.text URL:[NSURL URLWithString:self.URLField.text] completion:^(NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed", nil)];
            return;
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (IBAction)logInButtonTapped:(UIButton *)button
{
    [self logIn];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField)
    {
        [self.URLField becomeFirstResponder];
    }
    else if (textField == self.URLField && self.loginButton.enabled)
    {
        [textField resignFirstResponder];
        [self logIn];
    }
    
    return NO;
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    [self updateControls];
}

- (void)updateControls
{
    self.loginButton.enabled = self.userNameField.text.length && self.passwordField.text.length && self.URLField.text.length;
}

@end
