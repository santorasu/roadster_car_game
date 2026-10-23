using System;
using UnityEngine;

namespace TeslaRoadster.Vehicle
{
    public class ChaseCameraController : MonoBehaviour
    {
        [Header("Target")]
        [SerializeField] private Transform target;

        [Header("Camera Settings")]
        [SerializeField] private Vector3 chaseOffset = new Vector3(0f, 2.2f, -5.5f);
        [SerializeField] private Vector3 cockpitOffset = new Vector3(0f, 1.1f, 0.2f);
        [SerializeField] private float smoothSpeed = 10f;
        [SerializeField] private float rotationSpeed = 8f;

        private string _currentMode = "CHASE";
        private float _orbitAngle = 0f;

        private void LateUpdate()
        {
            if (target == null) return;

            switch (_currentMode)
            {
                case "COCKPIT":
                    UpdateCockpitView();
                    break;
                case "ORBIT":
                    UpdateOrbitView();
                    break;
                case "CHASE":
                default:
                    UpdateChaseView();
                    break;
            }
        }

        private void UpdateChaseView()
        {
            Vector3 desiredPos = target.TransformPoint(chaseOffset);
            transform.position = Vector3.Lerp(transform.position, desiredPos, smoothSpeed * Time.deltaTime);

            Vector3 lookDir = (target.position + Vector3.up * 1.2f) - transform.position;
            if (lookDir != Vector3.zero)
            {
                Quaternion targetRot = Quaternion.LookRotation(lookDir);
                transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, rotationSpeed * Time.deltaTime);
            }
        }

        private void UpdateCockpitView()
        {
            transform.position = target.TransformPoint(cockpitOffset);
            transform.rotation = target.rotation;
        }

        private void UpdateOrbitView()
        {
            _orbitAngle += 20f * Time.deltaTime;
            Quaternion rot = Quaternion.Euler(15f, _orbitAngle, 0f);
            Vector3 dir = rot * new Vector3(0f, 0f, -6f);
            transform.position = target.position + Vector3.up * 1f + dir;
            transform.LookAt(target.position + Vector3.up * 0.8f);
        }

        public void SetCameraMode(string mode)
        {
            _currentMode = mode.ToUpperInvariant();
        }
    }
}
