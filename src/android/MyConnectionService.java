package com.dmarc.cordovacall;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import android.telecom.Connection;
import android.telecom.ConnectionRequest;
import android.telecom.ConnectionService;
import android.telecom.DisconnectCause;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.util.Log;
import android.os.Handler;
import android.net.Uri;

import java.util.Collection;
import java.util.ArrayList;


public class MyConnectionService extends ConnectionService {

    private static String TAG = "MyConnectionService";
    private static Connection conn;

    public static Connection getConnection() {
        return conn;
    }

    @Override
    public Connection onCreateIncomingConnection(final PhoneAccountHandle connectionManagerPhoneAccount, final ConnectionRequest request) {
        final Connection connection = new Connection() {
            @Override
            public void onHold() {
                super.onHold();
            }

            @Override
            public void onAnswer() {
                super.onAnswer();
                this.setActive();
                ArrayList<CallbackContext> callbackContexts = CordovaCall.getCallbackContexts();
                for (final CallbackContext callbackContext : callbackContexts) {
                    CordovaPlugin.cordova.getThreadPool().execute(new Runnable() {
                        public void run() {
                            PluginResult result = new PluginResult(PluginResult.Status.OK, "onAnswer called successfully");
                            result.setKeepCallback(true);
                            callbackContext.sendPluginResult(result);
                        }
                    });
                }
            }

            @Override
            public void onReject() {
                super.onReject();
                DisconnectCause cause = new DisconnectCause(DisconnectCause.REJECTED);
                this.setDisconnected(cause);
            }

            @Override
            public void onAbort() {
                super.onAbort();

            }

            @Override
            public void onDisconnect() {
                super.onDisconnect();
                DisconnectCause cause = new DisconnectCause(DisconnectCause.LOCAL);
                this.setDisconnected(cause);
            }

        };
        connection.setAddress(Uri.parse(request.getExtras().getString("from")), TelecomManager.PRESENTATION_ALLOWED);
        conn = connection;
        return connection;
    }

    @Override
    public Connection onCreateOutgoingConnection(PhoneAccountHandle connectionManagerPhoneAccount, ConnectionRequest request) {
        final Connection connection = new Connection() {
            @Override
            public void onHold() {
            }

            @Override
            public void onAnswer() {
            }

            @Override
            public void onReject() {
            }

            @Override
            public void onAbort() {
                super.onAbort();

            }

            @Override
            public void onDisconnect() {
            }

        };
        connection.setAddress(Uri.parse(request.getExtras().getString("to")), TelecomManager.PRESENTATION_ALLOWED);
        conn = connection;
        return connection;
    }
}
