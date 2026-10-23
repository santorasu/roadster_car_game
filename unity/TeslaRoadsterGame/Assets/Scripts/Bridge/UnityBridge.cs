using System;
using UnityEngine;
using TeslaRoadster.Vehicle;

namespace TeslaRoadster.Bridge
{
    /// <summary>
    /// Core bridge component hosted in the Bootstrap scene.
    /// Exposes OnFlutterMessage as the entrypoint for UnitySendMessage calls from Android/Flutter.
    /// </summary>
    public class UnityBridge : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private PlaceholderVehicleController vehicleController;

        private bool _isPaused = false;
        private float _telemetryTimer = 0f;
        private const float TELEMETRY_INTERVAL = 0.1f; // 10 Hz telemetry stream

        private void Awake()
        {
            Application.lowMemory += OnLowMemory;
            Debug.Log($"[UnityBridge] Initialized with protocol v{BridgeProtocol.VERSION}");
        }

        private void Start()
        {
            if (vehicleController == null)
            {
                vehicleController = FindObjectOfType<PlaceholderVehicleController>();
            }

            // Notify Flutter that Unity BootstrapScene is ready
            NotifySceneReady();
        }

        private void Update()
        {
            if (_isPaused) return;

            _telemetryTimer += Time.deltaTime;
            if (_telemetryTimer >= TELEMETRY_INTERVAL)
            {
                _telemetryTimer = 0f;
                EmitTelemetry();
            }
        }

        private void OnDestroy()
        {
            Application.lowMemory -= OnLowMemory;
        }

        /// <summary>
        /// Entry point for messages from Flutter via UnitySendMessage("UnityBridge", "OnFlutterMessage", json)
        /// </summary>
        public void OnFlutterMessage(string jsonMessage)
        {
            if (string.IsNullOrEmpty(jsonMessage)) return;

            var msg = BridgeMessage.FromJson(jsonMessage);
            if (msg == null)
            {
                SendError("MALFORMED_JSON", "Failed to parse incoming bridge message");
                return;
            }

            // Version negotiation
            if (!string.Equals(msg.version, BridgeProtocol.VERSION, StringComparison.OrdinalIgnoreCase))
            {
                Debug.LogWarning($"[UnityBridge] Version mismatch: Flutter sent {msg.version}, Unity is {BridgeProtocol.VERSION}");
            }

            DispatchAction(msg);
        }

        private void DispatchAction(BridgeMessage msg)
        {
            switch (msg.action)
            {
                case BridgeProtocol.ACTION_HANDSHAKE_SYN:
                    HandleHandshake(msg);
                    break;

                case BridgeProtocol.ACTION_PING:
                    HandlePing(msg);
                    break;

                case BridgeProtocol.ACTION_LOAD_SCENE:
                    NotifySceneReady();
                    break;

                case BridgeProtocol.ACTION_SPAWN_VEHICLE:
                    HandleSpawnVehicle(msg);
                    break;

                case BridgeProtocol.ACTION_DRIVE_INPUT:
                    HandleDriveInput(msg);
                    break;

                case BridgeProtocol.ACTION_SET_CAMERA_MODE:
                    HandleSetCameraMode(msg);
                    break;

                case BridgeProtocol.ACTION_SET_VEHICLE_COLOR:
                    HandleSetVehicleColor(msg);
                    break;

                case BridgeProtocol.ACTION_PAUSE:
                    SetGamePaused(true);
                    break;

                case BridgeProtocol.ACTION_RESUME:
                    SetGamePaused(false);
                    break;

                default:
                    Debug.Log($"[UnityBridge] Unknown action received: {msg.action}");
                    break;
            }
        }

