# Window rebuild performance (Chrome): before and after `WindowLayer`

- **Date:** 2026-10-03 13:36 (local time)
- **Type:** integration test (frame timings) plus widget test (rebuild counts)
- **Result:** the change removes the dropped frames when opening, focusing and closing windows. Dragging is unchanged.
- **Related plan:** `plan/2026-10-03_1230_windows-state-refactor.md`, `plan/2026-05-08_1844_general-improvement-plan.md` (M5)

## 1. Question

Opening, closing or focusing a window made `DesktopBody` rebuild every open window. The cost was expected to grow with the number of windows. The goal was to measure it, remove it, and measure again.

## 2. What was tested

Three pieces, all in the repo:

| File | What it does |
|---|---|
| `test/performance/window_rebuilds_test.dart` | Counts how many windows rebuild per action (open, focus, close, drag) with 6, 30 and 60 windows. Also checks that cached windows still rebuild when the screen size changes. Runs with `fvm flutter test`. |
| `test/integration/window_performance.dart` | Measures frame timings in a real browser with `watchPerformance`. Scenarios `n06`, `n30`, `n60` (plus a `warmup` run that is discarded). |
| `test/integration/driver.dart` | Driver that writes the reported timings to `build/integration_response_data.json`. |

The two integration files ran from `integration_test/window_performance_test.dart` and `test_driver/integration_test.dart`. They were moved to `test/integration/` and renamed afterwards, with only their header comments changed, so that every test lives under `test/`. The renamed files were not run again; the commands below use the new paths.

Actions per scenario, all measured separately:

- **drag:** drag the topmost window by its header for 1 s.
- **focus:** focus the window at the bottom of the z-order, 20 times.
- **open:** open 5 more windows.
- **close:** close those 5 with the red traffic light, as a user would.

Window count `N` is the number of windows open before the actions: 6 (the real ones), 30 and 60. Windows beyond the 6 real ones are stress windows registered in `windowCatalog` only while the test runs. Their content is a `SizedBox`, so the numbers underestimate the cost with real content.

## 3. The change under test

- New `lib/features/desktop/window_layer.dart`: `WindowLayer` listens only to the list of open windows and keeps the same `WindowBase` instance for each window while it stays open. Flutter skips rebuilding a child that receives the identical widget instance.
- `lib/features/desktop/desktop.dart`: `DesktopBody` no longer watches `WindowsBloc` and uses `const WindowLayer()`. The `BlocBuilder<WindowsBloc, WindowsState>` that wrapped the whole screen was removed (its `builder` did not use the state), so the wallpaper, top bar and dock no longer rebuild on every window change.

## 4. Environment

| Item | Value |
|---|---|
| Flutter | 3.47.6 stable (FVM), Dart 3.13.5 |
| Browser | Chrome 154.0.8037.95, headed (not headless), window 1440x900 |
| Driver | chromedriver 154.0.8037.92 on port 4444 |
| Device / mode | `-d web-server --browser-name=chrome`, `--profile` |
| OS | Windows 11 Pro 10.0.26200 |
| CPU / RAM | AMD Ryzen 7 5800X, 31.9 GB |
| GPU / display | AMD Radeon RX 6700 XT, display at **144 Hz** |

Windows native was not measured: a first attempt failed on a bug in the test's own close assertion (fixed), and a second run was stopped on request because the desktop target will hardly be used.

## 5. Results

### 5.1 Rebuilds per action (widget test)

Number of windows whose content was rebuilt.

| Action | Before | After |
|---|---|---|
| Open | N + 1 | 1 |
| Focus | N + 1 | 0 |
| Close | N | 0 |
| Drag | 1 | 1 |

This is the same for N = 6, 30 and 60. The "before" row comes from the first run of the test, before the change. The test now asserts the "after" values.

### 5.2 Frame timings in Chrome

Worst build frame in ms. Between parentheses: frames that went over the 16.7 ms budget that Flutter uses to count missed frames.

