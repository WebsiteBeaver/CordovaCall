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

exports.setDTMFState = function(value, success, error) {
    if(typeof value == "boolean") {
      exec(success, error, "CordovaCall", "setDTMFState", [value]);
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

exports.receiveCall = function(from, id, success, error) {
    if(typeof id == "function") {
      error = success;
      success = id;
      id = undefined;
    } else if(id) {
      id = id.toString();
    }
    exec(success, error, "CordovaCall", "receiveCall", [from, id]);
};

exports.sendCall = function(to, id, success, error) {
    if(typeof id == "function") {
      error = success;
      success = id;
      id = undefined;
    } else if(id) {
      id = id.toString();
    }
    exec(success, error, "CordovaCall", "sendCall", [to, id]);
};

exports.connectCall = function(success, error) {
    exec(success, error, "CordovaCall", "connectCall", []);
};

exports.endCall = function(success, error) {
    exec(success, error, "CordovaCall", "endCall", []);
};

exports.mute = function(success, error) {
    exec(success, error, "CordovaCall", "mute", []);
};

exports.unmute = function(success, error) {
    exec(success, error, "CordovaCall", "unmute", []);
};

exports.speakerOn = function(success, error) {
    exec(success, error, "CordovaCall", "speakerOn", []);
};

exports.speakerOff = function(success, error) {
    exec(success, error, "CordovaCall", "speakerOff", []);
};

exports.callNumber = function(to, success, error) {
    exec(success, error, "CordovaCall", "callNumber", [to]);
};

exports.on = function(e, f) {
    var success = function(message) {
      f(message);
    };
    var error = function() {
    };
    exec(success, error, "CordovaCall", "registerEvent", [e]);
};
