# Cordova Call

- [Install](#install)
- [Examples](#examples)
  - [Receive A Phone Call](#receive-a-phone-call)
  - [Send A Phone Call](#send-a-phone-call)
  - [Make A Call From Recents](#make-a-call-from-recents)
  - [Use A Title Different Than App Name](#use-a-title-different-than-app-name)
  - [Use Your Custom Logo](#use-your-custom-logo)
  - [Make It Say Video Instead Of Audio](#make-it-say-video-instead-of-audio)
  - [Change The Ringtone](#change-the-ringtone)
- [Documentation](#documentation)
  - [Functions](#functions)
    - [receiveCall](#receivecall)
    - [sendCall](#sendcall)
    - [connectCall](#connectcall)
    - [endCall](#endcall)
    - [mute](#mute)
    - [unmute](#unmute)
    - [speakerOn](#speakeron)
    - [speakerOff](#speakeroff)
    - [callNumber](#callnumber)
  - [Options](#options)
    - [setAppName](#setappname)
    - [setIcon](#seticon)
    - [setVideo](#setvideo)
    - [setRingtone](#setringtone)
    - [setIncludeInRecents](#setincludeinrecents)
    - [setDTMFState](#setdtmfstate)
  - [Events](#events)
    - [onAnswer](#onanswer)
    - [onHangup](#onhangup)
    - [onReject](#onreject)
    - [onReceiveCall](#onreceivecall)
    - [onSendCall](#onsendcall)
    - [onMute](#onmute)
    - [onUnmute](#onunmute)
    - [onSpeakerOn](#onspeakeron)
    - [onSpeakerOff](#onspeakeroff)
    - [onDTMF](#ondtmf)
- [Common Errors](#common-errors)
  - [Info.plist](#infoplist)
- [About](#about)
  - [Built With](#built-with)
  - [License](#license)

# Install

Add the CordovaCall plugin to your Cordova project

`cordova plugin add cordova-call`

# Examples

Once you install the CordovaCall plugin, it's very easy to get started. Take a look at some of these examples to get a feel for using this plugin. Note that you should place the functions in `onDeviceReady` as specified in the [Cordova docs](https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready). The screenshots used in these examples show iOS 11 on an iPhone 7 (left) and Android Oreo on a Google Pixel (right). Because CallKit doesn't work on the simulator, you'll need to run this plugin on an actual iOS device (iOS 10 or greater). The one exception is the [`sendCall`](#sendcall) function which works on the simulator. CordovaCall works well on the Android Emulator (assuming you have Marshmallow or greater). These examples are meant to be simple, but make sure that in production you call functions within the callbacks to ensure that one finishes before you start another.

```javascript
//Vanilla JavaScript
document.addEventListener('deviceready', function() {
  console.log('cordova.plugins.CordovaCall is now available');
  var cordovaCall = cordova.plugins.CordovaCall; //not necessary, but might be more convenient
});

//jQuery-like (ex: DOM7)
$$(document).on('deviceready', function() {
  console.log('cordova.plugins.CordovaCall is now available');
  var cordovaCall = cordova.plugins.CordovaCall;
});
```

## Receive A Phone Call

```javascript
cordova.plugins.CordovaCall.receiveCall('David Marcus');
```

<img alt="CordovaCall Receive Call iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31639345-435ce6d2-b2a6-11e7-8f2b-01413197f8ed.png" height="600" /> <img alt="CordovaCall Receive Call ConnectionService" src="https://user-images.githubusercontent.com/26162804/31641743-c6a7a348-b2b4-11e7-84fa-fff289754555.png" height="600" />

Once you press Accept on iOS or you Swipe up to answer on Android, you'll see the in-call UI:

<img alt="CordovaCall Answer Call iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31643319-f1c4fa5e-b2bd-11e7-83bc-1706df93ab70.png" height="600" /> <img alt="CordovaCall Answer Call Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31643304-e08ffb80-b2bd-11e7-8104-4adf85aad3d1.png" height="600" />

If you're using WebRTC to make a video or audio chat app, you can call [`receiveCall`](#receivecall) right before `pc.setRemoteDescription`. For an excellent explanation of how to use WebRTC check out [this WebsiteBeaver tutorial](https://websitebeaver.com/insanely-simple-webrtc-video-chat-using-firebase-with-codepen-demo).

The first time you run this function on Android, you'll be taken to a screen that says Calling accounts. You have to click on `All calling accounts` and then click on the switch as shown below. __On Android Oreo and above this doesn't happen anymore 😃 The `Calling accounts` screen gets skipped, and the native call UI is shown immediately.__

<img alt="CordovaCall All calling accounts Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31642259-09c13ce0-b2b8-11e7-98c4-b82030eb7782.png" height="600" /> <img alt="CordovaCall Accept Phone Account Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31642260-09d144dc-b2b8-11e7-8e6e-e806f4abad21.png" height="600" />

## Send A Phone Call

```javascript
cordova.plugins.CordovaCall.sendCall('Daniel Marcus');

//simulate your friend answering the call 5 seconds after you call
setTimeout(function(){
  cordova.plugins.CordovaCall.connectCall();
}, 5000);
```

You'll see a screen that shows that your call is being connected as show below:

<img alt="CordovaCall Send Call iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31643420-7fbd87ea-b2be-11e7-9555-115a5e588c19.png" height="600" /> <img alt="CordovaCall Send Call Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31643429-8a985c80-b2be-11e7-99fc-6412abda3062.png" height="600" />

After 5 seconds pass, you'll notice that the screen changes because of the [`connectCall`](#connectcall) function:

<img alt="CordovaCall Connect Call iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31801720-114b589e-b518-11e7-8510-4c978548e30d.png" height="600" /> <img alt="CordovaCall Connect Call Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31644024-c54ff312-b2c1-11e7-9410-c584e121bbdc.png" height="600" />

If you're using WebRTC, you might call `pc.createOffer` in the success callback of [`sendCall`](#sendcall). The best place to call [`connectCall`](#connectcall) is in `pc.onaddstream`.

## Make A Call From Recents

```javascript
cordova.plugins.CordovaCall.setIncludeInRecents(true);
cordova.plugins.CordovaCall.receiveCall('David Marcus',21);

cordova.plugins.CordovaCall.on('sendCall',function(info){
  //info now contains the user id of the person you're trying to call
  setTimeout(function(){
    cordova.plugins.CordovaCall.connectCall();
  }, 5000);
});
```

This only works on iOS 11, and not with Android. It's a really neat feature, so props to Apple for adding this. If you call [`setIncludeInRecents`](#setIncludeInRecents), and pass in true as the parameter, calls get stored in Recents. By default calls do not get stored in Recents. Once you tap on the info icon to the right of David Marcus, you'll see the screen on the right. You can set the Social profile to whatever you like (user id is a good choice for many apps that store user ids and names in a database). If you don't set the Social profile, it gets set to the person's name by default. The coolest part about this is that you can call the person back just like a regular phone call. If you use the code in this example, info will contain the user id (21 in this example). This way you can link user ids to names.

<img alt="CordovaCall IncludeInRecents iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31695480-e2ff9b08-b378-11e7-9f47-f82c591b1562.png" height="600" /> <img alt="CordovaCall IncludeInRecents Social Profile iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31695584-8a4cc494-b379-11e7-8492-51c6c8de0f50.png" height="600" />

## Use A Title Different Than App Name

```javascript
cordova.plugins.CordovaCall.setAppName('New App Name');
cordova.plugins.CordovaCall.receiveCall('David Marcus');
```

<img alt="CordovaCall Change App Name iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31695933-905e5814-b37b-11e7-8a46-e75696b5598f.png" height="600" /> <img alt="CordovaCall Change App Name Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31696261-0ce90d5a-b37e-11e7-8b15-199dccd7e755.png" height="600" />

Say you name your app something. It will show up as the title by default with CordovaCall. If you'd like to change the text that shows up without renaming your app, this is an easy way to accomplish that. As you can see above, the app name hasn't changed, but the title that shows up has. Note that after you use this function, Android will force you to go through the Calling accounts screen again before you can receive and send phone calls.

## Use Your Custom Logo

Start by adding your icon to your app directory (the same location for `config.xml`, `www`, and `plugins`). You should select a 120px x 120px image. It should have transparency. This example uses a beaver icon found on [Icons8](https://icons8.com/).

Next you need to add resource-file tags to your `config.xml` (substitute beaver with whatever you named your image). There will already be two platform tags (one for android and one for ios), so just insert the resource-file tags in the platform tags as show here:
```xml
<platform name="android">
    <resource-file src="beaver.png" target="res/drawable/beaver.png" />
</platform>
<platform name="ios">
    <resource-file src="beaver.png" />
</platform>
```

Run `cordova build ios` followed by `cordova build android`. At this point, you're ready to change the call icon and receive a phone call.

```javascript
cordova.plugins.CordovaCall.setIcon('beaver');
cordova.plugins.CordovaCall.receiveCall('David Marcus');
```

<img alt="CordovaCall Custom Icon iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31696605-868d8544-b380-11e7-9612-d4f1b18234d0.png" height="600" /> <img alt="CordovaCall Custom Icon Android ConnectionService" src="https://user-images.githubusercontent.com/26162804/31696595-7a8db322-b380-11e7-8ffb-a0a14986fe9b.png" height="600" />

How awesome is that! You can use your own logo to make your VOIP app be more official.

## Make It Say Video Instead Of Audio
```javascript
cordova.plugins.CordovaCall.setVideo(true);
cordova.plugins.CordovaCall.receiveCall('David Marcus');
```
<img alt="CordovaCall Video Instead Of Audio iOS CallKit" src="https://user-images.githubusercontent.com/26162804/31696941-8a9a384c-b382-11e7-9cff-131998a92de2.png" height="600" />

This is an iOS only feature. You should use this if your app supports video chat.

## Change The Ringtone

This only works on iOS. Make sure to add a custom ringtone file to your app directory (the same location for `config.xml`, `www`, and `plugins`). The ringtone should be a `.caf` file.

```xml
<platform name="ios">
  <resource-file src="ringtone.caf" />
</platform>
```

Run `cordova build ios`. Now call the [`setRingtone`](#setRingtone) function.

```javascript
cordova.plugins.CordovaCall.setRingtone('ringtone');
cordova.plugins.CordovaCall.receiveCall('David Marcus');
```

Click the iPhone below to see and hear an example of receiving a call with a custom ringtone:

<a href="https://www.youtube.com/watch?v=06svKrE1lJ8"><img alt="CordovaCall Custom Ringtone" src="https://user-images.githubusercontent.com/26162804/31696941-8a9a384c-b382-11e7-9cff-131998a92de2.png" height="600" /></a>

# Documentation

## Functions

### receiveCall
```javascript
cordova.plugins.CordovaCall.receiveCall(from [, id] [, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **from**  
Type: *String*   
The name of the person you want to get a call from
- **id**  
Type: *Integer*   
The user id that allows you to identify the person's name
- **success**  
Type: *Function*   
A callback that gets executed if the incoming call is successful
- **error**  
Type: *Function*   
A callback that gets executed if the incoming call fails

### sendCall
```javascript
cordova.plugins.CordovaCall.sendCall(to [, id] [, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **to**  
Type: *String*   
The name of the person you want to call
- **id**  
Type: *Integer*   
The user id that allows you to identify the person's name
- **success**  
Type: *Function*   
A callback that gets executed if the outgoing call is successful
- **error**  
Type: *Function*   
A callback that gets executed if the outgoing call fails

### connectCall
```javascript
cordova.plugins.CordovaCall.connectCall([, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the outgoing call gets connected successfully
- **error**  
Type: *Function*   
A callback that gets executed if the outgoing call fails to connect

### endCall
```javascript
cordova.plugins.CordovaCall.endCall([, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the call ends successfully
- **error**  
Type: *Function*   
A callback that gets executed if the call fails to end

### mute
```javascript
cordova.plugins.CordovaCall.mute([, success] [, error]);
```

_Support: Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the call gets muted successfully
- **error**  
Type: *Function*   
A callback that gets executed if the call fails to mute

### unmute
```javascript
cordova.plugins.CordovaCall.unmute([, success] [, error]);
```

_Support: Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the call gets unmuted successfully
- **error**  
Type: *Function*   
A callback that gets executed if the call fails to unmute

### speakerOn
```javascript
cordova.plugins.CordovaCall.speakerOn([, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the speakerphone gets turned on
- **error**  
Type: *Function*   
A callback that gets executed if the speakerphone fails to turn on

### speakerOff
```javascript
cordova.plugins.CordovaCall.speakerOff([, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **success**  
Type: *Function*   
A callback that gets executed if the speakerphone gets turned off
- **error**  
Type: *Function*   
A callback that gets executed if the speakerphone fails to turn off

### callNumber
```javascript
cordova.plugins.CordovaCall.callNumber(to [, success] [, error]);
```

_Support: iOS 2+ and Android Cupcake+_

_**This is the only function that isn't related to VOIP, as it strictly deals with phone calls.**_

- **to**  
Type: *String*   
The number of the person you want to call (for example 5618770325). Note that this function will actually try to make a real phone call, and is not meant for voip apps.
- **success**  
Type: *Function*   
A callback that gets executed if the phone call is successful
- **error**  
Type: *Function*   
A callback that gets executed if the phone call fails

## Options

### setAppName
```javascript
cordova.plugins.CordovaCall.setAppName(appName [, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **appName**  
Type: *String*   
The title of the call which is your app name by default
- **success**  
Type: *Function*   
A callback that gets executed if the title gets changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the title fails to change

### setIcon
```javascript
cordova.plugins.CordovaCall.setIcon(iconName [, success] [, error]);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **iconName**  
Type: *String*   
The file name (should be a .png file) of the icon you'd like displayed during a call. You need to add the file to your project's directory next to config.xml, platforms, plugins, etc. Then you have to add resource tags to your config.xml file. Finally, make sure to build your project. Take a look at [Use Your Custom Logo](#use-your-custom-logo) for a complete example.
- **success**  
Type: *Function*   
A callback that gets executed if the icon gets changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the icon fails to change

### setVideo
```javascript
cordova.plugins.CordovaCall.setVideo(value [, success] [, error]);
```

_Support: iOS 10+_   

- **value**  
Type: *Boolean*   
Set this to true if you want the call to show up as a video call. By default or if you call this function with a value of false, the call will show up as an audio call.
- **success**  
Type: *Function*   
A callback that gets executed if the video type gets changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the video type fails to change

### setRingtone
```javascript
cordova.plugins.CordovaCall.setRingtone(ringtoneName [, success] [, error]);
```

_Support: iOS 10+_   

- **iconName**  
Type: *String*   
The file name (should be a .caf file) of the ringtone you'd like played during a call. You need to add the file to your project's directory next to config.xml, platforms, plugins, etc. Then you have to add resource tags to your config.xml file. Finally, make sure to build your project. Take a look at [Change The Ringtone](#change-the-ringtone) for a complete example.
- **success**  
Type: *Function*   
A callback that gets executed if the ringtone gets changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the ringtone fails to change

### setIncludeInRecents
```javascript
cordova.plugins.CordovaCall.setIncludeInRecents(value [, success] [, error]);
```

_Support: iOS 11+_   

- **value**  
Type: *Boolean*   
Set this to true if you want calls to show up in recent calls. By default it won't show up in recents if you're using iOS 11. If you're using iOS 10, by default it will show up in recents (and you can't call this function to prevent it from showing up in recents).
- **success**  
Type: *Function*   
A callback that gets executed if the recent calls preference gets changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the recent calls preference fails to change

### setDTMFState
```javascript
cordova.plugins.CordovaCall.setDTMFState(value [, success] [, error]);
```

_Support: iOS 10+_   

- **value**  
Type: *Boolean*   
Set this to true/false to enable/disable DTMF usage.
- **success**  
Type: *Function*   
A callback that gets executed if DTMF setState changed successfully
- **error**  
Type: *Function*   
A callback that gets executed if the DTMF setState fails to change

## Events

### onAnswer
```javascript
cordova.plugins.CordovaCall.on('answer', handler);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you answer an incoming call

### onHangup
```javascript
cordova.plugins.CordovaCall.on('hangup', handler);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you hangup a call

### onReject
```javascript
cordova.plugins.CordovaCall.on('reject', handler);
```

_Support: iOS 10+ and Android Marshmallow+_   

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you reject an incoming call

### onReceiveCall
```javascript
cordova.plugins.CordovaCall.on('receiveCall', handler);
```

_Support: iOS 10+ and Android Marshmallow+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you receive a call

### onSendCall
```javascript
cordova.plugins.CordovaCall.on('sendCall', handler);
```

_Support: iOS 10+ and Android Marshmallow+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you send a call. You can use the data that gets returned in the handler to access the user id that corresponds to the callee's name. This is very useful if you make a call from recents, and need to get the call information.

### onMute
```javascript
cordova.plugins.CordovaCall.on('mute', handler);
```

_Support: iOS 10+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you press the mute button on the native call UI. Note that it does not trigger if you call the [mute](#mute) function.

### onUnmute
```javascript
cordova.plugins.CordovaCall.on('unmute', handler);
```

_Support: iOS 10+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you press the unmute button on the native call UI. Note that it does not trigger if you call the [unmute](#unmute) function.

### onSpeakerOn
```javascript
cordova.plugins.CordovaCall.on('speakerOn', handler);
```

_Support: iOS 10+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you press the speakerOn button on the native call UI, and when you call the [speakerOn](#speakerOn) function.

### onSpeakerOff
```javascript
cordova.plugins.CordovaCall.on('speakerOff', handler);
```

_Support: iOS 10+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you press the speakerOff button on the native call UI, and when you call the [speakerOff](#speakerOff) function.

### onDTMF
```javascript
cordova.plugins.CordovaCall.on('DTMF', handler);
```

_Support: iOS 10+_  

- **handler**  
Type: *Function*   
A user-defined function that gets executed when you press the DTMF buttons on the DTMF native call UI and returns a string with the digit pressed.

# Common Errors

## Info.plist

If you get an error that says `The operation couldn’t be completed. (com.apple.CallKit.error.requesttransaction error 1.)`, open up your `.xcworkspace` file in Xcode, and modify the Info.plist file. You need to add two keys. These keys should already be in your Info.plist because they get added when you install CordovaCall, but you might have deleted them.

1. `Required background modes` with type `Array` and value `App provides Voice over IP services`.
2. `NSUserActivityTypes` with type `Array` and two items with type `String`: `INStartAudioCallIntent` and `INStartVideoCallIntent`

<img alt="Info.plist" src="https://user-images.githubusercontent.com/26162804/31591863-ceb7d3a0-b1f1-11e7-9677-c58711f8f95e.png" width="600" />

# About

Use this Cordova plugin to make your VOIP (audio and video calling) apps feel more native by having calls within your app appear like regular phone calls. You can display the incoming call screen and outgoing call screen by simply calling a JavaScript function. Ringtone sound, call icon, and several other features can be customized. This plugin takes advantage of iOS CallKit and Android ConnectionService in order to allow you to give your app users a better experience by having audio and video calls from your app appear like regular phone calls. WebRTC goes very well with this plugin.

## Built With

* [Cordova](https://cordova.apache.org/) - Allows you to write JavaScript in order to make apps for iOS, Android, etc.
* [CallKit](https://developer.apple.com/documentation/callkit) - iOS Framework that allows your app to access the native call UI
* [ConnectionService](https://developer.android.com/reference/android/telecom/ConnectionService.html) - Android class that allows your app to access the native call UI

## License
MIT License

Copyright (c) 2017 David Marcus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
