//
//  WebHandler.h
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/18/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
@interface WebHandler : NSObject <ASIHTTPRequestDelegate>
@property (strong, nonatomic) NSString * html;
@property    (strong, nonatomic) NSString * sessionID;
@property    (strong, nonatomic) NSString * ssoToken;

@property (strong,nonatomic) Parser * myParser;

@property (nonatomic, strong) NSString * userid;
@property (nonatomic, strong) NSString * password;
@property (nonatomic ,strong) NSString * passline;
@property (nonatomic) dispatch_queue_t DownloadQueue;

-(NSString *)getValuefromHTML:(NSString *) html forElement:(NSString *) element;
-(void) requestForHomePage;
-(void) requestForLogin;
-(void ) requestForTimeTable;
-(void) requestForTimeTableJSP;
-(NSString *) getTimeTableHTMLForUser:(NSString *) userid password:(NSString *)password passline:(NSString *) passline;
-(NSString *) getTimetable;
-(void) requestForWelcomePage;
-(UIImage *) requestCaptcha;
@property (nonatomic) BOOL captchaRequested;
@property (nonatomic) NSURL * captchaURL;

@end
