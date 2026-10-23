using System;

namespace TeslaRoadster.Bridge
{
    /// <summary>
    /// Versioned communication protocol definitions between Flutter host and Unity engine.
    /// Target: Android (ARM64 / OpenGLES3 / Vulkan)
    /// </summary>
    public static class BridgeProtocol
    {
        public const string VERSION = "1.0.0";

        // Protocol Action Constants
        public const string ACTION_HANDSHAKE_SYN = "HANDSHAKE_SYN";
        public const string ACTION_HANDSHAKE_ACK = "HANDSHAKE_ACK";
        public const string ACTION_PING = "PING";
        public const string ACTION_PONG = "PONG";
        
        // Scene and Vehicle Lifecycle
        public const string ACTION_LOAD_SCENE = "LOAD_SCENE";
        public const string ACTION_SCENE_LOADED = "SCENE_LOADED";
        public const string ACTION_SPAWN_VEHICLE = "SPAWN_VEHICLE";
        public const string ACTION_VEHICLE_SPAWNED = "VEHICLE_SPAWNED";
        
        // Controls & Configuration
        public const string ACTION_SET_CAMERA_MODE = "SET_CAMERA_MODE";
        public const string ACTION_SET_VEHICLE_COLOR = "SET_VEHICLE_COLOR";
        public const string ACTION_DRIVE_INPUT = "DRIVE_INPUT";
        public const string ACTION_TELEMETRY_UPDATE = "TELEMETRY_UPDATE";

        // Lifecycle & Diagnostics
        public const string ACTION_PAUSE = "PAUSE";
        public const string ACTION_RESUME = "RESUME";
        public const string ACTION_MEMORY_WARNING = "MEMORY_WARNING";
        public const string ACTION_ERROR = "ERROR";
    }
}
