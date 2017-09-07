package com.dmarc.cordovacall;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import android.os.Bundle;
import android.telecom.PhoneAccount;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.content.ComponentName;
import android.content.Intent;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaCall extends CordovaPlugin {
  
    private static String TAG = "CordovaCall";
    private int permissionCounter = 0;
    private TelecomManager tm;
    private PhoneAccountHandle handle;
    private PhoneAccount phoneAccount;
    private CallbackContext callbackContext;
  
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        handle = new PhoneAccountHandle(new ComponentName(this.cordova.getActivity().getApplicationContext(),MyConnectionService.class),"example0097");
        tm = (TelecomManager)this.cordova.getActivity().getApplicationContext().getSystemService(this.cordova.getActivity().getApplicationContext().TELECOM_SERVICE);
        phoneAccount = new PhoneAccount.Builder(handle, "CustomAccount18232")
                .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER)
                .build();
    }
  
    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        this.incomingCall();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("incomingCall")) {
            permissionCounter = 2;
            this.incomingCall();
            return true;
        }
        return false;
    }

    private void incomingCall() {
        if(permissionCounter >= 1) {
          try {
              tm.addNewIncomingCall(handle, new Bundle());
              permissionCounter = 0;
              this.callbackContext.success("Incoming call successful");
          } catch(Exception e) {
              if(permissionCounter == 2) {
                tm.registerPhoneAccount(phoneAccount);
                Intent phoneIntent = new Intent(TelecomManager.ACTION_CHANGE_PHONE_ACCOUNTS);
                  this.cordova.getActivity().getApplicationContext().startActivity(phoneIntent);
              } else {
                this.callbackContext.error("You need to accept phone account permissions in order to recieve calls"); 
              }
          }
        }
        permissionCounter--;
    }
}
