# Asset Licenses & Legal Disclaimers

## 1. Trademark & Intellectual Property Disclaimer

- **Trademark Ownership**: "Tesla", "Roadster", and associated logos, emblems, vehicle body shapes, and marks are registered trademarks of **Tesla, Inc.**
- **Project Nature**: This project is an independent tribute concept and software simulation proof-of-concept developed solely for educational, portfolio, and technical integration research purposes.
- **No Affiliation**: This project is **not** endorsed, sponsored, affiliated with, or associated with Tesla, Inc. or any of its subsidiaries.
- **Commercial Restrictions**: This software cannot be commercially distributed under Tesla proprietary trademarks. All brand representations in the codebase are designated as "Tesla Roadster-Inspired" or "Cyber Roadster Concept".

---

## 2. Source Code & Architecture Licensing

The custom software components created for this project, including:
- Flutter UI, state management, and 3D Canvas CustomPainter implementations
- Versioned Bridge Protocol (`v1.0.0`) specifications and serialization handlers
- Unity C# bridge scripts (`UnityBridge.cs`, `UnityMessageManager.cs`, `BuildScript.cs`)
- Placeholder vehicle and camera controllers (`PlaceholderVehicleController.cs`, `ChaseCameraController.cs`)

are licensed under the **MIT License**:

```text
Copyright (c) 2026 Antigravity IDE Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 3. Third-Party Dependencies & Libraries

| Dependency | License | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | BSD 3-Clause | UI framework and rendering engine |
| **Dart SDK** | BSD 3-Clause | Language runtime and standard libraries |
| **cupertino_icons** | MIT License | Supporting icon glyphs |
| **flutter_lints** | BSD 3-Clause | Code style analysis and best-practice enforcement |
| **Android SDK / NDK** | Android Software Development Kit License | Android compilation and JNI bindings |
| **OpenJDK 17** | GNU GPL v2 with Classpath Exception | Java runtime environment for Gradle |

---

## 4. Guidelines for Future Asset Acquisition (Feature 02+)

When importing 3D vehicle models, textures, sound effects, and skybox assets in subsequent features:
1. **Permitted Asset Sources**:
   - Original 3D models created by the project authors.
   - Public domain models (CC0 1.0 Universal).
   - Creative Commons Attribution (CC-BY 4.0 or CC-BY 3.0) with explicit attribution credited in this document.
   - Assets purchased under royalty-free commercial licenses with redistributable game engine rights.
2. **Prohibited Assets**:
   - Extracted proprietary 3D meshes from commercial video games (e.g., Forza, Gran Turismo, Asphalt).
   - Unlicensed manufacturer badges or proprietary CAD files.
