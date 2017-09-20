#import <Cordova/CDV.h>
#import <CallKit/CallKit.h>

@interface CordovaCall : CDVPlugin <CXProviderDelegate>
    @property (nonatomic, strong) CXProvider *provider;
    @property (nonatomic, strong) CXCallController *callController;
    - (void)incomingCall:(CDVInvokedUrlCommand*)command;
    - (void)outgoingCall:(CDVInvokedUrlCommand*)command;
    - (void)connectCall:(CDVInvokedUrlCommand*)command;
    - (void)endCall:(CDVInvokedUrlCommand*)command;
@end

@implementation CordovaCall

- (void)pluginInitialize
{
    CXProviderConfiguration *providerConfiguration;
    providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"Hello World"];
    self.provider = [[CXProvider alloc] initWithConfiguration:providerConfiguration];
    [self.provider setDelegate:self queue:nil];
    self.callController = [[CXCallController alloc] init];
}

- (void)getConfig:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary *configObj = [NSMutableDictionary dictionary];
    [configObj setObject: self.provider.configuration.localizedName forKey: @"appName"];
    [configObj setObject: self.provider.configuration.ringtoneSound?self.provider.configuration.ringtoneSound:[NSNull null] forKey: @"ringtone"];
    [configObj setObject: self.provider.configuration.iconTemplateImageData?[NSString stringWithFormat:@"%@%@", @"data:image/png;base64,", [self.provider.configuration.iconTemplateImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]]:[NSNull null] forKey: @"icon"];
    NSNumber *maximumCallGroups = @(self.provider.configuration.maximumCallGroups);
    [configObj setObject: maximumCallGroups forKey: @"maxCallGroups"];
    NSNumber *maximumCallsPerCallGroup = @(self.provider.configuration.maximumCallsPerCallGroup);
    [configObj setObject: maximumCallsPerCallGroup forKey: @"maxCallsPerGroup"];
    NSMutableArray *supportedHandleTypes = [[NSMutableArray alloc] init];
    for (NSNumber* handleType in self.provider.configuration.supportedHandleTypes) {
        if ([handleType isEqual:@1]) {
            [supportedHandleTypes addObject:@"generic"];
        } else if ([handleType isEqual:@2]) {
            [supportedHandleTypes addObject:@"phone"];
        } else if ([handleType isEqual:@3]) {
            [supportedHandleTypes addObject:@"email"];
        }
    }
    [configObj setObject: supportedHandleTypes forKey: @"supportedHandleTypes"];
    NSNumber *supportsVideo = self.provider.configuration.supportsVideo ? @YES : @NO;
    [configObj setObject: supportsVideo forKey: @"video"];
    if (@available(iOS 11.0, *)) {
        NSNumber *includesCallsInRecents = self.provider.configuration.includesCallsInRecents ? @YES : @NO;
        [configObj setObject: includesCallsInRecents forKey: @"includeInRecents"];
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:configObj];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setConfig:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* appName = [command.arguments objectAtIndex:0];
    NSString* ringtone = [command.arguments objectAtIndex:1];
    NSString* icon = [command.arguments objectAtIndex:2];
    NSString* maxCallGroups = [command.arguments objectAtIndex:3];
    NSString* maxCallsPerGroup = [command.arguments objectAtIndex:4];
    NSArray* supportedHandleTypes = [command.arguments objectAtIndex:5];
    NSString* video = [command.arguments objectAtIndex:6];
    NSString* includeInRecents = [command.arguments objectAtIndex:7];
    
    CXProviderConfiguration *providerConfiguration;
    if(appName != (id)[NSNull null] && appName.length != 0) {
        providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    } else {
        providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:self.provider.configuration.localizedName];
    }
    if(ringtone != (id)[NSNull null] && ringtone.length != 0) {
        providerConfiguration.ringtoneSound = ringtone;
    }
    if(icon != (id)[NSNull null] && icon.length != 0) {
        UIImage *iconImage = [UIImage imageNamed:icon];
        NSData *iconData = UIImagePNGRepresentation(iconImage);
        providerConfiguration.iconTemplateImageData = iconData;
    }
    if(maxCallGroups != (id)[NSNull null]) {
        NSInteger maximumCallGroups = [maxCallGroups integerValue];
        providerConfiguration.maximumCallGroups = (NSInteger)maximumCallGroups;
    }
    if(maxCallsPerGroup != (id)[NSNull null]) {
        NSInteger maximumCallsPerCallGroup = [maxCallsPerGroup integerValue];
        providerConfiguration.maximumCallsPerCallGroup = (NSInteger)maximumCallsPerCallGroup;
    }
    if(supportedHandleTypes != (id)[NSNull null] && supportedHandleTypes.count != 0) {
        NSMutableSet *handleTypes = [[NSMutableSet alloc] init];
        for (NSString* handleType in supportedHandleTypes) {
            if ([handleType isEqualToString:@"generic"]) {
                [handleTypes addObject:@(CXHandleTypeGeneric)];
            } else if ([handleType isEqualToString:@"phone"]) {
                [handleTypes addObject:@(CXHandleTypePhoneNumber)];
            } else if ([handleType isEqualToString:@"email"]) {
                [handleTypes addObject:@(CXHandleTypeEmailAddress)];
            }
        }
        providerConfiguration.supportedHandleTypes = handleTypes;
    }
    if(video != (id)[NSNull null]) {
        BOOL supportsVideo = [video boolValue];
        providerConfiguration.supportsVideo = supportsVideo;
    }
    if(includeInRecents != (id)[NSNull null]) {
        if (@available(iOS 11.0, *)) {
            BOOL includesCallsInRecents = [includeInRecents boolValue];
            providerConfiguration.includesCallsInRecents = includesCallsInRecents;
        }
    }
    
    self.provider.configuration = providerConfiguration;
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)incomingCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] init];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"1234567890"];
    callUpdate.remoteHandle = handle;
    callUpdate.hasVideo = YES;
    
    [self.provider reportNewIncomingCallWithUUID:callUUID update:callUpdate completion:^(NSError * _Nullable error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    NSMutableDictionary *callObj = [NSMutableDictionary dictionary];
    [callObj setObject: callUUIDString forKey: @"uuid"];
    [callObj setObject: @YES forKey: @"isOutgoing"];
    [callObj setObject: @NO forKey: @"hasConnected"];
    [callObj setObject: @NO forKey: @"hasEnded"];
    [callObj setObject: @YES forKey: @"isOnHold"];

    if (callUUIDString != nil && [callUUIDString length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:callObj];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)outgoingCall:(CDVInvokedUrlCommand*)command
{
    NSString* callUUIDString = [command.arguments objectAtIndex:0];

    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"1234567890"];
    NSUUID *callUUID = [[NSUUID alloc] init];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:callUUID handle:handle];
    startCallAction.video = YES;
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        CDVPluginResult* pluginResult = nil;
        if (error == nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:callUUIDString];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)connectCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:callUUIDString];
    
    if (callUUIDString != nil && [callUUIDString length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:callUUIDString];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.provider reportOutgoingCallWithUUID:callUUID connectedAtDate:nil];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endCall:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:callUUIDString];
    
    if (callUUIDString != nil && [callUUIDString length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:callUUIDString];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.provider reportCallWithUUID:callUUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)calls:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* callUUIDString = [command.arguments objectAtIndex:0];
    //NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:callUUIDString];
    
    NSMutableArray *calls = [[NSMutableArray alloc] init];
    for (CXCall* call in self.callController.callObserver.calls) {
        NSMutableDictionary *callObj = [NSMutableDictionary dictionary];
        [callObj setObject: call.UUID.UUIDString forKey: @"uuid"];
        [callObj setObject: @(call.outgoing) forKey: @"isOutgoing"];
        [callObj setObject: @(call.hasConnected) forKey: @"hasConnected"];
        [callObj setObject: @(call.hasEnded) forKey: @"hasEnded"];
        [callObj setObject: @(call.isOnHold) forKey: @"isOnHold"];
        [calls addObject:callObj];
    }
    
    if (callUUIDString != nil && [callUUIDString length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:calls];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"%s","providerdidreset");
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    NSLog(@"%s","cxstartcallaction");
    [self.provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    [action fulfill];
    //[action fail];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    [action fulfill];
    //[action fail];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    [action fulfill];
    //[action fail];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    [action fulfill];
    //[action fail];
}

@end