| Action | N | Before | After |
|---|---|---|---|
| Focus | 6 | 7.6 (0) | 4.6 (0) |
| Focus | 30 | 18.4 (16) | 7.6 (0) |
| Focus | 60 | 29.8 (20) | 12.0 (0) |
| Open | 6 | 9.8 (0) | 5.6 (0) |
| Open | 30 | 19.8 (5) | 8.0 (0) |
| Open | 60 | 32.1 (5) | 10.7 (0) |
| Close | 6 | 8.4 (0) | 4.5 (0) |
| Close | 30 | 19.0 (3) | 7.6 (0) |
| Close | 60 | 30.9 (5) | 11.5 (0) |
| Drag | 6 | 4.0 (0) | 3.6 (0) |
| Drag | 30 | 5.0 (0) | 6.8 (0) |
| Drag | 60 | 8.3 (0) | 11.9 (0) |

Rasterizer time is 3.4 ms or less in every focus, open and drag run, before and after. In the close runs it reaches 6.0 ms before the change and 7.2 ms after (60 windows), and no frame goes over the budget. One 22.9 ms raster frame appeared before the change in `close_n06`; it did not repeat after. Full tables are in the appendix.

## 6. Findings

1. **Focus, open and close:** with 30 and 60 windows the worst frame drops to about 40% of its previous value or less, and every missed frame disappears. With 6 windows they were already inside the budget.
2. **Cost still grows with N after the change:** focus with 60 windows is 12.0 ms against 4.6 ms with 6. It is no longer rebuilding, since the widget test counts 0. The likely cause is layout and painting of more windows in the `Stack`, but this was not measured.
3. **Drag did not improve:** with 60 windows the worst frame went from 8.3 to 11.9 ms and the average from 6.7 to 7.7 ms. The drag path was not changed, so this is probably run-to-run noise, but with one run per scenario a real regression cannot be ruled out. It stays under 16.7 ms.
4. **Average build time for "open"** barely moved (3.47 to 3.62 ms with 30 windows). The average mixes the frames of the opening animation with the frame that changes the layer. The gain is in the worst frame.
5. **The display is 144 Hz.** Flutter counts a missed frame against a fixed 16.7 ms, but a 144 Hz display gives about 6.9 ms per frame. Against that rougher reference (build time only, not the whole pipeline):
   - with 6 windows, before the change focus (7.6), open (9.8) and close (8.4) were over; after it (4.6, 5.6, 4.5) they are inside;
   - with 30 windows, after the change the worst frames (7.6, 8.0, 7.6) are slightly over, while p99 (5.8, 7.9, 6.8) is around the budget;
   - with 60 windows, after the change the worst frames (10.7 to 12.0) are over.
   
   The "no missed frames" result is therefore true for the 60 Hz budget Flutter reports, and only partly true for a 144 Hz display.

## 7. Limits

- One run before and one after, on one machine and one browser. Run-to-run variation was not measured, so small differences are not conclusive.
- Stress windows have trivial content. Real content makes each avoided rebuild worth more.
- Frame timings come from Flutter's frame reporting, not from a screen capture.
- Build time is the UI thread only. The frame budget in the rest of the pipeline was not analyzed beyond rasterizer time.

## 8. Next steps (not done)

- Try a `RepaintBoundary` per window and check whether drag and the remaining growth with N come from repainting.
- Repeat each scenario three times to separate improvements from noise.
- Measure with real window content once Skills, Projects, Contact, CV and Github exist.

## 9. Reproduce

Chrome (needs `chromedriver` matching the installed Chrome, running on port 4444):

```bash
fvm flutter drive --driver=test/integration/driver.dart --target=test/integration/window_performance.dart --profile -d web-server --browser-name=chrome --no-headless --browser-dimension=1440,900
```

The browser width must be above 1025 px, or the app shows the tablet or mobile placeholder.

Rebuild counts:

```bash
fvm flutter test test/performance/window_rebuilds_test.dart
```

Raw data of this report: `2026-10-03_1336_window-state-rebuild-performance-chrome.data/before.json` and `after.json` (the `build/` copies are ignored by git).

## 10. Appendix: full metrics

All times in ms. "missed" counts frames over the 16.7 ms budget.

### Before the change

