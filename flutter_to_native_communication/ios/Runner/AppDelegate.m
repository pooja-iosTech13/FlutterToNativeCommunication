#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "WebViewJavascriptBridge.h"

#import <Flutter/Flutter.h>

@interface AppDelegate()
@property WebViewJavascriptBridge* bridge;
@end

@implementation AppDelegate

NSString *const channelName = @"com.LW2/app";


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {

    //1. Controller
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    //2. Channel
    FlutterMethodChannel* flutterChannel = [FlutterMethodChannel
                                            methodChannelWithName: channelName
                                            binaryMessenger:controller.binaryMessenger];
    //3. Method
    [flutterChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // Note: this method is invoked on the UI thread.
        if ([@"encryptData" isEqualToString:call.method]) {
            [self encrpytData:call.arguments completion:^(NSString *data) {
                result(data);
            }];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    //Flutter generated method for bridging.
    [GeneratedPluginRegistrant registerWithRegistry:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Method to encrypt data passed from Flutter
-(void)encrpytData:(NSArray*)dataArray completion:(void (^)(NSString* data))completionBlock {
    // PGP public key passed from flutter code
    // Public key is always send at 0th index
    NSString *pgpPublicKey = dataArray[0];
    // Input data to be encrypted - passed from flutter code
    NSDictionary *dataObjectDictionary = @{@"user_name" : @"pooja", @"password" : @"dasa", @"v": @"remember_me",@"p": @"rememberMe"};
    
    [self fnSetupWebViewJavascriptBridge:dataObjectDictionary pgpPublicKey:pgpPublicKey completion:^(NSString *data) {
        //Output: - Encrypted data
        completionBlock(data);
    }];
}

-(void)fnSetupWebViewJavascriptBridge:(NSDictionary *)parameters pgpPublicKey:(NSString *)pgpPublicKey completion:(void (^)(NSString* data))completionBlock{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIWebView *webView;
    
    BOOL isWebViewPresentOnWindow = false;
    for (UIView *subView in [window subviews]) {
        if ([subView isKindOfClass:[UIWebView class]]) {
            isWebViewPresentOnWindow = true;
            webView = (UIWebView *)subView;
        }
    }
    
    if (!isWebViewPresentOnWindow) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [window addSubview:webView];
    }
    
    [WebViewJavascriptBridge enableLogging];
    WebViewJavascriptBridge* bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    [bridge registerHandler:@"pgpEncryptionCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"Response from pgpEncryptionCallback");
        
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:NSJSONWritingPrettyPrinted error:&error];
        NSString* stringData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        id dict = @{ @"message": stringData, @"pgp_public_key" : pgpPublicKey };
        
        [self.bridge callHandler:@"pgpEncryptionHandler" data:dict responseCallback:^(id response) {
            completionBlock(response);
        }];
    }];
    
    [self fnLoadPGPHandlerPage:webView];
    [webView setHidden:YES];
    
}

- (void)fnLoadPGPHandlerPage:(UIWebView*)webView {
    
    NSBundle *frameWorkBundle = [NSBundle bundleForClass:[self class]];
    NSString *htmlPath = [frameWorkBundle pathForResource:@"PgpHandler.html" ofType:nil];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
