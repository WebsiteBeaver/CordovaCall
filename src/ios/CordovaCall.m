#import <Cordova/CDV.h>
#import <CallKit/CallKit.h>
BOOL hasVideo = NO;
NSString* appName;
NSString* ringtone;
NSString* icon;
BOOL includeInRecents;
NSMutableDictionary *callbackIds;

@interface CordovaCall : CDVPlugin <CXProviderDelegate>
    @property (nonatomic, strong) CXProvider *provider;
    @property (nonatomic, strong) CXCallController *callController;
    - (void)updateProviderConfig;
    - (void)setAppName:(CDVInvokedUrlCommand*)command;
    - (void)setIcon:(CDVInvokedUrlCommand*)command;
    - (void)setRingtone:(CDVInvokedUrlCommand*)command;
    - (void)setIncludeInRecents:(CDVInvokedUrlCommand*)command;
    - (void)receiveCall:(CDVInvokedUrlCommand*)command;
    - (void)sendCall:(CDVInvokedUrlCommand*)command;
    - (void)connectCall:(CDVInvokedUrlCommand*)command;
    - (void)endCall:(CDVInvokedUrlCommand*)command;
    - (void)registerEvent:(CDVInvokedUrlCommand*)command;
@end

@implementation CordovaCall

- (void)pluginInitialize
{
    CXProviderConfiguration *providerConfiguration;
    appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    NSMutableSet *handleTypes = [[NSMutableSet alloc] init];
    [handleTypes addObject:@(CXHandleTypeGeneric)];
    providerConfiguration.supportedHandleTypes = handleTypes;
    providerConfiguration.supportsVideo = YES;
    if (@available(iOS 11.0, *)) {
        providerConfiguration.includesCallsInRecents = NO;
    }
    self.provider = [[CXProvider alloc] initWithConfiguration:providerConfiguration];
    [self.provider setDelegate:self queue:nil];
    self.callController = [[CXCallController alloc] init];
    //initialize callback dictionary
    callbackIds = [[NSMutableDictionary alloc]initWithCapacity:5];
    [callbackIds setObject:[NSMutableArray array] forKey:@"answer"];
    [callbackIds setObject:[NSMutableArray array] forKey:@"reject"];
    [callbackIds setObject:[NSMutableArray array] forKey:@"hangup"];
    [callbackIds setObject:[NSMutableArray array] forKey:@"sendCall"];
    [callbackIds setObject:[NSMutableArray array] forKey:@"receiveCall"];
}

- (void)updateProviderConfig {
    CXProviderConfiguration *providerConfiguration;
    providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    if(ringtone != nil) {
        providerConfiguration.ringtoneSound = ringtone;
    }
    if(icon != nil) {
        UIImage *iconImage = [UIImage imageNamed:icon];
        NSData *iconData = UIImagePNGRepresentation(iconImage);
        providerConfiguration.iconTemplateImageData = iconData;
    }
    NSMutableSet *handleTypes = [[NSMutableSet alloc] init];
    [handleTypes addObject:@(CXHandleTypeGeneric)];
    providerConfiguration.supportedHandleTypes = handleTypes;
    providerConfiguration.supportsVideo = YES;
    if (@available(iOS 11.0, *)) {
        if(includeInRecents != nil) {
            providerConfiguration.includesCallsInRecents = includeInRecents;
        }
    }

    self.provider.configuration = providerConfiguration;
}

- (void)setAppName:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* proposedAppName = [command.arguments objectAtIndex:0];

    if (proposedAppName != nil && [proposedAppName length] > 0) {
        appName = proposedAppName;
        [self updateProviderConfig];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"App Name Changed Successfully"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"App Name Can't Be Empty"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setIcon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* proposedIconName = [command.arguments objectAtIndex:0];

    if (proposedIconName == nil || [proposedIconName length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Icon Name Can't Be Empty"];
    } else if([UIImage imageNamed:proposedIconName] == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This icon does not exist. Make sure to add it to your project the right way."];
    } else {
        icon = proposedIconName;
        [self updateProviderConfig];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Icon Changed Successfully"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setRingtone:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* proposedRingtoneName = [command.arguments objectAtIndex:0];

    if (proposedRingtoneName == nil || [proposedRingtoneName length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Ringtone Name Can't Be Empty"];
    } else {
        ringtone = proposedRingtoneName;
        [self updateProviderConfig];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Ringtone Changed Successfully"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setIncludeInRecents:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    includeInRecents = [[command.arguments objectAtIndex:0] boolValue];
    [self updateProviderConfig];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"includeInRecents Changed Successfully"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)receiveCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] init];

    if (callUUIDString != nil && [callUUIDString length] > 0) {
        CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:callUUIDString];
        CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
        callUpdate.remoteHandle = handle;
        callUpdate.hasVideo = hasVideo;

        [self.provider reportNewIncomingCallWithUUID:callUUID update:callUpdate completion:^(NSError * _Nullable error) {
            if(error == nil) {
            } else {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Incoming call successful"];
        for (id callbackId in callbackIds[@"receiveCall"]) {
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"receiveCall event called successfully"];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Caller id can't be empty"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] init];

    if (callUUIDString != nil && [callUUIDString length] > 0) {
        CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:callUUIDString];
        CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:callUUID handle:handle];
        startCallAction.video = hasVideo;
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
        [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
            if (error == nil) {
            } else {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Outgoing call successful"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The caller id can't be empty"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connectCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSArray<CXCall *> *calls = self.callController.callObserver.calls;

    if([calls count] == 1) {
        [self.provider reportOutgoingCallWithUUID:calls[0].UUID connectedAtDate:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Call connected successfully"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No call exists for you to connect"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSArray<CXCall *> *calls = self.callController.callObserver.calls;

    if([calls count] == 1) {
        //[self.provider reportCallWithUUID:calls[0].UUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:calls[0].UUID];
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
        [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
            if (error == nil) {
            } else {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Call ended successfully"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No call exists for you to connect"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerEvent:(CDVInvokedUrlCommand*)command;
{
    NSString* eventName = [command.arguments objectAtIndex:0];
    if(callbackIds[eventName] != nil) {
        [callbackIds[eventName] addObject:command.callbackId];
    }
}

- (void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"%s","providerdidreset");
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    [self.provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    [action fulfill];
    for (id callbackId in callbackIds[@"sendCall"]) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"sendCall event called successfully"];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
    //[action fail];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    [action fulfill];
    for (id callbackId in callbackIds[@"answer"]) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"answer event called successfully"];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
    //[action fail];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    NSArray<CXCall *> *calls = self.callController.callObserver.calls;
    if([calls count] == 1) {
        if(calls[0].hasConnected) {
            for (id callbackId in callbackIds[@"hangup"]) {
                CDVPluginResult* pluginResult = nil;
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"hangup event called successfully"];
                [pluginResult setKeepCallbackAsBool:YES];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }
        } else {
            for (id callbackId in callbackIds[@"reject"]) {
                CDVPluginResult* pluginResult = nil;
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"reject event called successfully"];
                [pluginResult setKeepCallbackAsBool:YES];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }
        }
    }
    [action fulfill];
    //[action fail];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    [action fulfill];
    //[action fail];
}

@end
