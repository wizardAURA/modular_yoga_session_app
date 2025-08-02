# modular_yoga_session_app


Modular Yoga Session App
This is a simple Flutter app for guided yoga sessions. Everything is powered by a JSON file: pose names, images, audio, durations, and script cues are all loaded dynamically. If you want to update, extend, or swap out the whole session, just change or replace the JSON/assets—no code change required.

Key features:

Reads all pose, image, and audio info from a single JSON file on startup.

For each pose, shows the right image, plays the matching audio, and advances automatically after the set time.

Audio, image, and timing always stay in sync, even if you pause or resume.

Modular: Drop in a new JSON (with new asset files), and the app immediately uses the new session—no need to touch code.

Includes play, pause, resume, skip, progress bar, and timer display as core controls.

How to use:

Update session info in assets/poses.json. Add or remove sequences, change audio/image file names/paths, or swap out durations as you like.

Place matching image files under assets/images/ and audio files under assets/audio/.

Run the app—your new session appears, fully synced and ready to go.

Use the playback controls to guide your session: start, pause, resume, or skip as needed.

Feel free to add background music or a preview/summary page for all poses if you want bonus features later. The core logic automatically adapts to whatever content you provide in the JSON and assets.