        private void HandleHandshake(BridgeMessage msg)
        {
            var payload = JsonUtility.ToJson(new HandshakeAckPayload
            {
                unityVersion = Application.unityVersion,
                protocolVersion = BridgeProtocol.VERSION,
                scene = "BootstrapScene",
                status = "READY",
                renderApi = SystemInfo.graphicsDeviceType.ToString()
            });

            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_HANDSHAKE_ACK, payload);
        }

        private void HandlePing(BridgeMessage msg)
        {
            var payload = JsonUtility.ToJson(new PongPayload
            {
                fps = (int)(1.0f / Mathf.Max(Time.smoothDeltaTime, 0.001f)),
                memoryMB = (int)(GC.GetTotalMemory(false) / (1024 * 1024)),
                timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
            });

            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_PONG, payload);
        }

        private void HandleSpawnVehicle(BridgeMessage msg)
        {
            if (vehicleController == null)
            {
                vehicleController = FindObjectOfType<PlaceholderVehicleController>();
            }

            var payload = JsonUtility.ToJson(new VehicleSpawnedPayload
            {
                vehicleId = "roadster_placeholder_01",
                model = "Cyber Roadster 2026 Prototype",
                status = "SPAWNED"
            });

            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_VEHICLE_SPAWNED, payload);
        }

        private void HandleDriveInput(BridgeMessage msg)
        {
            if (vehicleController == null) return;
            try
            {
                var input = JsonUtility.FromJson<DriveInputPayload>(msg.payloadJson);
                if (input != null)
                {
                    vehicleController.ApplyInput(input.throttle, input.steering, input.brake);
                }
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[UnityBridge] Error applying drive input: {ex.Message}");
            }
        }

        private void HandleSetCameraMode(BridgeMessage msg)
        {
            var cam = FindObjectOfType<ChaseCameraController>();
            if (cam != null && !string.IsNullOrEmpty(msg.payloadJson))
            {
                var payload = JsonUtility.FromJson<CameraModePayload>(msg.payloadJson);
                if (payload != null)
                {
                    cam.SetCameraMode(payload.mode);
                }
            }
        }

        private void HandleSetVehicleColor(BridgeMessage msg)
        {
            if (vehicleController != null && !string.IsNullOrEmpty(msg.payloadJson))
            {
                var payload = JsonUtility.FromJson<VehicleColorPayload>(msg.payloadJson);
                if (payload != null && ColorUtility.TryParseHtmlString(payload.hexColor, out Color color))
                {
                    vehicleController.SetBodyColor(color);
                }
            }
        }

        private void NotifySceneReady()
        {
            var payload = JsonUtility.ToJson(new SceneLoadedPayload
            {
                sceneName = "BootstrapScene",
                status = "INITIALIZED"
            });
            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_SCENE_LOADED, payload);
        }

        private void EmitTelemetry()
        {
            if (vehicleController == null) return;

            var telemetry = vehicleController.GetTelemetry();
            string payload = JsonUtility.ToJson(telemetry);
            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_TELEMETRY_UPDATE, payload);
        }

        public void SetGamePaused(bool pause)
        {
            _isPaused = pause;
            Time.timeScale = pause ? 0f : 1f;
        }

        private void OnApplicationPause(bool pauseStatus)
        {
            SetGamePaused(pauseStatus);
            Debug.Log($"[UnityBridge] Android ApplicationPause: {pauseStatus}");
        }

        private void OnApplicationFocus(bool hasFocus)
        {
            if (!hasFocus)
            {
                SetGamePaused(true);
            }
            Debug.Log($"[UnityBridge] Android ApplicationFocus: {hasFocus}");
        }

        private void OnLowMemory()
        {
            Debug.LogWarning("[UnityBridge] Android OS Low Memory Warning received. Unloading unused assets.");
            Resources.UnloadUnusedAssets();
            GC.Collect();
            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_MEMORY_WARNING, "{\"reason\": \"OS_LOW_MEMORY\"}");
        }

        private void SendError(string code, string message)
        {
            var payload = $"{{\"code\":\"{code}\", \"message\":\"{message}\"}}";
            UnityMessageManager.Instance.SendAction(BridgeProtocol.ACTION_ERROR, payload);
        }

        [Serializable]
        private class HandshakeAckPayload
        {
            public string unityVersion;
            public string protocolVersion;
            public string scene;
            public string status;
            public string renderApi;
        }

        [Serializable]
        private class PongPayload
        {
            public int fps;
            public int memoryMB;
            public long timestamp;
        }

        [Serializable]
        private class SceneLoadedPayload
        {
            public string sceneName;
            public string status;
        }

        [Serializable]
        private class VehicleSpawnedPayload
        {
            public string vehicleId;
            public string model;
            public string status;
        }

        [Serializable]
        private class DriveInputPayload
        {
            public float throttle;
            public float steering;
            public float brake;
        }

        [Serializable]
        private class CameraModePayload
        {
            public string mode;
        }

        [Serializable]
        private class VehicleColorPayload
        {
            public string hexColor;
        }
    }
}