| Run | Frames | Build avg | Build p90 | Build p99 | Build worst | Build missed | Raster avg | Raster p99 | Raster worst | Raster missed |
|---|---|---|---|---|---|---|---|---|---|---|
| focus_n06 | 190 | 1.1 | 6.1 | 6.8 | 7.6 | 0 | 0.561 | 0.8 | 0.9 | 0 |
| focus_n30 | 179 | 2.545 | 15.8 | 17.3 | 18.4 | 16 | 0.988 | 1.3 | 1.3 | 0 |
| focus_n60 | 182 | 4.098 | 27.2 | 28.8 | 29.8 | 20 | 1.513 | 1.9 | 2.4 | 0 |
| open_n06 | 231 | 1.677 | 2.0 | 8.6 | 9.8 | 0 | 0.591 | 0.8 | 1.0 | 0 |
| open_n30 | 193 | 3.47 | 4.3 | 18.7 | 19.8 | 5 | 1.062 | 1.4 | 1.4 | 0 |
| open_n60 | 132 | 5.314 | 7.9 | 30.5 | 32.1 | 5 | 1.565 | 2.0 | 2.1 | 0 |
| close_n06 | 315 | 1.361 | 1.9 | 7.3 | 8.4 | 0 | 0.68 | 2.0 | 22.9 | 1 |
| close_n30 | 289 | 2.838 | 4.4 | 15.7 | 19.0 | 3 | 1.072 | 3.4 | 3.7 | 0 |
| close_n60 | 223 | 4.318 | 7.6 | 29.2 | 30.9 | 5 | 1.664 | 5.7 | 6.0 | 0 |
| drag_n06 | 103 | 1.879 | 2.5 | 2.6 | 4.0 | 0 | 0.594 | 0.8 | 1.0 | 0 |
| drag_n30 | 96 | 3.911 | 4.7 | 5.0 | 5.0 | 0 | 1.013 | 1.3 | 1.6 | 0 |
| drag_n60 | 67 | 6.652 | 7.8 | 8.1 | 8.3 | 0 | 1.565 | 1.9 | 1.9 | 0 |

### After the change

| Run | Frames | Build avg | Build p90 | Build p99 | Build worst | Build missed | Raster avg | Raster p99 | Raster worst | Raster missed |
|---|---|---|---|---|---|---|---|---|---|---|
| focus_n06 | 191 | 0.775 | 2.5 | 3.5 | 4.601 | 0 | 0.663 | 1.199 | 1.2 | 0 |
| focus_n30 | 181 | 1.295 | 5.1 | 5.8 | 7.599 | 0 | 0.997 | 1.3 | 1.5 | 0 |
| focus_n60 | 175 | 2.168 | 8.5 | 10.599 | 12.0 | 0 | 1.642 | 2.401 | 3.2 | 0 |
| open_n06 | 234 | 1.744 | 2.3 | 4.801 | 5.601 | 0 | 0.654 | 1.099 | 1.101 | 0 |
| open_n30 | 184 | 3.615 | 5.4 | 7.9 | 8.0 | 0 | 1.223 | 2.5 | 3.4 | 0 |
| open_n60 | 124 | 5.11 | 8.2 | 10.5 | 10.7 | 0 | 1.744 | 2.601 | 2.899 | 0 |
| close_n06 | 317 | 1.582 | 2.5 | 3.5 | 4.5 | 0 | 0.716 | 1.799 | 2.8 | 0 |
| close_n30 | 262 | 2.971 | 5.5 | 6.8 | 7.599 | 0 | 1.272 | 3.699 | 5.301 | 0 |
| close_n60 | 209 | 4.151 | 8.3 | 10.401 | 11.5 | 0 | 1.86 | 6.5 | 7.2 | 0 |
| drag_n06 | 101 | 2.237 | 3.0 | 3.6 | 3.601 | 0 | 0.733 | 1.0 | 1.0 | 0 |
| drag_n30 | 96 | 3.977 | 4.8 | 5.3 | 6.799 | 0 | 1.021 | 1.201 | 1.201 | 0 |
| drag_n60 | 57 | 7.694 | 9.101 | 11.0 | 11.899 | 0 | 1.801 | 2.3 | 2.899 | 0 |
