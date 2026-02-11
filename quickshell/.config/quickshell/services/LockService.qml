pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Singleton {
    id: root

    // ========================================================================
    // PROPERTIES
    // ========================================================================

    property bool locked: false
    property bool authenticating: false
    property bool failed: false
    property string failMessage: ""

    signal authSucceeded

    // ========================================================================
    // PAM AUTHENTICATION
    // ========================================================================

    property string _pendingPassword: ""

    PamContext {
        id: pam
        config: "login"
        user: Quickshell.env("USER")

        onResponseRequiredChanged: {
            if (responseRequired)
                pam.respond(root._pendingPassword);
        }

        onCompleted: result => {
            root.authenticating = false;
            root._pendingPassword = "";

            if (result === PamResult.Success) {
                console.log("[Lock] Authentication successful");
                root.failed = false;
                root.failMessage = "";
                root.authSucceeded();
            } else {
                console.log("[Lock] Authentication failed:", PamResult.toString(result));
                root.failed = true;
                root.failMessage = "Authentication failed";
            }
        }

        onError: error => {
            root.authenticating = false;
            root._pendingPassword = "";
            console.log("[Lock] PAM error:", PamError.toString(error));
            root.failed = true;
            root.failMessage = "Authentication error";
        }
    }

    // ========================================================================
    // PUBLIC FUNCTIONS
    // ========================================================================

    function lock() {
        if (!locked) {
            console.log("[Lock] Locking screen");
            locked = true;
            failed = false;
            failMessage = "";
            authenticating = false;
            _pendingPassword = "";
        }
    }

    function unlock() {
        if (locked) {
            console.log("[Lock] Unlocking screen");
            // Only set locked = false here. Do NOT reset failed/failMessage/etc
            // because that triggers signals on the LockScreen which is being
            // destroyed (causes "invalid context" warning). State is reset in lock().
            locked = false;
        }
    }

    function tryUnlock(password: string) {
        if (authenticating)
            return;
        console.log("[Lock] Attempting authentication");
        _pendingPassword = password;
        authenticating = true;
        failed = false;
        failMessage = "";
        pam.start();
    }
}
