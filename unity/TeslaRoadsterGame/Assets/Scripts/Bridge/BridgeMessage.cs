using System;
using UnityEngine;

namespace TeslaRoadster.Bridge
{
    [Serializable]
    public class BridgeMessage
    {
        public string version = BridgeProtocol.VERSION;
        public string action;
        public string payloadJson;
        public long timestamp;

        public BridgeMessage()
        {
            version = BridgeProtocol.VERSION;
            timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        }

        public BridgeMessage(string action, string payloadJson = "{}")
        {
            this.version = BridgeProtocol.VERSION;
            this.action = action;
            this.payloadJson = payloadJson;
            this.timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        }

        public string ToJson()
        {
            return JsonUtility.ToJson(this);
        }

        public static BridgeMessage FromJson(string json)
        {
            if (string.IsNullOrEmpty(json)) return null;
            try
            {
                return JsonUtility.FromJson<BridgeMessage>(json);
            }
            catch (Exception ex)
            {
                Debug.LogError($"[UnityBridge] Failed to deserialize message: {ex.Message}. Json: {json}");
                return null;
            }
        }
    }
}
