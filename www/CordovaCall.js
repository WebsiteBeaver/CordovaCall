var exec = require('cordova/exec');

exports.setConfig = function(config, success, error) {
    var appName = config.appName;
    var ringtone = config.ringtone;
    var icon = config.icon;
    var maxCallGroups = config.maxCallGroups;
    var maxCallsPerGroup = config.maxCallsPerGroup;
    var supportedHandleTypes = config.supportedHandleTypes;
    var video = config.video;
    var includeInRecents = config.includeInRecents;
    exec(success, error, "CordovaCall", "setConfig", [appName, ringtone, icon, maxCallGroups, maxCallsPerGroup, supportedHandleTypes, video, includeInRecents]);
};

exports.getConfig = function(success, error) {
    exec(success, error, "CordovaCall", "getConfig", []);
};

//methods start here

exports.setAppName = function(appname, success, error) {
    exec(success, error, "CordovaCall", "setAppName", [appname]);
};

exports.receiveCall = function(from, success, error) {
    exec(success, error, "CordovaCall", "receiveCall", [from]);
};

exports.sendCall = function(to, success, error) {
    exec(success, error, "CordovaCall", "sendCall", [to]);
};

exports.connectCall = function(success, error) {
    exec(success, error, "CordovaCall", "connectCall", []);
};

exports.endCall = function(success, error) {
    exec(success, error, "CordovaCall", "endCall", []);
};

exports.on = function(e, f) {
    var success = function(message) {
      f(message);
    };
    var error = function() {
    };
    exec(success, error, "CordovaCall", "registerEvent", [e]);
};
