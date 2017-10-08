var exec = require('cordova/exec');

exports.setAppName = function(appName, success, error) {
    exec(success, error, "CordovaCall", "setAppName", [appName]);
};

exports.setIcon = function(iconName, success, error) {
    exec(success, error, "CordovaCall", "setIcon", [iconName]);
};

exports.setRingtone = function(ringtoneName, success, error) {
    exec(success, error, "CordovaCall", "setRingtone", [ringtoneName]);
};

exports.setIncludeInRecents = function(value, success, error) {
    if(typeof value == "boolean") {
      exec(success, error, "CordovaCall", "setIncludeInRecents", [value]);
    } else {
      error("Value Must Be True Or False");
    }
};

exports.setVideo = function(value, success, error) {
    if(typeof value == "boolean") {
      exec(success, error, "CordovaCall", "setVideo", [value]);
    } else {
      error("Value Must Be True Or False");
    }
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
