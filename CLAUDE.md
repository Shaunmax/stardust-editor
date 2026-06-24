# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A visual editor for the [Stardust Extended](https://github.com/Icicle-project/stardust-extended) particle engine. Written in ActionScript 3 / Flex (MXML), compiled to a SWF file. The editor can run in a browser via Flash Player or be wrapped in an AIR desktop application.

## Building

**Gradle build** (currently broken on Mac — the `build.gradle` has a Windows path hardcoded for the Flex SDK):
```
./gradlew build
```
Gradle 3.2.1 is required specifically; later versions are incompatible with GradleFX.

**VS Code / AS3MXML extension** (recommended for Mac): The project includes `asconfig.json` pointing to the Flex SDK at `/Users/playkiamac/Projects/apache-flex-sdk-4.16.1-bin`. Build via the extension's compile command. Output goes to `bin/stardust_editor_release.swf`.

There are no unit tests.

## Architecture

The app uses **Robotlegs 2** (MVCS framework with dependency injection). The wiring lives entirely in `AppConfig.as`.

### Startup sequence (`Stardusttool.mxml`)
1. Flex app initializes, creates a `Starling` instance (GPU renderer for particle preview)
2. On Starling ready: Robotlegs `Context` is created with `MVCSBundle` + `AppConfig`
3. A default `.sde` sim is loaded via `LoadSimEvent`; if running in an AIR wrapper, the wrapper can pass a sim file via `loadExternalSim()`

### Key layers

| Layer | Location | Role |
|---|---|---|
| Entry point | `Stardusttool.mxml` | App bootstrap, Starling + Robotlegs init |
| Config | `config/AppConfig.as` | All event→command and view→mediator mappings |
| Model | `model/ProjectModel.as` | Singleton holding current open project state |
| Commands | `controller/` | Business logic triggered by events |
| Views | `view/*.mxml` | Flex Spark UI components |
| Mediators | `view/mediators/` | Bridge between views and the Robotlegs event bus |
| Particle UI | `view/stardust/twoD/` | One renderer per action/zone/initializer type |

### Dual rendering layers
The UI is Flex/Spark (Flash display list). The particle preview canvas is **Starling** (Stage3D / GPU). These two layers coexist: `Globals.starlingCanvas` is a Starling `Sprite` overlaid on the Flash stage.

### Adding a new particle action
1. Create a renderer MXML in `view/stardust/twoD/actions/` extending `PropertyRendererBase`
2. Register it in `Globals.as` `init()` inside `actionDict` with a `DropdownListVO`

Similarly for zones (`view/stardust/twoD/zones/`, `zonesDict`) and triggers (`triggersDDLAC`).

### Key dependencies (in `libs/`)
- `stardust-library.swc` — the Stardust Extended particle engine classes (`idv.cjcat.stardustextended.*`)
- `stardust-sim-loader.swc` — `SimLoader`/`SimPlayer` for loading `.sde` files (`com.funkypandagame.stardustplayer.*`)
- `starling.swc` — Starling 2.x GPU renderer
- `robotlegs-framework-v2.2.1.swc` — MVCS DI framework
- `as3-signals-0.8.swc` — AS3 Signals library

### `.sde` files
Serialized particle simulation files. Example presets live in `src/main/resources/`. `stardustProjectDEFAULT.sde` is embedded in the SWF and loaded on startup.

### AIR wrapper integration
`Globals.externalEventDispatcher` dispatches two special bubble-up events that an AIR wrapper listens for:
- `EXTERNAL_SET_SIM_NAME_EVENT` (`"setSimName"`) — updates the window title
- `EXTERNAL_LOAD_FILE_EVENT` (`"loadFile"`) — requests the AIR wrapper to open the file picker (so it can cache the last path)
