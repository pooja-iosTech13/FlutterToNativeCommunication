#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import <Flutter/Flutter.h>

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    //1. Controller
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    //2. Channel
    FlutterMethodChannel* flutterChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.LW2/app"
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
    // Input coming from flutter
    NSLog(@"%@", dataArray);
    
    //Output
    NSString* output = [NSString stringWithFormat:@"%@: %s", dataArray[0], "Data Encrypted"];
    completionBlock(output);
}

@end
