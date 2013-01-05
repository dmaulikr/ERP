//
//  LoginViewController.m
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/22/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import "LoginViewController.h"
#import "GridViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController


@synthesize myParser = _myParser, rollNumber , password , secretQuestion , answerText,activityIndicator ,webHandler , questionid ,reach = _reach, html = _html   ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)getSecurityQuestion:(id)sender {
    
    //Using multithreading
    
    dispatch_queue_t DownloadQueue = dispatch_queue_create("get secret question", NULL) ;
    
    dispatch_async( DownloadQueue , ^{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://erp.iitkgp.ernet.in/SSOAdministration/getSecurityQuestion.htm?user_id=%@&rand_id=1",self.rollNumber.text]];
        NSString *webData= [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
        NSLog(@"%@",webData);
        dispatch_async(dispatch_get_main_queue(), ^{
    self.secretQuestion.text = [webData substringFromIndex:3];
    self.questionid = [webData substringToIndex:2];
    [self showSecretQuestonRelatedStuff];
        });
    });
    
    dispatch_release(DownloadQueue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setDelegate:self];
   
    [self hideSecretQuestonRelatedStuff];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reach startNotifier];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logInPressed:(id)sender {
    
    [self.answerText resignFirstResponder];
    [self.view setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
    self.webHandler = [[WebHandler alloc] init];
    
    dispatch_queue_t DownloadQueue = dispatch_queue_create("get timetable", NULL) ;
    
    dispatch_async( DownloadQueue , ^{
        self.html =  [self.webHandler getTimeTableHTMLForUser:self.rollNumber.text password:self.password.text andSecretAnswer:self.answerText.text  forQuestion:self.questionid ];
        
        self.myParser = [[Parser alloc]init   ];
        self.timetable = [self.myParser getTimeTableDictionaryfromHTML:self.html];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSegueWithIdentifier:@"SendToGrid" sender:self];
            
        });
        
    });

dispatch_release(DownloadQueue);

}
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self logInPressed:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


- (void)viewDidUnload {
    [self setRollNumber:nil];
    [self setPassword:nil];
    [self setActivityIndicator:nil];
    [self setSecretQuestion:nil];
    [self setAnswerText:nil];

    [super viewDidUnload];
}

-(void) hideSecretQuestonRelatedStuff{
    [self.secretQuestion setHidden:YES];
    [self.answerText setHidden:YES];
    
}

-(void) showSecretQuestonRelatedStuff{
    [self.secretQuestion setHidden:NO];
    [self.answerText setHidden:NO];
    
}

-(void)setViewToDefault{
    
    [self.view setUserInteractionEnabled:YES];
    [self.activityIndicator stopAnimating];
    self.rollNumber.text = @"";
    self.password.text = @"";
    self.answerText.text = @"";
    [self hideSecretQuestonRelatedStuff];
    
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
        UIAlertView * alert=[[UIAlertView alloc] init];
        [alert setDelegate:self];
        [alert setTitle:@"No connection"];
        [alert addButtonWithTitle:@"Retry"];
        [alert show];
    }
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if([viewController isKindOfClass:[LoginViewController class]]){
        
        [self setViewToDefault];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"%c",[self.reach isReachable]);
    if([self.reach isReachable])
    {
        [alertView dismissWithClickedButtonIndex:-1 animated:YES]   ;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ( [segue.identifier isEqualToString:@"SendToGrid"])
    {
        GridViewController *newcontroller = segue.destinationViewController;
        newcontroller.timetable =  self.timetable;
    }
}

@end
