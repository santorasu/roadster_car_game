using System;
using UnityEngine;

namespace TeslaRoadster.Bridge
{
    /// <summary>
    /// Handles sending messages from Unity to the Android Flutter host environment.
    /// In production Android builds, calls the Android JNI or Flutter Unity plugin bridge.
    /// In standalone/editor, logs or dispatches locally.
    /// </summary>
    public class UnityMessageManager : MonoBehaviour
    {
        private static UnityMessageManager _instance;
        public static UnityMessageManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    var go = new GameObject("UnityMessageManager");
                    _instance = go.AddComponent<UnityMessageManager>();
                    DontDestroyOnLoad(go);
                }
                return _instance;
            }
        }

        public Action<string> OnMessageSent;

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }

        public void SendMessageToFlutter(string jsonMessage)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            try
            {
                // In standard flutter_unity_widget or custom Android plugin,
                // messages are transmitted back to Flutter via UnityPlayerActivity or JNI callback.
                using (var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                using (var currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    if (currentActivity != null)
                    {
                        currentActivity.Call("onUnityMessage", jsonMessage);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[UnityMessageManager] JNI dispatch notice: {ex.Message}");
            }
#else
            Debug.Log($"[Unity -> Flutter]: {jsonMessage}");
#endif
            OnMessageSent?.Invoke(jsonMessage);
        }

        public void SendAction(string action, string payloadJson = "{}")
        {
            var msg = new BridgeMessage(action, payloadJson);
            SendMessageToFlutter(msg.ToJson());
        }
    }
}
