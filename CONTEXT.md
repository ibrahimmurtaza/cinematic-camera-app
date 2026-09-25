# Cinematic Camera App domain glossary

## Core terms

- Camera sensor output: the raw image or video captured by the device camera before any composition or export step.
- Composition frame: the selected cinematic aspect ratio that defines the visible framing guide over the live preview.
- Final export: the derived still image or video cropped to the chosen aspect ratio for final output.
- Frame preset: a reusable aspect-ratio definition with metadata such as name, ratio, description, and orientation.
- Capture session: the lifecycle of a single photo or video operation, including metadata and storage paths.
- Media processor: the platform-specific component responsible for cropping or exporting media according to the selected frame.

## Important distinctions

The app treats raw capture, framing, and final export as separate concepts. The selected composition frame guides the user but does not replace the original capture. Final output is created as a derived artifact that preserves the original when practical.

## Status model

Camera state is modeled as explicit states rather than scattered booleans: initializing, ready, capturing, recording, processing, and error.
