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

exports.incomingCall = function(arg0, success, error) {
    exec(success, error, "CordovaCall", "incomingCall", [arg0]);
};

exports.outgoingCall = function(arg0, success, error) {
    exec(success, error, "CordovaCall", "outgoingCall", [arg0]);
};

exports.connectCall = function(arg0, success, error) {
    exec(success, error, "CordovaCall", "connectCall", [arg0]);
};

exports.endCall = function(arg0, success, error) {
    exec(success, error, "CordovaCall", "endCall", [arg0]);
};

exports.calls = function(arg0, success, error) {
    exec(success, error, "CordovaCall", "calls", [arg0]);
};