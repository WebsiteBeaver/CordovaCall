package com.dmarc.cordovacall;

import android.telecom.Connection;
import android.telecom.ConnectionRequest;
import android.telecom.ConnectionService;
import android.telecom.DisconnectCause;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.util.Log;
import android.content.Intent;
import android.net.Uri;

public class MyConnectionService extends ConnectionService {

    private static String TAG = "MyService";


    @Override
    public Connection onCreateIncomingConnection(final PhoneAccountHandle connectionManagerPhoneAccount, final ConnectionRequest request) {
        Log.i(TAG,"onCreateIncomingConnection60");
        Log.i(TAG,connectionManagerPhoneAccount.toString());
        Log.i(TAG,request.toString());
        final Connection connection = new Connection() {
            @Override
            public void onHold() {
                super.onHold();
            }

            @Override
            public void onAnswer() {
                super.onAnswer();
                this.setActive();
                Log.i(TAG,"onAnswer");
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
        connection.setAddress(Uri.parse("010004405534"), TelecomManager.PRESENTATION_ALLOWED);
        connection.setConnectionCapabilities(Connection.CAPABILITY_SUPPORT_HOLD);

        Log.d(TAG, connection.toString());
        return connection;
    }

    public Connection onCreateOutgoingConnection(PhoneAccountHandle connectionManagerPhoneAccount, ConnectionRequest request) {

        return super.onCreateOutgoingConnection(connectionManagerPhoneAccount,request);
    }
}