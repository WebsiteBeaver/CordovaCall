package com.dmarc.cordovacall;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import android.os.Bundle;
import android.telecom.DisconnectCause;
import android.telecom.PhoneAccount;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.content.ComponentName;
import android.content.Intent;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;
import android.net.Uri;
import android.Manifest;
import android.telecom.Connection;

import com.example.hello.MainActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaCall extends CordovaPlugin {

    private static String TAG = "CordovaCall";
    public static final int CALL_PHONE_REQ_CODE = 0;
    private int permissionCounter = 0;
    private TelecomManager tm;
    private PhoneAccountHandle handle;
    private PhoneAccount phoneAccount;
    private CallbackContext callbackContext;
    private String appName;
    private String from;
    private String to;
    private static HashMap<String, ArrayList<CallbackContext>> callbackContextMap = new HashMap<String, ArrayList<CallbackContext>>();

    public static HashMap<String, ArrayList<CallbackContext>> getCallbackContexts() {
        return callbackContextMap;
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        appName = getApplicationName(this.cordova.getActivity().getApplicationContext());
        handle = new PhoneAccountHandle(new ComponentName(this.cordova.getActivity().getApplicationContext(),MyConnectionService.class),appName);
        tm = (TelecomManager)this.cordova.getActivity().getApplicationContext().getSystemService(this.cordova.getActivity().getApplicationContext().TELECOM_SERVICE);
        phoneAccount = new PhoneAccount.Builder(handle, appName)
                .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER)
                .build();
        callbackContextMap.put("answer",new ArrayList<CallbackContext>());
        callbackContextMap.put("reject",new ArrayList<CallbackContext>());
        callbackContextMap.put("hangup",new ArrayList<CallbackContext>());
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        this.receiveCall();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("receiveCall")) {
            Connection conn = MyConnectionService.getConnection();
            if(conn != null) {
                if(conn.getState() == Connection.STATE_ACTIVE) {
                    this.callbackContext.error("You can't receive a call right now because you're already in a call");
                } else {
                    this.callbackContext.error("You can't receive a call right now");
                }
            } else {
                from = args.getString(0);
                permissionCounter = 2;
                this.receiveCall();
            }
            return true;
        } else if (action.equals("sendCall")) {
            Connection conn = MyConnectionService.getConnection();
            if(conn != null) {
                if(conn.getState() == Connection.STATE_ACTIVE) {
                    this.callbackContext.error("You can't make a call right now because you're already in a call");
                } else if(conn.getState() == Connection.STATE_DIALING) {
                    this.callbackContext.error("You can't make a call right now because you're already trying to make a call");
                } else {
                    this.callbackContext.error("You can't make a call right now");
                }
            } else {
                to = args.getString(0);
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        getCallPhonePermission();
                    }
                });
            }
            return true;
        } else if (action.equals("connectCall")) {
            Connection conn = MyConnectionService.getConnection();
            if(conn == null) {
                this.callbackContext.error("No call exists for you to connect");
            } else if(conn.getState() == Connection.STATE_ACTIVE) {
                this.callbackContext.error("Your call is already connected");
            } else {
                conn.setActive();
                Intent intent = new Intent(this.cordova.getActivity().getApplicationContext(), MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_SINGLE_TOP);
                this.cordova.getActivity().getApplicationContext().startActivity(intent);
                this.callbackContext.success("Call connected successfully");
            }
            return true;
        } else if (action.equals("endCall")) {
            Connection conn = MyConnectionService.getConnection();
            if(conn == null) {
                this.callbackContext.error("No call exists for you to end");
            } else {
                DisconnectCause cause = new DisconnectCause(DisconnectCause.LOCAL);
                conn.setDisconnected(cause);
                conn.destroy();
                MyConnectionService.deinitConnection();
                ArrayList<CallbackContext> callbackContexts = CordovaCall.getCallbackContexts().get("hangup");
                for (final CallbackContext cbContext : callbackContexts) {
                    CordovaPlugin.cordova.getThreadPool().execute(new Runnable() {
                        public void run() {
                            PluginResult result = new PluginResult(PluginResult.Status.OK, "hangup event called successfully");
                            result.setKeepCallback(true);
                            cbContext.sendPluginResult(result);
                        }
                    });
                }
                this.callbackContext.success("Call ended successfully");
            }
            return true;
        } else if (action.equals("registerEvent")) {
            String eventType = args.getString(0);
            ArrayList<CallbackContext> callbackContextList = callbackContextMap.get(eventType);
            callbackContextList.add(this.callbackContext);
            return true;
        }
        return false;
    }

    private void receiveCall() {
        if(permissionCounter >= 1) {
          try {
              Bundle callInfo = new Bundle();
              callInfo.putString("from",from);
              tm.addNewIncomingCall(handle, callInfo);
              permissionCounter = 0;
              this.callbackContext.success("Incoming call successful");
          } catch(Exception e) {
              if(permissionCounter == 2) {
                tm.registerPhoneAccount(phoneAccount);
                Intent phoneIntent = new Intent(TelecomManager.ACTION_CHANGE_PHONE_ACCOUNTS);
                this.cordova.getActivity().getApplicationContext().startActivity(phoneIntent);
              } else {
                this.callbackContext.error("You need to accept phone account permissions in order to receive calls");
              }
          }
        }
        permissionCounter--;
    }

    private void sendCall() {
        Uri uri = Uri.fromParts("tel", to, null);
        Bundle callInfoBundle = new Bundle();
        callInfoBundle.putString("to",to);
        Bundle callInfo = new Bundle();
        callInfo.putParcelable(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS,callInfoBundle);
        callInfo.putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, handle);
        tm.placeCall(uri, callInfo);
        this.callbackContext.success("Outgoing call successful");
    }

    public static String getApplicationName(Context context) {
      ApplicationInfo applicationInfo = context.getApplicationInfo();
      int stringId = applicationInfo.labelRes;
      return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : context.getString(stringId);
    }

    protected void getCallPhonePermission() {
        cordova.requestPermission(this, CALL_PHONE_REQ_CODE, Manifest.permission.CALL_PHONE);
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException
    {
        for(int r:grantResults)
        {
            if(r == PackageManager.PERMISSION_DENIED)
            {
                this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "CALL_PHONE Permission Denied"));
                return;
            }
        }
        switch(requestCode)
        {
            case CALL_PHONE_REQ_CODE:
                this.sendCall();
                break;
        }
    }
}
