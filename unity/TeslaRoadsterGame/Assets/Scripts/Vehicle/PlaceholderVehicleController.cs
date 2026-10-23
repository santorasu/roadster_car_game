using System;
using UnityEngine;

namespace TeslaRoadster.Vehicle
{
    [Serializable]
    public class VehicleTelemetry
    {
        public float speedMph;
        public float rpm;
        public float batteryPercent;
        public string gear;
        public float gForce;
        public float motorTempC;
        public float steeringAngle;
        public float throttleInput;
    }

    /// <summary>
    /// Placeholder vehicle controller for Feature 01.
    /// Provides basic movement, telemetry calculation, and visual color response.
    /// </summary>
    public class PlaceholderVehicleController : MonoBehaviour
    {
        [Header("Vehicle Dynamics")]
        [SerializeField] private float maxSpeedMph = 250f;
        [SerializeField] private float acceleration = 35f;
        [SerializeField] private float brakingPower = 50f;
        [SerializeField] private float turnSpeed = 75f;

        [Header("Visual Components")]
        [SerializeField] private Renderer bodyRenderer;

        private float _currentSpeedMph = 0f;
        private float _batteryPercent = 98.5f;
        private float _steeringInput = 0f;
        private float _throttleInput = 0f;
        private float _brakeInput = 0f;
        private string _gear = "D";

        private void Update()
        {
            SimulateMovement();
        }

        private void SimulateMovement()
        {
            float dt = Time.deltaTime;

            if (_throttleInput > 0f)
            {
                _currentSpeedMph = Mathf.MoveTowards(_currentSpeedMph, maxSpeedMph * _throttleInput, acceleration * dt);
                _batteryPercent = Mathf.Max(5f, _batteryPercent - (0.01f * _throttleInput * dt));
            }
            else if (_brakeInput > 0f)
            {
                _currentSpeedMph = Mathf.MoveTowards(_currentSpeedMph, 0f, brakingPower * _brakeInput * dt);
            }
            else
            {
                // Drag / coasting
                _currentSpeedMph = Mathf.MoveTowards(_currentSpeedMph, 0f, 10f * dt);
            }

            // Simple yaw rotation when moving
            if (Mathf.Abs(_currentSpeedMph) > 0.5f)
            {
                transform.Rotate(0f, _steeringInput * turnSpeed * dt * Mathf.Sign(_currentSpeedMph), 0f);
            }

            // Move forward along transform.forward
            float metersPerSecond = _currentSpeedMph * 0.44704f;
            transform.position += transform.forward * (metersPerSecond * dt);
        }

        public void ApplyInput(float throttle, float steering, float brake)
        {
            _throttleInput = Mathf.Clamp01(throttle);
            _steeringInput = Mathf.Clamp(steering, -1f, 1f);
            _brakeInput = Mathf.Clamp01(brake);

            if (_currentSpeedMph < 0.1f && _throttleInput == 0f && _brakeInput == 0f)
            {
                _gear = "P";
            }
            else
            {
                _gear = "D";
            }
        }

        public void SetBodyColor(Color color)
        {
            if (bodyRenderer != null)
            {
                bodyRenderer.material.color = color;
            }
            else
            {
                var rend = GetComponentInChildren<Renderer>();
                if (rend != null) rend.material.color = color;
            }
        }

        public VehicleTelemetry GetTelemetry()
        {
            float rpm = Mathf.Lerp(800f, 18000f, _currentSpeedMph / maxSpeedMph);
            float gForce = (_throttleInput > 0f ? 1.4f * _throttleInput : 0.1f);

            return new VehicleTelemetry
            {
                speedMph = Mathf.Round(_currentSpeedMph * 10f) / 10f,
                rpm = Mathf.Round(rpm),
                batteryPercent = Mathf.Round(_batteryPercent * 10f) / 10f,
                gear = _gear,
                gForce = Mathf.Round(gForce * 100f) / 100f,
                motorTempC = 42.5f + (_currentSpeedMph * 0.1f),
                steeringAngle = _steeringInput * 30f,
                throttleInput = _throttleInput
            };
        }
    }
}
