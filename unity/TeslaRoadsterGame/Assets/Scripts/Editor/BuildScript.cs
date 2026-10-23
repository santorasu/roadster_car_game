#if UNITY_EDITOR
using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace TeslaRoadster.Editor
{
    public static class BuildScript
    {
        private static readonly string[] Scenes = {
            "Assets/Scenes/BootstrapScene.unity"
        };

        [MenuItem("Flutter/Export Android (Library)")]
        public static void ExportAndroidLibraryMenu()
        {
            ExportAndroidLibrary();
        }

        public static void ExportAndroidLibrary()
        {
            Debug.Log("[BuildScript] Starting Unity Android Gradle Library Export...");

            // Output path relative to Unity project: points to flutter android/unityLibrary
            string exportPath = Path.GetFullPath(Path.Combine(Application.dataPath, "../../android/unityLibrary"));
            Debug.Log($"[BuildScript] Target export directory: {exportPath}");

            // Configure Android Build Settings
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            EditorUserBuildSettings.buildAppBundle = false;
            
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel24;
            PlayerSettings.Android.targetSdkVersion = AndroidSdkVersions.AndroidApiLevel35;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64 | AndroidArchitecture.ARMv7;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);

            var buildOptions = BuildOptions.AcceptExternalModificationsToPlayer;

            var report = BuildPipeline.BuildPlayer(
                Scenes,
                exportPath,
                BuildTarget.Android,
                buildOptions
            );

            if (report.summary.result == BuildResult.Succeeded)
            {
                Debug.Log($"[BuildScript] Unity Android Library successfully exported to: {exportPath}");
                Debug.Log($"[BuildScript] Total size: {report.summary.totalSize} bytes in {report.summary.totalTime.TotalSeconds:F1}s");
            }
            else
            {
                Debug.LogError($"[BuildScript] Unity export failed: {report.summary.result} ({report.summary.totalErrors} errors)");
                if (Application.isBatchMode)
                {
                    EditorApplication.Exit(1);
                }
            }
        }
    }
}
#endif
